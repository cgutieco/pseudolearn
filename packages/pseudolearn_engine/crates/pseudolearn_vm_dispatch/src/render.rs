#![forbid(unsafe_code)]

use crate::forms::{Rendered, Selection};

pub(crate) fn render_dispatch(rendered: &Rendered) -> String {
    let text = dispatch_text(rendered);
    format!(
        "#[derive(Clone, Copy, Debug, PartialEq)]\npub(crate) enum Op {{ {ordinary_variants} Task(TaskOp) }}\n\n#[derive(Clone, Copy, Debug, PartialEq)]\npub(crate) enum CompactOp {{ {ordinary_variants} }}\n\n#[derive(Clone, Copy, Debug, PartialEq)]\npub(crate) enum TaskOp {{ {task_variants} }}\n\npub(crate) fn compact_operation(operation: Op, task_operations: &mut Vec<TaskOp>) -> Result<(CompactOp, Option<u32>), Fault> {{ match operation {{ {compact_conversions} Op::Task(task) => {{ let index = u32::try_from(task_operations.len()).map_err(|_| crate::evaluate::INVALID_BYTECODE)?; if index == u32::MAX {{ return Err(crate::evaluate::INVALID_BYTECODE); }} task_operations.push(task); Ok((CompactOp::Unreachable, Some(index))) }}, }} }}\n\n#[inline(always)]\npub(crate) fn step<const TASK_RUNTIME: bool>(machine: &mut Machine<'_>, position: usize, probed: bool, operation: CompactOp) -> Result<Flow, Fault> {{ if TASK_RUNTIME && let Some(task) = machine.current.task_operation(position, probed) {{ return step_task(machine, task); }} match operation {{ {compact_arms} }} }}\n\nfn step_task(machine: &mut Machine<'_>, operation: TaskOp) -> Result<Flow, Fault> {{ match operation {{ {task_arms} }} }}\n\npub(crate) fn select_operation(opcode: pseudolearn_bytecode::Opcode, predicate: Option<&str>, destination: u16, sources: &[Source]) -> Option<Op> {{ match (opcode, predicate, sources) {{ {selections} _ => None, }} }}\n\npub(crate) fn select_fused(opcode: pseudolearn_bytecode::Opcode, predicate: Option<&str>, destination: u16, sources: &[Source], (then_edge, else_edge): (u32, u32)) -> Option<Op> {{ match (opcode, predicate, sources) {{ {fused} _ => None, }} }}\n",
        ordinary_variants = text.ordinary_variants,
        task_variants = text.task_variants,
        compact_conversions = text.compact_conversions,
        compact_arms = text.compact_arms,
        task_arms = text.task_arms,
        selections = text.selections,
        fused = text.fused,
    )
}

struct DispatchText {
    ordinary_variants: String,
    task_variants: String,
    compact_arms: String,
    compact_conversions: String,
    task_arms: String,
    selections: String,
    fused: String,
}

fn dispatch_text(rendered: &Rendered) -> DispatchText {
    DispatchText {
        ordinary_variants: render_variants(rendered, false),
        task_variants: render_variants(rendered, true),
        compact_arms: render_compact_arms(rendered),
        compact_conversions: render_compact_conversions(rendered),
        task_arms: render_task_arms(rendered),
        selections: render_selections(&rendered.selections),
        fused: render_selections(&rendered.fused_selections),
    }
}

fn render_variants(rendered: &Rendered, task: bool) -> String {
    rendered
        .variants
        .iter()
        .filter(|variant| variant.task == task)
        .map(|variant| {
            let name = variant.name.strip_prefix("Task").unwrap_or(&variant.name);
            format!("{}{},", name, field_list(&variant.fields, true))
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn render_compact_arms(rendered: &Rendered) -> String {
    rendered
        .variants
        .iter()
        .filter(|variant| !variant.task)
        .map(|variant| {
            format!(
                "CompactOp::{}{} => {},",
                variant.name,
                field_list(&variant.fields, false),
                variant.arm
            )
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn render_compact_conversions(rendered: &Rendered) -> String {
    rendered
        .variants
        .iter()
        .filter(|variant| !variant.task)
        .map(|variant| {
            let fields = field_list(&variant.fields, false);
            format!(
                "Op::{}{fields} => Ok((CompactOp::{}{fields}, None)),",
                variant.name, variant.name
            )
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn render_task_arms(rendered: &Rendered) -> String {
    rendered
        .variants
        .iter()
        .filter(|variant| variant.task)
        .map(|variant| {
            let name = variant.name.strip_prefix("Task").unwrap_or(&variant.name);
            format!(
                "TaskOp::{}{} => {},",
                name,
                field_list(&variant.fields, false),
                variant.arm
            )
        })
        .collect::<Vec<_>>()
        .join(" ")
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
