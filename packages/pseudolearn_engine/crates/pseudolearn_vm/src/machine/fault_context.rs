use super::{Machine, cells::Cell};
use crate::{
    Fault, VmTrap,
    dispatch::CompactOp,
    load::memory::{MemoryOp, TypedSource},
};
use pseudolearn_bytecode::{Opcode, Register, RegisterClass};
use pseudolearn_diagnostics::DiagnosticArgument;
use pseudolearn_runtime::{self as runtime, Handle};
use std::collections::BTreeMap;

type Arguments = BTreeMap<&'static str, DiagnosticArgument>;

mod arrays;

impl Machine<'_> {
    pub(super) fn trap_context(&self, fault: Fault, position: usize) -> VmTrap {
        let mut trap = VmTrap::new(fault, self.current.span(position, self.probed));
        if fault == "taskDeadlock" {
            trap.related.extend(
                self.tasks
                    .blocked_locations(self.probed)
                    .into_iter()
                    .filter_map(|blocked| blocked.span),
            );
            return trap;
        }
        match fault {
            "cellLimitExceeded"
            | "recursionDepthExceeded"
            | "statementBudgetExhausted"
            | "taskLimitExceeded" => {
                self.limit_arguments(fault, &mut trap.arguments);
            }
            "subroutineEndedWithoutReturn" => {
                self.subroutine_arguments(&mut trap);
            }
            _ => self.operation_arguments(fault, position, &mut trap.arguments),
        }
        trap
    }

    fn limit_arguments(&self, fault: Fault, arguments: &mut Arguments) {
        match fault {
            "cellLimitExceeded" => {
                arguments.insert(
                    "limit",
                    DiagnosticArgument::Number(self.options.memory.cells.into()),
                );
            }
            "recursionDepthExceeded" => {
                arguments.insert(
                    "limit",
                    DiagnosticArgument::Number(
                        u64::try_from(self.options.depth).unwrap_or(u64::MAX).into(),
                    ),
                );
            }
            "taskLimitExceeded" => {
                arguments.insert(
                    "limit",
                    DiagnosticArgument::Number(self.options.task_limit.into()),
                );
            }
            "statementBudgetExhausted" => {
                if let Some(limit) = self.options.statement_limit {
                    arguments.insert("limit", DiagnosticArgument::Number(limit.into()));
                }
            }
            _ => {}
        }
    }

    fn subroutine_arguments(&self, trap: &mut VmTrap) {
        if let Some(header) = self.current.declaration_span {
            trap.related.push(header);
        }
        let name = self
            .current
            .name
            .trim_start_matches('@')
            .rsplit('.')
            .next()
            .unwrap_or("");
        trap.arguments
            .insert("lexeme", DiagnosticArgument::Lexeme(name.to_owned()));
    }

    fn operation_arguments(&self, fault: Fault, position: usize, arguments: &mut Arguments) {
        match self.current.operation(position, self.probed) {
            CompactOp::ArrayRead1D { array, index, .. }
            | CompactOp::ArrayWrite1D { array, index, .. } => {
                self.array_arguments(fault, (array, std::slice::from_ref(&index)), arguments)
            }
            CompactOp::ObjectRead {
                receiver, offset, ..
            } if fault == "uninitializedVariableRead" => {
                self.object_field_name(receiver, offset, arguments);
            }
            CompactOp::Memory { site } => {
                if let Some(operation) = usize::try_from(site)
                    .ok()
                    .and_then(|site| self.current.memory.get(site))
                {
                    self.memory_arguments(fault, operation, arguments);
                }
            }
            CompactOp::CharFromCodeRegister { source, .. } => {
                if let Ok(word) = self.scalar(source) {
                    number(arguments, "code", crate::evaluate::integer_of(word));
                }
            }
            CompactOp::CharFromCodeImmediate { source, .. } => {
                number(arguments, "code", crate::evaluate::integer_of(source))
            }
            CompactOp::RequireFailed { source }
            | CompactOp::RequireDefinedInteger { source, .. }
            | CompactOp::RequireSentinel { source, .. } => {
                self.variable_argument(source, RegisterClass::Scalar, arguments)
            }
            CompactOp::RequireReference { source, .. } => {
                self.variable_argument(source, RegisterClass::Reference, arguments)
            }
            _ => {}
        }
    }

    fn memory_arguments(&self, fault: Fault, operation: &MemoryOp, arguments: &mut Arguments) {
        match operation {
            MemoryOp::Collection(operation) => {
                self.collection_arguments(fault, operation, arguments)
            }
            MemoryOp::ArrayRead { array, indices, .. }
            | MemoryOp::ArrayWrite { array, indices, .. }
            | MemoryOp::CellElement { array, indices, .. } => {
                self.array_arguments(fault, (*array, indices), arguments)
            }
            MemoryOp::ArrayNew { dimensions, .. } => {
                self.array_creation_arguments(dimensions, arguments)
            }
            MemoryOp::Text {
                opcode, sources, ..
            } => self.text_arguments(*opcode, sources, arguments),
            MemoryOp::CellLoad { cell, .. } => {
                let name = self
                    .current
                    .names
                    .get(&Register {
                        class: RegisterClass::Reference,
                        index: *cell,
                    })
                    .cloned()
                    .or_else(|| self.cell(*cell).ok().and_then(|cell| self.cell_name(cell)))
                    .unwrap_or_default();
                arguments.insert("lexeme", DiagnosticArgument::Lexeme(name));
            }
            _ => {}
        }
    }

    fn object_field_name(&self, receiver: u16, offset: usize, arguments: &mut Arguments) {
        let field_name = self
            .reference(receiver)
            .ok()
            .map(Handle)
            .and_then(|handle| runtime::object_class(&self.heap, handle).ok())
            .and_then(|class| usize::try_from(class).ok())
            .and_then(|class| self.program.inner.classes.get(class))
            .and_then(|class| class.fields.get(offset))
            .map(|(name, _)| name.clone());
        if let Some(name) = field_name {
            arguments.insert("lexeme", DiagnosticArgument::Lexeme(name));
        }
    }

    fn text_arguments(&self, opcode: Opcode, sources: &[TypedSource], arguments: &mut Arguments) {
        let first = sources
            .first()
            .and_then(|source| self.read_value(source.source).ok())
            .and_then(|word| u32::try_from(word).ok())
            .map(Handle);
        let Some(first) = first else {
            return;
        };
        match opcode {
            Opcode::TextToInteger | Opcode::TextToReal => {
                if let Ok(text) = runtime::text_content(&self.heap, first) {
                    arguments.insert("lexeme", DiagnosticArgument::Lexeme(text.to_owned()));
                }
            }
            Opcode::TextCharAt => {
                if let Ok(length) = runtime::text_length(&self.heap, first) {
                    arguments.insert("length", DiagnosticArgument::Number(length.into()));
                }
                if let Some(position) = sources
                    .get(1)
                    .and_then(|source| self.read_value(source.source).ok())
                {
                    number(arguments, "position", crate::evaluate::integer_of(position));
                }
            }
            _ => {}
        }
    }

    fn index_arguments(
        &self,
        array: u16,
        indices: &[crate::load::Source],
        arguments: &mut Arguments,
    ) {
        let dimensions = self
            .reference(array)
            .ok()
            .and_then(|handle| runtime::array_dimensions(&self.heap, Handle(handle)).ok());
        let (Some(dimensions), Ok(indices)) = (dimensions, self.read_indices(indices)) else {
            return;
        };
        for (index, size) in indices.iter().zip(dimensions) {
            if u64::try_from(*index).is_err()
                || u64::try_from(*index).is_ok_and(|index| index >= *size)
            {
                number(arguments, "index", *index);
                arguments.insert("size", DiagnosticArgument::Number((*size).into()));
                break;
            }
        }
    }

    fn variable_argument(&self, index: u16, class: RegisterClass, arguments: &mut Arguments) {
        if let Some(name) = self.current.names.get(&Register { class, index }) {
            arguments.insert("lexeme", DiagnosticArgument::Lexeme(name.clone()));
        }
    }

    fn cell_name(&self, cell: Cell) -> Option<String> {
        match cell {
            Cell::Managed(cell) => {
                let class = runtime::object_class(&self.heap, cell.owner).ok()?;
                self.program
                    .inner
                    .classes
                    .get(usize::try_from(class).ok()?)?
                    .fields
                    .get(cell.index)
                    .map(|(name, _)| name.clone())
            }
            Cell::Local { absolute, slot, .. } => self
                .local_cell_name(
                    self.current.as_ref(),
                    (self.cursor.scalar_base, self.cursor.reference_base),
                    (absolute, slot.class),
                )
                .or_else(|| {
                    self.frames.iter().rev().find_map(|frame| {
                        self.local_cell_name(
                            frame.function.as_ref(),
                            (frame.scalar_base, frame.reference_base),
                            (absolute, slot.class),
                        )
                    })
                }),
        }
    }

    fn local_cell_name(
        &self,
        function: &crate::load::LoadedFunction,
        (scalar_base, reference_base): (usize, usize),
        (absolute, class): (usize, RegisterClass),
    ) -> Option<String> {
        let base = if class == RegisterClass::Scalar {
            scalar_base
        } else {
            reference_base
        };
        let relative = u16::try_from(absolute.checked_sub(base)?).ok()?;
        function
            .memory
            .iter()
            .find_map(|operation| match operation {
                MemoryOp::CellLocal {
                    destination, slot, ..
                } if slot.class == class && slot.index == relative => function
                    .names
                    .get(&Register {
                        class: RegisterClass::Reference,
                        index: *destination,
                    })
                    .cloned(),
                _ => None,
            })
    }
}

fn number(arguments: &mut Arguments, name: &'static str, value: i64) {
    arguments.insert(name, DiagnosticArgument::Number(value.into()));
}
