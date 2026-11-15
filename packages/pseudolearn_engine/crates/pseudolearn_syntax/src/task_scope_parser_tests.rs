use crate::{NodeKind, parse_source};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

#[test]
fn parses_bilingual_empty_nested_and_spawn_forms() {
    for (program, profile) in programs() {
        let source = SourceText::new(program.to_owned());
        let (tree, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
        assert_eq!(count(&tree, NodeKind::TaskScope), 3);
        assert_eq!(count(&tree, NodeKind::SpawnStatement), 1);
        assert_eq!(count(&tree, NodeKind::SpawnExpression), 2);
    }
}

#[test]
fn reports_an_unclosed_task_scope() {
    let source = SourceText::new("Algoritmo Main\nTareas\nFinAlgoritmo\n".to_owned());
    let (_, diagnostics) = parse_source(&source, Profile::Spanish);
    assert_eq!(
        diagnostics
            .into_iter()
            .map(|diagnostic| diagnostic.code)
            .collect::<Vec<_>>(),
        vec![DiagnosticCode::UnclosedTaskScope]
    );
}

fn count(tree: &crate::SyntaxTree, kind: NodeKind) -> usize {
    tree.nodes.iter().filter(|node| node.kind == kind).count()
}

fn programs() -> Vec<(&'static str, Profile)> {
    vec![
        (
            "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nTareas\nDefinir answer Como Tarea<Entero> <- Lanzar Work();\nFinTareas\nFinTareas\nTareas\nFinTareas\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\ntasks\ndefine answer as task<integer> <- spawn Work();\nendTasks\nendTasks\ntasks\nendTasks\nendAlgorithm\n",
            Profile::English,
        ),
    ]
}
