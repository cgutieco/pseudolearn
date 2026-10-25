use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, parse_source, reprint_lossless};

fn parse(text: &str) -> (SyntaxTree, SourceText, usize) {
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    let count = diagnostics.len();
    (tree, source, count)
}

fn count(tree: &SyntaxTree, kind: NodeKind) -> usize {
    tree.nodes.iter().filter(|node| node.kind == kind).count()
}

fn children(tree: &SyntaxTree, kind: NodeKind) -> Vec<usize> {
    tree.nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == kind)
        .map(|(index, _)| tree.child_indices(index).len())
        .collect()
}

#[test]
fn subprogram_and_record_declare_type_parameters() {
    let text = "record Pair<K, V>\ndefine first as K;\ndefine second as V;\nendRecord\nsubroutine swap<K, V>(p as Pair<K, V>) as Pair<V, K>\nreturn Pair(p.second, p.first);\nendSubroutine\nalgorithm P\nendAlgorithm\n";
    let (tree, source, errors) = parse(text);
    assert_eq!(errors, 0);
    assert_eq!(children(&tree, NodeKind::TypeParameters), vec![2, 2]);
    assert_eq!(children(&tree, NodeKind::TypeArguments), vec![2, 2]);
    assert_eq!(reprint_lossless(&source, &tree.tokens), text);
}

#[test]
fn single_parameter_and_nested_arguments_parse() {
    let text = "algorithm P\ndefine b as Box<Box<integer>> <- Box(Box(1));\nendAlgorithm\n";
    let (tree, _, errors) = parse(text);
    assert_eq!(errors, 0);
    assert_eq!(count(&tree, NodeKind::TypeArguments), 2);
}

#[test]
fn plain_names_and_comparisons_stay_ordinary() {
    let text =
        "algorithm P\ndefine a as integer <- 1;\nif a < 2 then\nwrite a;\nendIf\nendAlgorithm\n";
    let (tree, _, errors) = parse(text);
    assert_eq!(errors, 0);
    assert_eq!(count(&tree, NodeKind::TypeArguments), 0);
    assert_eq!(count(&tree, NodeKind::TypeParameters), 0);
}

#[test]
fn malformed_parameter_and_argument_lists_recover_without_panicking() {
    for text in [
        "subroutine id<>(x as integer)\nendSubroutine\nalgorithm P\nendAlgorithm\n",
        "subroutine id<T(x as T)\nendSubroutine\nalgorithm P\nendAlgorithm\n",
        "record Box<T,>\ndefine v as T;\nendRecord\nalgorithm P\nendAlgorithm\n",
        "algorithm P\ndefine b as Box<integer <- 1;\nendAlgorithm\n",
        "algorithm P\ndefine b as Box<> <- 1;\nendAlgorithm\n",
    ] {
        let (tree, source, errors) = parse(text);
        assert!(errors > 0, "{text}");
        assert_eq!(reprint_lossless(&source, &tree.tokens), text);
    }
}

#[test]
fn class_headers_do_not_accept_type_parameters() {
    let (_, _, errors) = parse("class C<T>\nendClass\nalgorithm P\nendAlgorithm\n");
    assert!(errors > 0);
}
