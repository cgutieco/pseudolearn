#![forbid(unsafe_code)]

use crate::identities::{InstructionId, ValueId};
use crate::operand::Operand;
use crate::operation::Operation;
use crate::span::IrSpan;
use crate::types::IrType;
use std::ops::Range;

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct InstructionDefinition {
    pub operation: Operation,
    pub result: Option<ValueId>,
    pub span: Option<IrSpan>,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct InstructionColumns {
    operations: Vec<Operation>,
    operands: Vec<Operand>,
    operand_ranges: Vec<Range<usize>>,
    results: Vec<Option<ValueId>>,
    spans: Vec<Option<IrSpan>>,
    value_types: Vec<Option<IrType>>,
}

impl InstructionColumns {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn push_instruction(
        &mut self,
        definition: InstructionDefinition,
        instruction_operands: &[Operand],
    ) -> InstructionId {
        let start_index = self.operands.len();
        self.operands.extend_from_slice(instruction_operands);
        let end_index = self.operands.len();

        let instruction_number = u32::try_from(self.operations.len()).unwrap_or(0);
        let identifier = InstructionId(instruction_number);
        self.operations.push(definition.operation);
        self.operand_ranges.push(start_index..end_index);
        self.results.push(definition.result);
        self.spans.push(definition.span);
        identifier
    }

    pub(crate) fn register_value_type(&mut self, value: ValueId, value_type: IrType) {
        let value_index = usize::try_from(value.0).unwrap_or(0);
        if value_index >= self.value_types.len() {
            let additional = (value_index.saturating_add(1)).saturating_sub(self.value_types.len());
            self.value_types
                .resize(self.value_types.len().saturating_add(additional), None);
        }
        if let Some(slot) = self.value_types.get_mut(value_index) {
            *slot = Some(value_type);
        }
    }

    pub fn operation(&self, identifier: InstructionId) -> Option<Operation> {
        let index = usize::try_from(identifier.0).ok()?;
        self.operations.get(index).copied()
    }

    pub fn operands(&self, identifier: InstructionId) -> &[Operand] {
        let index = match usize::try_from(identifier.0) {
            Ok(instruction_index) => instruction_index,
            Err(_) => return &[],
        };
        if let Some(range) = self.operand_ranges.get(index) {
            self.operands.get(range.clone()).unwrap_or(&[])
        } else {
            &[]
        }
    }

    pub fn result(&self, identifier: InstructionId) -> Option<ValueId> {
        let index = usize::try_from(identifier.0).ok()?;
        self.results.get(index).copied().flatten()
    }

    pub fn span(&self, identifier: InstructionId) -> Option<IrSpan> {
        let index = usize::try_from(identifier.0).ok()?;
        self.spans.get(index).copied().flatten()
    }

    pub fn value_type(&self, value: ValueId) -> Option<IrType> {
        let index = usize::try_from(value.0).ok()?;
        self.value_types.get(index).cloned().flatten()
    }
}

pub fn replace_operands(
    columns: &mut InstructionColumns,
    identifier: InstructionId,
    operands: &[Operand],
) {
    let Some(index) = usize::try_from(identifier.0).ok() else {
        return;
    };
    let start = columns.operands.len();
    columns.operands.extend_from_slice(operands);
    if let Some(range) = columns.operand_ranges.get_mut(index) {
        *range = start..columns.operands.len();
    }
}
