#![forbid(unsafe_code)]

use crate::catalog::pascal_case;
use crate::{GenerationResult, array_field, text_field};

pub(crate) struct Variant {
    pub name: String,
    pub fields: Vec<(String, String)>,
    pub arm: String,
    pub task: bool,
}

pub(crate) type Selection = (String, String);

#[derive(Default)]
pub(crate) struct Rendered {
    pub variants: Vec<Variant>,
    pub selections: Vec<Selection>,
    pub fused_selections: Vec<Selection>,
}

struct OperandSlot {
    name: String,
    register: bool,
}

struct OperationRow<'row> {
    form: &'row str,
    opcode: String,
    evaluate: &'row str,
    predicate: String,
    fusable: bool,
}

fn operand_shapes(
    shapes: &serde_json::Value,
    arity: u64,
) -> GenerationResult<Vec<(String, Vec<OperandSlot>)>> {
    let mut expanded = Vec::new();
    for shape in array_field(shapes, &arity.to_string())? {
        let mut slots = Vec::new();
        for entry in array_field(shape, "slots")? {
            let register = entry.get("register").and_then(serde_json::Value::as_bool);
            slots.push(OperandSlot {
                name: text_field(entry, "name")?.to_owned(),
                register: register.ok_or("Missing register flag")?,
            });
        }
        expanded.push((text_field(shape, "suffix")?.to_owned(), slots));
    }
    Ok(expanded)
}

fn operation_row(operation: &serde_json::Value) -> GenerationResult<OperationRow<'_>> {
    let predicate = match operation
        .get("predicate")
        .and_then(serde_json::Value::as_str)
    {
        Some(value) => format!("Some(\"{value}\")"),
        None => "None".to_owned(),
    };
    Ok(OperationRow {
        form: text_field(operation, "form")?,
        opcode: pascal_case(text_field(operation, "opcode")?),
        evaluate: text_field(operation, "evaluate")?,
        predicate,
        fusable: operation
            .get("fusable")
            .and_then(serde_json::Value::as_bool)
            == Some(true),
    })
}

pub(crate) fn expand_operation(
    operation: &serde_json::Value,
    shapes: &serde_json::Value,
    rendered: &mut Rendered,
) -> GenerationResult<()> {
    let row = operation_row(operation)?;
    let arity = operation
        .get("arity")
        .and_then(serde_json::Value::as_u64)
        .ok_or("Missing arity")?;
    for (suffix, slots) in operand_shapes(shapes, arity)? {
        expand_shape(&row, (&suffix, &slots), rendered);
    }
    Ok(())
}

fn expand_shape(
    row: &OperationRow<'_>,
    (suffix, slots): (&str, &[OperandSlot]),
    rendered: &mut Rendered,
) {
    let pattern = selection_pattern(&row.opcode, &row.predicate, slots);
    let evaluation = evaluation_text(row.evaluate, slots);
    let fields = shape_fields(slots);
    let name = format!("{}{suffix}", row.form);
    push_selection(&mut rendered.selections, &pattern, &name, &fields);
    rendered.variants.push(Variant {
        name,
        fields: fields.clone(),
        arm: format!("{{ {evaluation} Ok(Flow::Continue) }}"),
        task: false,
    });
    if row.fusable {
        let fused_name = format!("{}Branch{suffix}", row.form);
        let mut fused_fields = fields;
        fused_fields.push(("then_edge".to_owned(), "u32".to_owned()));
        fused_fields.push(("else_edge".to_owned(), "u32".to_owned()));
        push_selection(
            &mut rendered.fused_selections,
            &pattern,
            &fused_name,
            &fused_fields,
        );
        rendered.variants.push(Variant {
            name: fused_name,
            fields: fused_fields,
            arm: format!(
                "{{ {evaluation} machine.branch_on::<TASK_RUNTIME>(value, then_edge, else_edge) }}"
            ),
            task: false,
        });
    }
}

fn evaluation_text(evaluate: &str, slots: &[OperandSlot]) -> String {
    let reads = slots
        .iter()
        .map(read_expression)
        .collect::<Vec<_>>()
        .join(", ");
    format!(
        "let value = crate::evaluate::{evaluate}({reads})?; machine.set_scalar(destination, value)?;"
    )
}

fn shape_fields(slots: &[OperandSlot]) -> Vec<(String, String)> {
    let mut fields = vec![("destination".to_owned(), "u16".to_owned())];
    fields.extend(slots.iter().map(|entry| {
        let kind = if entry.register { "u16" } else { "u64" };
        (entry.name.clone(), kind.to_owned())
    }));
    fields
}

fn read_expression(entry: &OperandSlot) -> String {
    if entry.register {
        format!("machine.scalar({})?", entry.name)
    } else {
        entry.name.clone()
    }
}

fn selection_pattern(opcode: &str, predicate: &str, slots: &[OperandSlot]) -> String {
    let slots = slots
        .iter()
        .map(|entry| {
            let kind = if entry.register {
                "Register"
            } else {
                "Immediate"
            };
            format!("Source::{kind}({})", entry.name)
        })
        .collect::<Vec<_>>()
        .join(", ");
    format!("(pseudolearn_bytecode::Opcode::{opcode}, {predicate}, [{slots}])")
}

fn push_selection(
    selections: &mut Vec<Selection>,
    pattern: &str,
    name: &str,
    fields: &[(String, String)],
) {
    let assignments = fields
        .iter()
        .map(|(field, _)| match field.as_str() {
            "left" | "right" | "source" => format!("{field}: *{field}"),
            _ => field.clone(),
        })
        .collect::<Vec<_>>()
        .join(", ");
    selections.push((
        pattern.to_owned(),
        format!("Some(Op::{name} {{ {assignments} }})"),
    ));
}

pub(crate) fn special_variant(special: &serde_json::Value) -> GenerationResult<Variant> {
    let name = text_field(special, "form")?.to_owned();
    let handler = text_field(special, "handler")?;
    let mut fields = Vec::new();
    for field in array_field(special, "fields")? {
        fields.push((
            text_field(field, "name")?.to_owned(),
            text_field(field, "type")?.to_owned(),
        ));
    }
    let arguments = fields
        .iter()
        .map(|(field, _)| field.as_str())
        .collect::<Vec<_>>()
        .join(", ");
    let task_runtime_generic = matches!(
        handler,
        "jump"
            | "branch"
            | "call"
            | "switch"
            | "return_scalar"
            | "return_reference"
            | "return_unit"
    );
    let handler_call = if task_runtime_generic {
        format!("machine.{handler}::<TASK_RUNTIME>({arguments})")
    } else {
        format!("machine.{handler}({arguments})")
    };
    Ok(Variant {
        task: name.starts_with("Task"),
        name,
        fields,
        arm: handler_call,
    })
}
