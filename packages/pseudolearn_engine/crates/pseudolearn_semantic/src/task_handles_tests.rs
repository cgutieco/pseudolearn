use crate::session::SemanticOptions;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn permits_repeated_await_of_a_local_task_handle() {
    for (program, profile) in programs_with_repeated_await() {
        assert!(analyze(program, profile).is_empty());
    }
}

#[test]
fn rejects_task_handles_that_escape_their_scope() {
    for (program, profile) in programs_with_handle_escape() {
        assert!(analyze(program, profile).contains(&DiagnosticCode::TaskHandleEscape));
    }
}

#[test]
fn rejects_non_transferable_and_by_reference_arguments() {
    for (program, profile, expected) in programs_with_invalid_arguments() {
        assert!(analyze(program, profile).contains(&expected));
    }
}

fn analyze(program: &str, profile: Profile) -> Vec<DiagnosticCode> {
    let source = SourceText::new(program.to_owned());
    let (tree, syntax) = parse_source(&source, profile);
    assert!(syntax.is_empty(), "{syntax:?}");
    let (_, diagnostics) = crate::analyze_with_options(
        &tree,
        &source,
        SemanticOptions {
            profile,
            strict: true,
        },
    );
    diagnostics
        .into_iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

fn programs_with_repeated_await() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Answer() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo Main\nTareas\nDefinir answer Como Tarea<Entero> <- Lanzar Answer();\nEscribir Aguardar answer;\nEscribir Aguardar answer;\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Answer() as integer\nreturn 7;\nendSubroutine\nalgorithm Main\ntasks\ndefine answer as task<integer> <- spawn Answer();\nwrite await answer;\nwrite await answer;\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_handle_escape() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo Main\nTareas\nDefinir first Como Tarea<Entero> <- Lanzar Work();\nDefinir second Como Tarea<Entero> <- Lanzar Work();\nfirst <- second;\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nsubroutine Leak() as task<integer>\ntasks\ndefine item as task<integer> <- spawn Work();\nreturn item;\nendTasks\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
        (
            "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo Main\nTareas\nDefinir item Como Tarea<Entero> <- Lanzar Work();\nDefinir closure Como SubProceso() <- SubProceso()\nDescartar item;\nFinSubProceso;\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nsubroutine Consume(item as task<integer>)\nendSubroutine\nalgorithm Main\ntasks\ndefine item as task<integer> <- spawn Work();\nConsume(item);\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_invalid_arguments() -> Vec<(&'static str, Profile, DiagnosticCode)> {
    vec![
        (
            "SubProceso Suspendible Use(items Como Vector<Entero>)\nFinSubProceso\nAlgoritmo Main\nDefinir items Como Vector<Entero> <- Vector();\nTareas\nLanzar Use(items);\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
            DiagnosticCode::TaskArgumentNotTransferable,
        ),
        (
            "subroutine suspendable Use(value as integer by reference)\nendSubroutine\nalgorithm Main\ndefine value as integer <- 1;\ntasks\nspawn Use(value);\nendTasks\nendAlgorithm\n",
            Profile::English,
            DiagnosticCode::TaskByReferenceArgument,
        ),
    ]
}
