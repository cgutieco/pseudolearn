use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

#[test]
fn rejects_unbound_fallible_scope_and_unused_infallible_binding() {
    assert!(codes("SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failure\");\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Fail();\nFinTareas\nFinAlgoritmo\n").contains(&DiagnosticCode::TaskScopeFailureUnbound));
    assert!(
        codes("Algoritmo Main\nTareas failure\nFinTareas\nFinAlgoritmo\n")
            .contains(&DiagnosticCode::TaskScopeFailureUnused)
    );
}

#[test]
fn failure_binding_has_typed_fields_and_must_be_consumed() {
    let prefix = "SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failure\");\nFinSubProceso\nAlgoritmo Main\nTareas failure\nLanzar Fail();\nFinTareas\n";
    assert!(codes(&format!("{prefix}Segun failure Hacer\nNada: Escribir 0;\nAlgo(problem): Escribir problem.Primero;\nFinSegun\nFinAlgoritmo\n")).is_empty());
    assert!(
        codes(&format!("{prefix}FinAlgoritmo\n")).contains(&DiagnosticCode::TaskScopeFailureUnused)
    );
}

#[test]
fn scope_rejects_distinct_exact_error_types() {
    let program = "SubProceso Suspendible First() Como Resultado<Entero, Cadena>\nRetornar Error(\"failure\");\nFinSubProceso\nSubProceso Suspendible Second() Como Resultado<Entero, Entero>\nRetornar Error(1);\nFinSubProceso\nAlgoritmo Main\nTareas failure\nLanzar First();\nLanzar Second();\nFinTareas\nDescartar failure;\nFinAlgoritmo\n";
    assert!(codes(program).contains(&DiagnosticCode::TaskScopeErrorTypeMismatch));
}

fn codes(program: &str) -> Vec<DiagnosticCode> {
    let source = SourceText::new(program.to_owned());
    let (tree, syntax) = pseudolearn_syntax::parse_source(&source, Profile::Spanish);
    assert!(syntax.is_empty(), "{syntax:?}");
    let (_, diagnostics) = crate::analyze_with_options(
        &tree,
        &source,
        crate::SemanticOptions {
            profile: Profile::Spanish,
            strict: true,
        },
    );
    assert!(
        diagnostics.is_empty() || !program.contains("Segun"),
        "{diagnostics:?}"
    );
    diagnostics
        .into_iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

#[test]
fn scope_rejects_errors_with_mutable_collection_payloads() {
    let diagnostics = codes(
        "SubProceso Suspendible Fail() Como Resultado<Entero, Vector<Entero>>\nRetornar Error(Vector());\nFinSubProceso\nAlgoritmo Main\nTareas failureReport\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nFinAlgoritmo\n",
    );
    assert!(
        diagnostics.contains(&DiagnosticCode::TaskErrorNotTransferable),
        "{diagnostics:?}"
    );
}
