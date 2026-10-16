#![forbid(unsafe_code)]

use pseudolearn_ir::{
    Block, BlockId, InstructionColumns, InstructionDefinition, InstructionId, IrSpan, IrType,
    Operand, Operation, ValueId,
};

#[derive(Clone, Debug, PartialEq)]
pub struct FunctionBuilder {
    pub name: String,
    pub parameters: Vec<(ValueId, IrType)>,
    pub return_type: IrType,
    pub columns: InstructionColumns,
    pub blocks: Vec<Block>,
    pub current_block: Option<BlockId>,
    pub receiver: Option<ValueId>,
    next_value_index: u32,
    next_block_index: u32,
}

impl FunctionBuilder {
    pub fn new(name: String, return_type: IrType) -> Self {
        Self {
            name,
            parameters: Vec::new(),
            return_type,
            columns: InstructionColumns::new(),
            blocks: Vec::new(),
            current_block: None,
            receiver: None,
            next_value_index: 0,
            next_block_index: 0,
        }
    }

    pub fn next_value(&mut self) -> ValueId {
        let identifier = ValueId(self.next_value_index);
        self.next_value_index = self.next_value_index.saturating_add(1);
        identifier
    }

    pub fn create_block(&mut self) -> BlockId {
        let identifier = BlockId(self.next_block_index);
        self.next_block_index = self.next_block_index.saturating_add(1);
        self.blocks.push(Block {
            identifier,
            parameters: Vec::new(),
            mass: 0,
            instructions: Vec::new(),
        });
        identifier
    }

    pub fn set_current_block(&mut self, block_id: BlockId) {
        self.current_block = Some(block_id);
    }

    pub fn add_block_parameter(
        &mut self,
        block_id: BlockId,
        param_value: ValueId,
        param_type: IrType,
    ) {
        if let Some(block) = self
            .blocks
            .iter_mut()
            .find(|target| target.identifier == block_id)
        {
            block.parameters.push((param_value, param_type));
        }
    }

    fn emit_instruction(
        &mut self,
        definition: InstructionDefinition,
        operands: Vec<Operand>,
    ) -> InstructionId {
        let instruction_id = self.columns.push_instruction(definition, &operands);
        if let Some(current) = self.current_block
            && let Some(block) = self
                .blocks
                .iter_mut()
                .find(|target| target.identifier == current)
        {
            block.instructions.push(instruction_id);
        }
        instruction_id
    }

    pub fn emit_with_target(
        &mut self,
        operation: Operation,
        operands: Vec<Operand>,
        target: (Option<ValueId>, Option<IrSpan>),
    ) -> InstructionId {
        let (result, span) = target;
        self.emit_instruction(
            InstructionDefinition {
                operation,
                result,
                span,
            },
            operands,
        )
    }

    pub fn emit_void(
        &mut self,
        operation: Operation,
        operands: Vec<Operand>,
        span: Option<IrSpan>,
    ) -> InstructionId {
        self.emit_with_target(operation, operands, (None, span))
    }
}

pub fn is_current_block_terminated(builder: &FunctionBuilder) -> bool {
    let Some(current) = builder.current_block else {
        return false;
    };
    let Some(block) = builder
        .blocks
        .iter()
        .find(|target| target.identifier == current)
    else {
        return false;
    };
    let Some(&last_id) = block.instructions.last() else {
        return false;
    };
    builder
        .columns
        .operation(last_id)
        .is_some_and(|operation| operation.is_terminator())
}
