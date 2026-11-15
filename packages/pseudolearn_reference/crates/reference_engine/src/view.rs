use pseudolearn_api::ApiSession;
use reference_model::{MemberView, Profile, ProgramView, SubprogramView};
use serde_json::{Value, json};
use std::collections::BTreeMap;

const CONSTRUCT_BY_SYNTAX_KIND: [(&str, &str); 9] = [
    ("conditional", "condicional"),
    ("switch", "seleccion-multiple"),
    ("while_loop", "bucle-condicional"),
    ("repeat_loop", "bucle-condicional-posterior"),
    ("for_loop", "bucle-contado"),
    ("dimension_declaration", "arreglo"),
    ("subroutine", "subprograma"),
    ("class_unit", "clase"),
    ("interface_unit", "interfaz"),
];

pub fn program_view(code: &str, profile: Profile) -> Result<ProgramView, String> {
    let mut session = ApiSession::default();
    let document = session.call(
        "create_document",
        &json!({"program": code, "profile": profile.code()}),
    );
    let resource = document
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("the document was rejected: {document}"))?;
    let response = session.call("program_view", &json!({"resource": resource}));
    let view = response
        .get("value")
        .ok_or_else(|| format!("the program has no view: {response}"))?;
    Ok(ProgramView {
        constructs: constructs(view),
        subprograms: subprograms(view),
        members: members(view),
    })
}

fn entries<'view>(view: &'view Value, field: &str) -> &'view [Value] {
    view.get(field)
        .and_then(Value::as_array)
        .map_or(&[], Vec::as_slice)
}

fn text(entry: &Value, field: &str) -> String {
    entry
        .get(field)
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_owned()
}

fn syntax_kind(node: &Value) -> &str {
    node.get("syntax_kind")
        .and_then(Value::as_str)
        .unwrap_or_default()
}

fn constructs(view: &Value) -> BTreeMap<String, usize> {
    let mut counts = BTreeMap::new();
    for node in entries(view, "nodes") {
        let kind = syntax_kind(node);
        if let Some((_, construct)) = CONSTRUCT_BY_SYNTAX_KIND
            .iter()
            .find(|(candidate, _)| *candidate == kind)
        {
            let count: &mut usize = counts.entry((*construct).to_owned()).or_default();
            *count = count.saturating_add(1);
        }
    }
    counts
}

fn node_by_id<'view>(view: &'view Value, node_id: &str) -> Option<&'view Value> {
    entries(view, "nodes")
        .iter()
        .find(|node| node.get("node_id").and_then(Value::as_str) == Some(node_id))
}

fn children<'view>(view: &'view Value, node: &Value) -> Vec<&'view Value> {
    node.get("child_node_ids")
        .and_then(Value::as_array)
        .map(|identifiers| {
            identifiers
                .iter()
                .filter_map(Value::as_str)
                .filter_map(|identifier| node_by_id(view, identifier))
                .collect()
        })
        .unwrap_or_default()
}

fn arity(view: &Value, unit: &Value) -> usize {
    let Some(node) = node_by_id(view, &text(unit, "node_id")) else {
        return 0;
    };
    children(view, node)
        .into_iter()
        .find(|child| syntax_kind(child) == "parameters")
        .map_or(0, |parameters| {
            children(view, parameters)
                .into_iter()
                .filter(|child| syntax_kind(child) == "parameter")
                .count()
        })
}

fn subprograms(view: &Value) -> Vec<SubprogramView> {
    entries(view, "units")
        .iter()
        .filter(|unit| text(unit, "kind") == "subprogram")
        .map(|unit| SubprogramView {
            name: text(unit, "name"),
            arity: arity(view, unit),
        })
        .collect()
}

fn members(view: &Value) -> Vec<MemberView> {
    entries(view, "members")
        .iter()
        .map(|member| MemberView {
            class: text(member, "class"),
            name: text(member, "name"),
            visibility: text(member, "visibility"),
        })
        .collect()
}
