#![forbid(unsafe_code)]

use crate::forms::{Rendered, Selection};

pub(crate) fn render_dispatch(rendered: &Rendered) -> String {
    let variants = rendered
        .variants
        .iter()
        .map(|variant| format!("{}{},", variant.name, field_list(&variant.fields, true)))
        .collect::<Vec<_>>()
        .join(" ");
    let arms = rendered
        .variants
        .iter()
        .map(|variant| {
            format!(
                "Op::{}{} => {},",
                variant.name,
                field_list(&variant.fields, false),
                variant.arm
            )
        })
        .collect::<Vec<_>>()
        .join(" ");
    let selections = render_selections(&rendered.selections);
    let fused = render_selections(&rendered.fused_selections);
    format!(
        "#[derive(Clone, Copy, Debug, PartialEq)]\npub(crate) enum Op {{ {variants} }}\n\n#[inline(always)]\npub(crate) fn step(machine: &mut Machine<'_>, operation: Op) -> Result<Flow, Fault> {{ match operation {{ {arms} }} }}\n\npub(crate) fn select_operation(opcode: pseudolearn_bytecode::Opcode, predicate: Option<&str>, destination: u16, sources: &[Source]) -> Option<Op> {{ match (opcode, predicate, sources) {{ {selections} _ => None, }} }}\n\npub(crate) fn select_fused(opcode: pseudolearn_bytecode::Opcode, predicate: Option<&str>, destination: u16, sources: &[Source], (then_edge, else_edge): (u32, u32)) -> Option<Op> {{ match (opcode, predicate, sources) {{ {fused} _ => None, }} }}\n"
    )
}

fn render_selections(selections: &[Selection]) -> String {
    selections
        .iter()
        .map(|(pattern, construction)| format!("{pattern} => {construction},"))
        .collect::<Vec<_>>()
        .join(" ")
}

fn field_list(fields: &[(String, String)], typed: bool) -> String {
    if fields.is_empty() {
        return String::new();
    }
    let entries = fields
        .iter()
        .map(|(name, kind)| {
            if typed {
                format!("{name}: {kind}")
            } else {
                name.clone()
            }
        })
        .collect::<Vec<_>>()
        .join(", ");
    format!(" {{ {entries} }}")
}
