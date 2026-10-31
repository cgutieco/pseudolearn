use super::inspection_environment::result_type;
use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_bytecode::{Register, RegisterClass, ValueType};
use pseudolearn_runtime::{Handle, Heap};
use pseudolearn_vm::{Machine, RunExit, RunOptions, RuntimeValue};
use serde_json::{Value, json};

pub(super) type RecordFields = Vec<(String, ValueType)>;
type RegisteredRecordFields = Vec<(String, Register, ValueType)>;

pub(super) struct InspectionRun {
    pub program: pseudolearn_vm::LoadedProgram,
    pub parameters: Vec<Register>,
    pub result: ValueType,
    pub aggregate: Option<RegisteredRecordFields>,
}

pub(super) fn prepare(
    module: &pseudolearn_ir::Module,
    aggregate: Option<RecordFields>,
) -> Result<InspectionRun, ApiError> {
    let bytecode = pseudolearn_bytecode::compile_module(module)
        .map_err(|error| usage(&format!("{error:?}")))?;
    let function = bytecode
        .module()
        .functions
        .first()
        .ok_or_else(|| usage("missing inspection entry"))?;
    Ok(InspectionRun {
        program: pseudolearn_vm::load(&bytecode).map_err(|error| usage(&format!("{error:?}")))?,
        parameters: function.parameters.clone(),
        result: function.result_type.clone(),
        aggregate: result_registers(function, aggregate)?,
    })
}

pub(super) fn run(
    prepared: InspectionRun,
    heap: Heap,
    values: Vec<RuntimeValue>,
    options: RunOptions,
) -> Result<Value, ApiError> {
    let mut machine = pseudolearn_vm::create_machine(
        &prepared.program,
        pseudolearn_vm::Fuel {
            statements: 4096,
            probes: 65536,
        },
        options,
    )
    .map_err(|error| usage(&format!("{error:?}")))?;
    inject(&mut machine, &prepared.parameters, &values)?;
    *machine.heap_mut() = heap;
    for _ in 0..65536 {
        match machine.step_instruction() {
            None | Some(RunExit::Service(_)) => (),
            Some(RunExit::Completed(None)) if prepared.aggregate.is_some() => {
                return render_aggregate(&machine, prepared.aggregate.as_deref().unwrap_or(&[]));
            }
            Some(RunExit::Completed(Some(value))) => {
                return render(&machine, &prepared.result, value);
            }
            Some(RunExit::Trap(error)) => return Err(usage(&format!("{error:?}"))),
            Some(_) => return Err(usage("inspection exceeded its execution budget")),
        }
    }
    Err(usage("inspection instruction limit exceeded"))
}

fn inject(
    machine: &mut Machine<'_>,
    parameters: &[Register],
    values: &[RuntimeValue],
) -> Result<(), ApiError> {
    if parameters.len() != values.len() {
        return Err(usage("invalid inspection capture count"));
    }
    let mut state = machine.capture_machine_state();
    for (parameter, value) in parameters.iter().zip(values) {
        let slot = usize::from(parameter.index);
        match (parameter.class, value) {
            (RegisterClass::Scalar, RuntimeValue::Scalar(word)) => {
                *state
                    .scalars
                    .get_mut(slot)
                    .ok_or_else(|| usage("invalid inspection scalar"))? = *word;
                *state
                    .defined
                    .get_mut(slot)
                    .ok_or_else(|| usage("invalid inspection defined value"))? = true;
            }
            (RegisterClass::Reference, RuntimeValue::Reference(word)) => {
                *state
                    .references
                    .get_mut(slot)
                    .ok_or_else(|| usage("invalid inspection reference"))? = *word;
            }
            _ => return Err(usage("inspection capture type mismatch")),
        }
    }
    machine.restore_machine_state(&state);
    Ok(())
}

fn render(machine: &Machine<'_>, kind: &ValueType, value: RuntimeValue) -> Result<Value, ApiError> {
    let rendered = match (kind, value) {
        (ValueType::I64, RuntimeValue::Scalar(word)) => {
            i64::from_ne_bytes(word.to_ne_bytes()).to_string()
        }
        (ValueType::F64, RuntimeValue::Scalar(word)) => {
            pseudolearn_timeline::format_real(f64::from_bits(word))
        }
        (ValueType::Bool, RuntimeValue::Scalar(word)) => (word != 0).to_string(),
        (ValueType::Char, RuntimeValue::Scalar(word)) => {
            char::from_u32(u32::try_from(word).map_err(|_| usage("invalid inspection character"))?)
                .ok_or_else(|| usage("invalid inspection character"))?
                .to_string()
        }
        (ValueType::Str, RuntimeValue::Reference(word)) => {
            pseudolearn_runtime::text_content(machine.heap(), Handle(word))
                .map_err(|error| usage(&format!("{error:?}")))?
                .to_owned()
        }
        (_, RuntimeValue::Reference(0)) => "null".to_owned(),
        (_, RuntimeValue::Reference(word)) => {
            let ordinal = pseudolearn_runtime::allocation_ordinal(machine.heap(), Handle(word))
                .map_err(|error| usage(&format!("{error:?}")))?;
            return Ok(
                json!({"type":result_type(kind),"value":format!("{}({ordinal})",result_type(kind)),"reference":ordinal}),
            );
        }
        _ => return Err(usage("invalid inspection result")),
    };
    Ok(json!({"type":result_type(kind),"value":rendered}))
}

fn result_registers(
    function: &pseudolearn_bytecode::BytecodeFunction,
    fields: Option<RecordFields>,
) -> Result<Option<RegisteredRecordFields>, ApiError> {
    fields
        .map(|fields| {
            fields
                .into_iter()
                .enumerate()
                .map(|(position, (name, kind))| {
                    let label = format!("inspection_result_{position}");
                    let register = function
                        .names
                        .iter()
                        .find(|entry| entry.1 == &label)
                        .map(|entry| *entry.0)
                        .ok_or_else(|| usage("missing inspection result register"))?;
                    Ok((name, register, kind))
                })
                .collect()
        })
        .transpose()
}

fn render_aggregate(
    machine: &Machine<'_>,
    fields: &[(String, Register, ValueType)],
) -> Result<Value, ApiError> {
    let mut rendered = serde_json::Map::new();
    for (name, register, kind) in fields {
        let slot = usize::from(register.index);
        let value = match register.class {
            RegisterClass::Scalar => {
                pseudolearn_vm::machine_scalar(machine, slot).map(RuntimeValue::Scalar)
            }
            RegisterClass::Reference => {
                pseudolearn_vm::machine_reference(machine, slot).map(RuntimeValue::Reference)
            }
        }
        .ok_or_else(|| usage("invalid inspection result register"))?;
        let result = render(machine, kind, value)?;
        rendered.insert(
            name.clone(),
            result
                .get("value")
                .cloned()
                .ok_or_else(|| usage("missing inspection rendered value"))?,
        );
    }
    Ok(json!({"type":"record","value":Value::Object(rendered).to_string()}))
}
