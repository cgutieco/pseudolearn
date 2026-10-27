use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use serde_json::Value;

const EFFECT: &str = "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\n";

#[test]
fn purity_cases_reject_hidden_effects() -> Result<(), String> {
    let corpus =
        include_str!("../../../../pseudolearn_spec/specifications/lang/lang.capability.purity.md");
    for identity in ["C7", "C8", "C9"] {
        let case = find_case(corpus, identity)?;
        let program = case
            .pointer("/programas/es")
            .and_then(Value::as_str)
            .ok_or("missing program")?;
        let (module, diagnostics) = analyze(program);
        assert!(module.is_none(), "{identity}: hidden effect accepted");
        assert!(
            diagnostics
                .iter()
                .any(|diagnostic| diagnostic.code
                    == DiagnosticCode::PureFunctionTransitiveSideEffect),
            "{identity}: {diagnostics:?}"
        );
    }
    Ok(())
}

fn find_case(corpus: &str, identity: &str) -> Result<Value, String> {
    for block in corpus.split("```caso\n").skip(1) {
        let source = block.split("\n```").next().ok_or("missing case body")?;
        let case: Value = serde_json::from_str(source).map_err(|error| error.to_string())?;
        if case.get("id").and_then(Value::as_str) == Some(identity) {
            return Ok(case);
        }
    }
    Err(format!("missing case {identity}"))
}

fn analyze(
    program: &str,
) -> (
    Option<pseudolearn_semantic::HirModule>,
    Vec<pseudolearn_diagnostics::Diagnostic>,
) {
    let source = pseudolearn_source::SourceText::new(program.to_owned());
    let profile = pseudolearn_lexicon::Profile::Spanish;
    let (tree, mut diagnostics) = pseudolearn_syntax::parse_source_with_terminator(
        &source,
        profile,
        Some(DiagnosticCode::MissingStatementTerminator),
    );
    let (module, mut semantic) = pseudolearn_semantic::analyze_with_options(
        &tree,
        &source,
        pseudolearn_semantic::SemanticOptions {
            profile,
            strict: true,
        },
    );
    diagnostics.append(&mut semantic);
    (module, diagnostics)
}

fn codes(program: &str) -> Vec<DiagnosticCode> {
    analyze(program).1.iter().map(|diagnostic| diagnostic.code).collect()
}

fn with_effect(body: &str) -> String {
    format!("{EFFECT}{body}")
}

fn related_count(diagnostics: &[Diagnostic], index: usize) -> Option<usize> {
    diagnostics.get(index).map(|diagnostic| diagnostic.related.len())
}

fn semantic(program: &str) -> Vec<Diagnostic> {
    analyze(program).1
}

#[test]
fn read_inside_a_function_is_a_direct_effect() {
    let program = "Funcion F() Como Entero\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nRetornar x;\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n";
    assert_eq!(codes(program), vec![DiagnosticCode::PureFunctionSideEffect]);
}

#[test]
fn subprogram_with_the_same_effects_is_accepted() {
    let program = "SubProceso F() Como Entero\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x;\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n";
    assert_eq!(codes(program), Vec::<DiagnosticCode>::new());
}

#[test]
fn empty_pure_function_is_accepted() {
    let program = "Funcion F()\nFinFuncion\nAlgoritmo P\nF();\nFinAlgoritmo\n";
    assert_eq!(codes(program), Vec::<DiagnosticCode>::new());
}

#[test]
fn causal_chain_lists_every_unit_down_to_the_direct_effect() {
    let program = with_effect("SubProceso B() Como Entero\nRetornar Effect();\nFinSubProceso\nFuncion A() Como Entero\nRetornar B();\nFinFuncion\nAlgoritmo P\nEscribir A();\nFinAlgoritmo\n");
    let diagnostics = semantic(&program);
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(diagnostics.first().map(|diagnostic| diagnostic.code), Some(DiagnosticCode::PureFunctionTransitiveSideEffect));
    let lines: Vec<usize> = diagnostics
        .iter()
        .flat_map(|diagnostic| diagnostic.related.iter())
        .map(|span| program[..usize::try_from(span.start).unwrap_or(0)].matches('\n').count().saturating_add(1))
        .collect();
    assert_eq!(lines, vec![5, 1]);
}

