use std::collections::BTreeSet;

pub fn generate(names: &BTreeSet<String>, nesting: u32) -> String {
    let mut generated = format!("pub const ANALYSIS_NESTING_LIMIT: u32 = {nesting};\n");
    generated.push_str("#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]\n#[repr(u16)]\npub enum NodeKind {\n");
    for name in names {
        generated.push_str(&format!("{},\n", pascal(name)));
    }
    generated.push_str("ErrorNode,\n}\n");
    for name in names {
        generate_view(name, &mut generated);
    }
    generated
}

fn generate_view(name: &str, generated: &mut String) {
    let type_name = pascal(name);
    let function_name = snake(name);
    generated.push_str(&format!("#[derive(Clone, Copy, Debug, Eq, PartialEq)]\npub struct {type_name}View {{ pub index: usize }}\n"));
    generated.push_str(&format!("pub fn {function_name}_view(tree: &SyntaxTree, index: usize) -> Option<{type_name}View> {{\n"));
    generated.push_str(&format!("tree.nodes.get(index).filter(|node| node.kind == NodeKind::{type_name}).map(|_| {type_name}View {{ index }})\n}}\n"));
}

fn pascal(name: &str) -> String {
    let mut characters = name.chars();
    let first = characters
        .next()
        .map(|character| character.to_uppercase().to_string())
        .unwrap_or_default();
    format!("{first}{}", characters.as_str())
}

fn snake(name: &str) -> String {
    let mut result = String::new();
    for character in name.chars() {
        if character.is_ascii_uppercase() {
            result.push('_');
        }
        result.extend(character.to_lowercase());
    }
    result
}
