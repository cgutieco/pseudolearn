#![forbid(unsafe_code)]

use pseudolearn_bytecode::{
    BytecodeFunction, BytecodeOperand, Instruction, Opcode, Register, RegisterClass, ValueType,
};

use super::Definition;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(super) enum StaticState {
    Defined,
    Undefined,
    Dynamic,
}

pub(super) struct Definedness {
    states: Vec<StaticState>,
    tracked: Vec<bool>,
    integers: Vec<bool>,
}

impl Definedness {
    pub(super) fn analyze(function: &BytecodeFunction) -> Self {
        let count = function.scalar_types.len();
        let mut analysis = Self {
            states: vec![StaticState::Defined; count],
            tracked: vec![false; count],
            integers: function
                .scalar_types
                .iter()
                .map(|value_type| *value_type == ValueType::I64)
                .collect(),
        };
        analysis.mark_states(function);
        analysis.seed_queries(function);
        analysis.propagate(function);
        analysis
    }

    pub(super) fn state(&self, register: Register) -> StaticState {
        if register.class != RegisterClass::Scalar {
            return StaticState::Dynamic;
        }
        self.states
            .get(usize::from(register.index))
            .copied()
            .unwrap_or(StaticState::Dynamic)
    }

    pub(super) fn is_integer(&self, register: Register) -> bool {
        register.class == RegisterClass::Scalar
            && self.integers.get(usize::from(register.index)) == Some(&true)
    }

    pub(super) fn definition_into(
        &self,
        source: Register,
        destination_tracked: bool,
    ) -> Definition {
        if !destination_tracked {
            return Definition::Untracked;
        }
        match self.state(source) {
            StaticState::Defined => Definition::Defined,
            StaticState::Undefined => Definition::Undefined,
            StaticState::Dynamic => Definition::Copied,
        }
    }

    pub(super) fn is_tracked(&self, register: Register) -> bool {
        register.class == RegisterClass::Scalar
            && self.tracked.get(usize::from(register.index)) == Some(&true)
    }

    fn mark_states(&mut self, function: &BytecodeFunction) {
        let dynamic = function.parameters.iter().chain(
            function
                .fast
                .blocks
                .iter()
                .flat_map(|block| &block.parameters),
        );
        for register in dynamic.copied().collect::<Vec<_>>() {
            self.set_state(register, StaticState::Dynamic);
        }
        for instruction in &function.fast.instructions {
            if let (Opcode::ValueUndefined, Some(register)) =
                (instruction.opcode, instruction.destination)
            {
                self.set_state(register, StaticState::Undefined);
            }
        }
    }

    fn set_state(&mut self, register: Register, state: StaticState) {
        if register.class == RegisterClass::Scalar
            && let Some(slot) = self.states.get_mut(usize::from(register.index))
        {
            *slot = state;
        }
    }

    fn seed_queries(&mut self, function: &BytecodeFunction) {
        for instruction in &function.fast.instructions {
            for register in queried_registers(instruction) {
                self.track(register);
            }
        }
    }

    fn track(&mut self, register: Register) -> bool {
        if !self.is_integer(register) || self.state(register) != StaticState::Dynamic {
            return false;
        }
        match self.tracked.get_mut(usize::from(register.index)) {
            Some(slot) if !*slot => {
                *slot = true;
                true
            }
            _ => false,
        }
    }

    fn propagate(&mut self, function: &BytecodeFunction) {
        let copies = block_copies(function);
        let mut changed = true;
        while changed {
            changed = false;
            for (source, destination) in &copies {
                if self.is_tracked(*destination) && self.track(*source) {
                    changed = true;
                }
            }
        }
    }
}

fn queried_registers(instruction: &Instruction) -> Vec<Register> {
    match (instruction.opcode, instruction.operands.first()) {
        (Opcode::ValueRequire, Some(BytecodeOperand::Register(register))) => vec![*register],
        (Opcode::Call, Some(BytecodeOperand::FunctionTarget { arguments, .. })) => {
            arguments.clone()
        }
        _ => Vec::new(),
    }
}

fn block_copies(function: &BytecodeFunction) -> Vec<(Register, Register)> {
    let mut copies = Vec::new();
    for instruction in &function.fast.instructions {
        for operand in &instruction.operands {
            let BytecodeOperand::BlockTarget { target, arguments } = operand else {
                continue;
            };
            let Some(block) = function
                .fast
                .blocks
                .iter()
                .find(|block| block.identifier == *target)
            else {
                continue;
            };
            copies.extend(
                arguments
                    .iter()
                    .copied()
                    .zip(block.parameters.iter().copied()),
            );
        }
    }
    copies
}
