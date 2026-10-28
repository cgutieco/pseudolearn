use crate::hir::HirModule;
use crate::session::SemanticOptions;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn marks_root_and_declared_subprogram_suspendible_in_both_profiles() {
    let programs = [
        (
            "SubProceso Suspendible Worker()\nEscribir 7;\nFinSubProceso\nAlgoritmo Main\nAguardar Worker();\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Worker()\nwrite 7;\nendSubroutine\nalgorithm Main\nawait Worker();\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        for strict in [true, false] {
            let (model, diagnostics) = analyze(program, profile, strict);
            assert!(diagnostics.is_empty(), "{diagnostics:?}");
            assert!(model.is_some());
            let Some(model) = model else {
                continue;
            };
            assert_eq!(
                model
                    .functions
                    .iter()
                    .filter(|function| function.suspendible)
                    .count(),
                2
            );
        }
    }
}

#[test]
fn rejects_suspendible_function_and_function_value() {
    let programs = [
        (
            "Funcion Suspendible Calculate() Como Entero\nRetornar 1;\nFinFuncion\nSubProceso Suspendible Worker()\nFinSubProceso\nAlgoritmo Main\nDefinir action Como SubProceso() <- Worker;\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "function suspendable Calculate() as integer\nreturn 1;\nend function\nsubroutine suspendable Worker()\nendSubroutine\nalgorithm Main\ndefine action as subroutine() <- Worker;\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        for strict in [true, false] {
            let (_, diagnostics) = analyze(program, profile, strict);
            assert!(diagnostics.contains(&DiagnosticCode::SuspendibleModifierNotAllowed));
            assert!(diagnostics.contains(&DiagnosticCode::SuspendibleAsValue));
        }
    }
}

#[test]
fn rejects_function_modifier_without_marking_function_suspendible() {
    let programs = [
        (
            "Funcion Suspendible Calculate() Como Entero\nRetornar 1;\nFinFuncion\nAlgoritmo Main\nEscribir Calculate();\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "function suspendable Calculate() as integer\nreturn 1;\nend function\nalgorithm Main\nwrite Calculate();\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        for strict in [true, false] {
            let (_, diagnostics) = analyze(program, profile, strict);
            assert_eq!(
                diagnostics,
                vec![DiagnosticCode::SuspendibleModifierNotAllowed]
            );
        }
    }
}

#[test]
fn rejects_suspendible_methods_constructors_and_closures() {
    let programs = [
        (
            "Clase Box\nMetodo Suspendible run()\nFinMetodo\nMetodo Constructor Suspendible()\nFinMetodo\nFinClase\nAlgoritmo Main\nDefinir callback Como SubProceso() Como Entero <- SubProceso Suspendible() Como Entero\nRetornar 1;\nFinSubProceso;\nEscribir callback();\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "class Box\nmethod suspendable run()\nendMethod\nmethod constructor suspendable()\nendMethod\nendClass\nalgorithm Main\ndefine callback as subroutine() as integer <- subroutine suspendable() as integer\nreturn 1;\nendSubroutine;\nwrite callback();\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        for strict in [true, false] {
            let (_, diagnostics) = analyze(program, profile, strict);
            assert_eq!(
                diagnostics
                    .iter()
                    .filter(|code| **code == DiagnosticCode::SuspendibleModifierNotAllowed)
                    .count(),
                3
            );
        }
    }
}

fn analyze(
    program: &str,
    profile: Profile,
    strict: bool,
) -> (Option<HirModule>, Vec<DiagnosticCode>) {
    let source = SourceText::new(program.to_owned());
    let (tree, syntax_diagnostics) = parse_source(&source, profile);
    assert!(syntax_diagnostics.is_empty());
    let (model, diagnostics) =
        crate::analyze_with_options(&tree, &source, SemanticOptions { profile, strict });
    (
        model,
        diagnostics
            .into_iter()
            .map(|diagnostic| diagnostic.code)
            .collect(),
    )
}
