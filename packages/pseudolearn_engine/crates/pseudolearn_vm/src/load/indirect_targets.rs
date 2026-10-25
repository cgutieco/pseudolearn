use pseudolearn_bytecode::{BytecodeFunction, BytecodeModule};

pub(crate) fn collect(module: &BytecodeModule, prototype: usize) -> Vec<Option<u16>> {
    let Some(prototype) = module.functions.get(prototype) else {
        return Vec::new();
    };
    module
        .functions
        .iter()
        .enumerate()
        .map(|(index, function)| {
            compatible(prototype, function)
                .then(|| u16::try_from(index).ok())
                .flatten()
        })
        .collect()
}

fn compatible(prototype: &BytecodeFunction, function: &BytecodeFunction) -> bool {
    prototype.result_type == function.result_type
        && prototype.parameters.len() == function.parameters.len()
        && prototype
            .parameters
            .iter()
            .zip(&function.parameters)
            .all(|(left, right)| prototype.register_type(*left) == function.register_type(*right))
}
