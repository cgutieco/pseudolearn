use crate::session::SemanticOptions;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn accepts_empty_nested_and_branch_scopes_in_both_profiles() {
    for (program, profile) in programs() {
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
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
    }
}

#[test]
fn rejects_spawns_outside_scopes_and_in_deferred_cleanup() {
    for (outside, profile) in programs_with_spawn_outside() {
        assert_eq!(
            analyze(outside, profile),
            vec![DiagnosticCode::SpawnOutsideTaskScope]
        );
    }
    for (inside, profile) in programs_with_tasks_in_defer() {
        assert_eq!(
            analyze(inside, profile),
            vec![DiagnosticCode::TaskScopeInsideDefer]
        );
    }
    for (inside, profile) in programs_with_spawn_in_defer() {
        assert_eq!(
            analyze(inside, profile),
            vec![DiagnosticCode::TaskScopeInsideDefer]
        );
    }
}

#[test]
fn rejects_spawns_in_closures_and_calls_to_non_suspendible_units() {
    for (program, profile) in programs_with_invalid_targets() {
        assert_eq!(
            analyze(program, profile),
            vec![DiagnosticCode::SpawnTargetNotSuspendible]
        );
    }
    for (program, profile) in programs_with_closure_spawns() {
        assert_eq!(
            analyze(program, profile),
            vec![DiagnosticCode::SpawnOutsideTaskScope]
        );
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

fn programs() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo Main\nTareas\nSi Verdadero Entonces\nLanzar Work();\nFinSi\nTareas\nLanzar Work();\nFinTareas\nFinTareas\nTareas\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work()\nwrite 1;\nendSubroutine\nalgorithm Main\ntasks\nif true then\nspawn Work();\nendIf\ntasks\nspawn Work();\nendTasks\nendTasks\ntasks\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_spawn_outside() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo Main\nLanzar Work();\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work()\nendSubroutine\nalgorithm Main\nspawn Work();\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_tasks_in_defer() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "Algoritmo Main\nDiferir\nTareas\nFinTareas\nFinDiferir\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "algorithm Main\ndefer\ntasks\nendTasks\nendDefer\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_spawn_in_defer() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo Main\nTareas\nDiferir\nLanzar Work();\nFinDiferir\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work()\nendSubroutine\nalgorithm Main\ntasks\ndefer\nspawn Work();\nendDefer\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_invalid_targets() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Work()\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine Work()\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}

fn programs_with_closure_spawns() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo Main\nTareas\nDefinir operation Como SubProceso() <- SubProceso()\nLanzar Work();\nFinSubProceso;\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work()\nendSubroutine\nalgorithm Main\ntasks\ndefine operation as subroutine() <- subroutine()\nspawn Work();\nendSubroutine;\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}
