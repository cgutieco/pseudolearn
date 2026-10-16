use pseudolearn_ir::Operation;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, parse_source, reprint::reprint};
use serde_json::{Value, json};

const STATEMENT_KINDS: [NodeKind; 12] = [
    NodeKind::AssignmentStatement,
    NodeKind::CallStatement,
    NodeKind::ReturnStatement,
    NodeKind::Declaration,
    NodeKind::Conditional,
    NodeKind::ForLoop,
    NodeKind::WhileLoop,
    NodeKind::RepeatLoop,
    NodeKind::Switch,
    NodeKind::Input,
    NodeKind::Output,
    NodeKind::DimensionDeclaration,
];

pub fn probe(request: &Value) -> Value {
    let text = request
        .get("program")
        .and_then(Value::as_str)
        .unwrap_or_default();
    let profile = request
        .get("profile")
        .and_then(Value::as_str)
        .and_then(Profile::from_name)
        .unwrap_or(Profile::Spanish);
    let outcome =
        std::panic::catch_unwind(|| match request.get("operation").and_then(Value::as_str) {
            Some("reprint") => reprinted(text, profile),
            Some("statement_mass") => statement_mass(text, request, profile),
            _ => json!({"failure":"unsupported probe"}),
        });
    outcome.unwrap_or_else(|_| json!({"failure":"internalFault"}))
}

fn reprinted(text: &str, profile: Profile) -> Value {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    json!({"kind":"probe","reprint":reprint(&source, &tree)})
}

fn statement_mass(text: &str, request: &Value, profile: Profile) -> Value {
    let strictness = request
        .get("strictness")
        .and_then(Value::as_str)
        .unwrap_or("strict");
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    let Ok(module) = crate::compile_source_to_module(text, profile.as_str(), strictness) else {
        return json!({"kind":"probe","compiled":false});
    };
    let (enters, exits, mass) = observation_counts(&module);
    json!({"kind":"probe","compiled":true,"statements":statements(&tree),
        "enters":enters,"exits":exits,"mass":mass})
}

fn statements(tree: &SyntaxTree) -> usize {
    let field_ranges: Vec<(usize, usize)> = tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::FieldDeclaration)
        .map(|(index, node)| {
            let size = usize::try_from(node.subtree_size).unwrap_or_default();
            (index.saturating_add(1).saturating_sub(size), index)
        })
        .collect();
    tree.nodes
        .iter()
        .enumerate()
        .filter(|(index, node)| {
            STATEMENT_KINDS.contains(&node.kind)
                && !field_ranges
                    .iter()
                    .any(|(first, last)| (*first..=*last).contains(index))
        })
        .count()
}

fn observation_counts(module: &pseudolearn_ir::Module) -> (u64, u64, u64) {
    let mut counts = (0_u64, 0_u64, 0_u64);
    for function in &module.functions {
        for block in &function.blocks {
            counts.2 = counts.2.saturating_add(u64::from(block.mass));
            let operations = block
                .instructions
                .iter()
                .filter_map(|instruction| function.columns.operation(*instruction));
            for operation in operations {
                tally(operation, &mut counts);
            }
        }
    }
    counts
}

fn tally(operation: Operation, counts: &mut (u64, u64, u64)) {
    match operation {
        Operation::StmtEnter => counts.0 = counts.0.saturating_add(1),
        Operation::StmtExit => counts.1 = counts.1.saturating_add(1),
        _ => {}
    }
}
