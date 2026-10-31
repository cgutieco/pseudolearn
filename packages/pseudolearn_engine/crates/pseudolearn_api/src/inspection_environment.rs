use super::inspection_types::{class_environment, semantic_type};
use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_bytecode::{RegisterClass, ValueType};
use pseudolearn_semantic::inspection_expression::InspectionEnvironment;
use pseudolearn_timeline::VariableValue;
use pseudolearn_vm::{Machine, RuntimeValue};

pub(super) struct InspectionCaptures {
    pub environment: InspectionEnvironment,
    pub values: Vec<RuntimeValue>,
    pub texts: Vec<(usize, String)>,
}

pub(super) fn capture(machine: &Machine<'_>, frame: usize) -> Result<InspectionCaptures, ApiError> {
    let module = class_environment(pseudolearn_vm::machine_program(machine))?;
    let inspection = machine
        .active_frame(frame)
        .ok_or_else(|| usage("invalid inspection frame"))?;
    let view = pseudolearn_timeline::capture_frame(machine, frame)
        .map_err(|error| usage(&error.to_string()))?;
    let mut captures = InspectionCaptures {
        environment: InspectionEnvironment {
            module,
            bindings: Vec::new(),
        },
        values: Vec::new(),
        texts: Vec::new(),
    };
    for variable in view.variables {
        if matches!(variable.value, VariableValue::Undefined) {
            continue;
        }
        let kind = variable_type(&inspection, &variable.name)?;
        let type_id = semantic_type(kind, &mut captures.environment.module)?;
        let value = capture_value(variable.value, &mut captures)?;
        captures.environment.bindings.push((variable.name, type_id));
        captures.values.push(value);
    }
    Ok(captures)
}

fn capture_value(
    value: VariableValue,
    captures: &mut InspectionCaptures,
) -> Result<RuntimeValue, ApiError> {
    Ok(match value {
        VariableValue::Integer(number) => {
            RuntimeValue::Scalar(u64::from_ne_bytes(number.to_ne_bytes()))
        }
        VariableValue::Real(number) => RuntimeValue::Scalar(number.to_bits()),
        VariableValue::Boolean(value) => RuntimeValue::Scalar(u64::from(value)),
        VariableValue::Character(value) => RuntimeValue::Scalar(u64::from(u32::from(value))),
        VariableValue::Text(text) => {
            captures.texts.push((captures.values.len(), text));
            RuntimeValue::Reference(0)
        }
        VariableValue::ArrayReference { handle_word, .. }
        | VariableValue::ObjectReference { handle_word, .. } => {
            RuntimeValue::Reference(handle_word)
        }
        VariableValue::NullReference => RuntimeValue::Reference(0),
        VariableValue::Undefined => return Err(usage("uninitialized inspection capture")),
    })
}

pub(super) fn result_type(kind: &ValueType) -> &'static str {
    match kind {
        ValueType::I64 => "integer",
        ValueType::F64 => "real",
        ValueType::Bool => "boolean",
        ValueType::Char => "character",
        ValueType::Str => "string",
        ValueType::Array { .. } => "array",
        ValueType::Object(name) if name.starts_with("$vector<") => "vector",
        ValueType::Object(name) if name.starts_with("$dictionary<") => "dictionary",
        ValueType::Object(_) => "object",
        _ => "unit",
    }
}

fn variable_type<'program>(
    inspection: &'program pseudolearn_vm::ActiveFrameInspection<'_>,
    name: &str,
) -> Result<&'program ValueType, ApiError> {
    inspection
        .names
        .iter()
        .find(|entry| entry.1 == name)
        .and_then(|(register, _)| match register.class {
            RegisterClass::Scalar => inspection.scalar_types.get(usize::from(register.index)),
            RegisterClass::Reference => inspection.reference_types.get(usize::from(register.index)),
        })
        .ok_or_else(|| usage("missing inspection variable type"))
}