#[test]
fn direct_effect_has_no_causal_chain() {
    let program = "Funcion F() Como Entero\nEscribir 1;\nRetornar 1;\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n";
    let diagnostics = semantic(program);
    assert_eq!(diagnostics.len(), 1);
    assert_eq!(related_count(&diagnostics, 0), Some(0));
}

#[test]
fn mutual_recursion_reaches_the_fixed_point_in_both_functions() {
    let program = with_effect("Funcion Even(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar Effect();\nFinSi\nRetornar Odd(n - 1);\nFinFuncion\nFuncion Odd(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 0;\nFinSi\nRetornar Even(n - 1);\nFinFuncion\nAlgoritmo P\nEscribir Odd(3);\nFinAlgoritmo\n");
    let diagnostics = semantic(&program);
    assert_eq!(diagnostics.len(), 2, "{diagnostics:?}");
    assert!(diagnostics.iter().all(|diagnostic| diagnostic.code == DiagnosticCode::PureFunctionTransitiveSideEffect));
    assert_eq!(related_count(&diagnostics, 0), Some(1));
    assert_eq!(related_count(&diagnostics, 1), Some(2));
}

#[test]
fn pure_mutual_recursion_is_accepted() {
    let program = "Funcion Even(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 1;\nFinSi\nRetornar Odd(n - 1);\nFinFuncion\nFuncion Odd(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 0;\nFinSi\nRetornar Even(n - 1);\nFinFuncion\nAlgoritmo P\nEscribir Odd(3);\nFinAlgoritmo\n";
    assert_eq!(codes(program), Vec::<DiagnosticCode>::new());
}

#[test]
fn effect_inside_nested_closures_is_attributed_to_the_pure_function() {
    let program = with_effect("Funcion F() Como Entero\nDefinir outer Como SubProceso() Como Entero <- SubProceso() Como Entero\nDefinir inner Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar Effect();\nFinSubProceso;\nRetornar inner();\nFinSubProceso;\nRetornar outer();\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n");
    assert_eq!(codes(&program), vec![DiagnosticCode::PureFunctionTransitiveSideEffect]);
}

#[test]
fn pure_nested_closures_are_accepted() {
    let program = "Funcion F() Como Entero\nDefinir outer Como SubProceso() Como Entero <- SubProceso() Como Entero\nDefinir inner Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar 1;\nFinSubProceso;\nRetornar inner();\nFinSubProceso;\nRetornar outer();\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n";
    assert_eq!(codes(program), Vec::<DiagnosticCode>::new());
}

const CALCULABLE: &str = "Interfaz Calculable\nFuncion Calcular() Como Entero;\nFinInterfaz\n";

#[test]
fn interface_realization_reading_input_is_rejected() {
    let program = format!("{CALCULABLE}Clase Demo Realiza Calculable\nMetodo Calcular() Como Entero\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nRetornar x;\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n");
    assert_eq!(codes(&program), vec![DiagnosticCode::PureFunctionInterfaceImpurity]);
}

#[test]
fn interface_realization_with_an_indirect_effect_carries_the_chain() {
    let program = with_effect(&format!("{CALCULABLE}Clase Demo Realiza Calculable\nMetodo Calcular() Como Entero\nRetornar Effect();\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n"));
    let diagnostics = semantic(&program);
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(diagnostics.first().map(|diagnostic| diagnostic.code), Some(DiagnosticCode::PureFunctionInterfaceImpurity));
    assert_eq!(related_count(&diagnostics, 0), Some(1));
}

#[test]
fn pure_interface_realization_is_accepted() {
    let program = format!("{CALCULABLE}Clase Demo Realiza Calculable\nMetodo Calcular() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n");
    assert_eq!(codes(&program), Vec::<DiagnosticCode>::new());
}

#[test]
fn pure_function_calling_a_method_with_effect_is_rejected() {
    let program = with_effect("Clase K\nMetodo Run() Como Entero\nRetornar Effect();\nFinMetodo\nFinClase\nFuncion F(k Como K) Como Entero\nRetornar k.Run();\nFinFuncion\nAlgoritmo P\nDefinir k Como K <- Nuevo K();\nEscribir F(k);\nFinAlgoritmo\n");
    assert_eq!(codes(&program), vec![DiagnosticCode::PureFunctionTransitiveSideEffect]);
}
