use super::ExecutionResource;
use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_runtime::{Handle, Heap};
use pseudolearn_vm::{RunOptions, RuntimeValue};
use serde_json::Value;

#[path = "inspection_environment.rs"]
mod inspection_environment;
#[path = "inspection_execution.rs"]
mod inspection_execution;
#[path = "inspection_types.rs"]
mod inspection_types;

struct CompiledInspection {
    module: pseudolearn_ir::Module,
    texts: Vec<String>,
    aggregate: Option<inspection_execution::RecordFields>,
}

struct InspectionRequest<'text> {
    text: &'text str,
    event: usize,
    frame: usize,
    task: Option<u64>,
}

impl ExecutionResource {
    pub(crate) fn inspect_expression(&self, arguments: &Value) -> Result<Value, ApiError> {
        let request = parse_request(arguments)?;
        let machine = self.inspection_machine(request.event, request.task)?;
        let captures = inspection_environment::capture(&machine, request.frame)?;
        let compiled = compile_expression(
            request.text,
            self.inspection_profile(),
            captures.environment,
        )?;
        let prepared = inspection_execution::prepare(&compiled.module, compiled.aggregate)?;
        let options = inspection_options(self.inspection_options());
        let mut heap =
            pseudolearn_runtime::clone_heap_bounded(machine.heap(), options.memory.cells)
                .map_err(|error| usage(&format!("{error:?}")))?;
        let values = materialize_text(&mut heap, captures.values, captures.texts, compiled.texts)?;
        inspection_execution::run(prepared, heap, values, options)
    }
}

fn parse_request(arguments: &Value) -> Result<InspectionRequest<'_>, ApiError> {
    let text = arguments
        .get("expression")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing inspection expression"))?;
    if text.len() > 8192 {
        return Err(usage("inspection expression exceeds byte limit"));
    }
    let task = arguments
        .get("task_id")
        .map(|value| {
            value
                .as_u64()
                .ok_or_else(|| usage("invalid inspection task"))
        })
        .transpose()?;
    Ok(InspectionRequest {
        text,
        event: index(arguments, "event")?,
        frame: index(arguments, "frame")?,
        task,
    })
}

fn compile_expression(
    text: &str,
    profile: pseudolearn_lexicon::Profile,
    environment: pseudolearn_semantic::inspection_expression::InspectionEnvironment,
) -> Result<CompiledInspection, ApiError> {
    let source = pseudolearn_source::SourceText::new(text.to_owned());
    let (tree, diagnostics) =
        pseudolearn_syntax::expression_entry::parse_expression_source(&source, profile);
    if !diagnostics.is_empty() {
        return Err(usage("invalid inspection expression syntax"));
    }
    let inspection = pseudolearn_semantic::inspection_expression::check_inspection(
        &tree,
        &source,
        environment,
        profile,
    )
    .map_err(|_| usage("inspection expression is not admitted or well typed"))?;
    let module = pseudolearn_lowering::inspection_lowering::lower_inspection(&inspection, &source)
        .map_err(|error| usage(&error.description))?;
    let aggregate = aggregate_fields(&inspection)?;
    Ok(CompiledInspection {
        module,
        texts: inspection.text_captures,
        aggregate,
    })
}

fn index(arguments: &Value, name: &str) -> Result<usize, ApiError> {
    arguments
        .get(name)
        .and_then(Value::as_u64)
        .and_then(|value| usize::try_from(value).ok())
        .ok_or_else(|| usage("invalid inspection index"))
}

fn inspection_options(mut options: RunOptions) -> RunOptions {
    options.depth = options.depth.min(64);
    options.memory.cells = options.memory.cells.min(65536);
    options.statement_limit = Some(options.statement_limit.unwrap_or(4096).min(4096));
    options.inputs.clear();
    options.cancelled = None;
    options.cancel_at_statement = None;
    options.cancel_at_poll = None;
    options.twin_mode = pseudolearn_vm::TwinMode::Fast;
    options
}

fn materialize_text(
    heap: &mut Heap,
    mut values: Vec<RuntimeValue>,
    texts: Vec<(usize, String)>,
    literals: Vec<String>,
) -> Result<Vec<RuntimeValue>, ApiError> {
    let mut roots: Vec<_> = values
        .iter()
        .filter_map(|value| match value {
            RuntimeValue::Reference(handle) if *handle != 0 => Some(Handle(*handle)),
            _ => None,
        })
        .collect();
    for (index, text) in texts {
        let handle = text_capture(heap, &text, &mut roots)?;
        *values
            .get_mut(index)
            .ok_or_else(|| usage("invalid inspection text capture"))? =
            RuntimeValue::Reference(handle.0);
    }
    for text in literals {
        let handle = text_capture(heap, &text, &mut roots)?;
        values.push(RuntimeValue::Reference(handle.0));
    }
    Ok(values)
}

fn aggregate_fields(
    inspection: &pseudolearn_semantic::inspection_expression::InspectionExpression,
) -> Result<Option<inspection_execution::RecordFields>, ApiError> {
    let slot = usize::try_from(inspection.expression.0)
        .map_err(|_| usage("invalid inspection expression"))?;
    let kind = inspection
        .module
        .expressions
        .types
        .get(slot)
        .copied()
        .ok_or_else(|| usage("missing inspection result type"))?;
    let pseudolearn_semantic::Type::Record(record) = inspection.module.types.representation(kind)
    else {
        return Ok(None);
    };
    let model = inspection
        .module
        .records
        .get(usize::try_from(record.0).map_err(|_| usage("invalid inspection record"))?)
        .ok_or_else(|| usage("missing inspection record"))?;
    Ok(Some(
        model
            .leaf_names
            .iter()
            .zip(&model.leaf_types)
            .map(|(name, kind)| {
                (
                    name.clone(),
                    pseudolearn_lowering::types::lower_type(*kind, &inspection.module),
                )
            })
            .collect(),
    ))
}

fn text_capture(heap: &mut Heap, text: &str, roots: &mut Vec<Handle>) -> Result<Handle, ApiError> {
    let handle = pseudolearn_runtime::new_text(heap, text, false, roots)
        .map_err(|error| usage(&format!("{error:?}")))?;
    roots.push(handle);
    Ok(handle)
}
