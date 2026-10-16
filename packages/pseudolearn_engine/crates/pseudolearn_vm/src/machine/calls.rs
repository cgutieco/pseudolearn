#![forbid(unsafe_code)]

use pseudolearn_bytecode::{Register, RegisterClass};

use crate::evaluate::INVALID_BYTECODE;
use crate::events::{EventPayload, TraceClass, TraceEvent};
use crate::load::{CallSite, Definition, LoadedFunction, Move};
use crate::machine::{ControlFrame, Cursor, Flow, Machine};
use crate::{Fault, RuntimeValue};

const RESOURCE_LIMIT: Fault = "resourceLimit";

impl<'program> Machine<'program> {
    pub(crate) fn call(&mut self, site: u32) -> Result<Flow, Fault> {
        if self.frames.len().saturating_add(1) >= self.options.depth {
            return Err("recursionDepthExceeded");
        }
        let site = self
            .current
            .calls
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .copied()
            .ok_or(INVALID_BYTECODE)?;
        let callee = self.resolve_callee(&site)?;
        let caller = self.cursor;
        let callee_cursor = self.callee_cursor(callee)?;
        self.pass_arguments(&site, caller, callee_cursor)?;
        self.push_control_frame(&site, caller)?;
        if self.probed {
            self.record_call_event(&callee.name);
        }
        self.enter_callee(callee, callee_cursor);
        Ok(self.charge_entry(callee.entry_mass, 0))
    }

    fn push_control_frame(&mut self, site: &CallSite, caller: Cursor) -> Result<(), Fault> {
        self.frames.try_reserve(1).map_err(|_| RESOURCE_LIMIT)?;
        self.frames.push(ControlFrame {
            function: self.current,
            return_point: site.return_point,
            destination: site.destination,
            scalar_base: caller.scalar_base,
            reference_base: caller.reference_base,
            cell_count: self.cells.len(),
        });
        Ok(())
    }

    fn enter_callee(&mut self, callee: &'program LoadedFunction, callee_cursor: Cursor) {
        self.current = callee;
        let entry_target = if self.probed {
            callee.fast_to_probed_blocks.first().copied().unwrap_or(0)
        } else {
            0
        };
        self.cursor = Cursor {
            program_counter: entry_target,
            scalar_base: callee_cursor.scalar_base,
            reference_base: callee_cursor.reference_base,
        };
    }

    fn record_call_event(&mut self, callee_name: &str) {
        let line = self.current_line();
        let depth = self.current_depth();
        let name = callee_name.trim_start_matches('@').to_owned();
        self.events.push(TraceEvent {
            class: TraceClass::Call,
            line,
            depth,
            payload: Some(EventPayload::Call { nombre: name }),
        });
    }

    fn resolve_callee(&self, site: &CallSite) -> Result<&'program LoadedFunction, Fault> {
        let declared = self
            .program
            .functions
            .get(site.function)
            .ok_or(INVALID_BYTECODE)?;
        let Some(receiver) = site.receiver else {
            return Ok(declared);
        };
        let receiver = pseudolearn_runtime::Handle(self.reference(receiver)?);
        let class = pseudolearn_runtime::object_class(&self.heap, receiver)
            .map_err(super::memory::memory_fault)?;
        let class = self
            .program
            .classes
            .get(usize::try_from(class).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        let method = declared
            .name
            .rsplit_once('.')
            .map(|(_, name)| name)
            .ok_or(INVALID_BYTECODE)?;
        let target = class.methods.get(method).ok_or(INVALID_BYTECODE)?;
        self.program
            .functions
            .get(usize::from(*target))
            .ok_or(INVALID_BYTECODE)
    }

    fn callee_cursor(&mut self, callee: &LoadedFunction) -> Result<Cursor, Fault> {
        let cursor = Cursor {
            program_counter: 0,
            scalar_base: self
                .cursor
                .scalar_base
                .checked_add(
                    self.current
                        .scalar_window
                        .saturating_sub(self.current.scalar_outgoing),
                )
                .ok_or(RESOURCE_LIMIT)?,
            reference_base: self
                .cursor
                .reference_base
                .checked_add(
                    self.current
                        .reference_window
                        .saturating_sub(self.current.reference_outgoing),
                )
                .ok_or(RESOURCE_LIMIT)?,
        };
        self.ensure_capacity(
            cursor
                .scalar_base
                .checked_add(callee.scalar_window)
                .ok_or(RESOURCE_LIMIT)?,
            cursor
                .reference_base
                .checked_add(callee.reference_window)
                .ok_or(RESOURCE_LIMIT)?,
        )?;
        self.clear_window(cursor, callee)?;
        Ok(cursor)
    }

    fn clear_window(&mut self, cursor: Cursor, callee: &LoadedFunction) -> Result<(), Fault> {
        let reference_end = cursor
            .reference_base
            .checked_add(callee.reference_window)
            .ok_or(RESOURCE_LIMIT)?;
        self.references
            .get_mut(cursor.reference_base..reference_end)
            .ok_or(INVALID_BYTECODE)?
            .fill(0);
        let scalar_end = cursor
            .scalar_base
            .checked_add(callee.scalar_window)
            .ok_or(RESOURCE_LIMIT)?;
        self.defined
            .get_mut(cursor.scalar_base..scalar_end)
            .ok_or(INVALID_BYTECODE)?
            .fill(false);
        Ok(())
    }

    fn pass_arguments(
        &mut self,
        site: &CallSite,
        caller: Cursor,
        callee: Cursor,
    ) -> Result<(), Fault> {
        let arguments = self
            .current
            .moves
            .get(site.arguments_start..site.arguments_end)
            .ok_or(INVALID_BYTECODE)?;
        for entry in arguments {
            self.pass_argument(entry, caller, callee)?;
        }
        Ok(())
    }

    fn pass_argument(&mut self, entry: &Move, caller: Cursor, callee: Cursor) -> Result<(), Fault> {
        let source = usize::from(entry.source);
        let destination = usize::from(entry.destination);
        if entry.class == RegisterClass::Reference {
            let handle = *self
                .references
                .get(caller.reference_base.wrapping_add(source))
                .ok_or(INVALID_BYTECODE)?;
            let slot = self
                .references
                .get_mut(callee.reference_base.wrapping_add(destination))
                .ok_or(INVALID_BYTECODE)?;
            *slot = handle;
            return Ok(());
        }
        let word = *self
            .scalars
            .get(caller.scalar_base.wrapping_add(source))
            .ok_or(INVALID_BYTECODE)?;
        let slot = self
            .scalars
            .get_mut(callee.scalar_base.wrapping_add(destination))
            .ok_or(INVALID_BYTECODE)?;
        *slot = word;
        let defined = match entry.definition {
            Definition::Untracked => return Ok(()),
            Definition::Defined => true,
            Definition::Undefined => false,
            Definition::Copied => *self
                .defined
                .get(caller.scalar_base.wrapping_add(source))
                .ok_or(INVALID_BYTECODE)?,
        };
        self.set_defined(callee.scalar_base.wrapping_add(destination), defined)
    }

    pub(crate) fn return_scalar(&mut self, source: u16) -> Result<Flow, Fault> {
        let word = self.scalar(source)?;
        self.finish_call(Some(RuntimeValue::Scalar(word)))
    }

    pub(crate) fn return_reference(&mut self, source: u16) -> Result<Flow, Fault> {
        let handle = self.reference(source)?;
        self.finish_call(Some(RuntimeValue::Reference(handle)))
    }

    pub(crate) fn return_unit(&mut self) -> Result<Flow, Fault> {
        self.finish_call(None)
    }

    fn finish_call(&mut self, value: Option<RuntimeValue>) -> Result<Flow, Fault> {
        let callee_name = self.current.name.trim_start_matches('@').to_owned();
        let Some(frame) = self.frames.pop() else {
            return Ok(Flow::Completed(value));
        };
        self.cells.truncate(frame.cell_count);
        self.current = frame.function;
        let continuation = self.resolve_continuation(&frame)?;
        self.cursor = Cursor {
            program_counter: continuation,
            scalar_base: frame.scalar_base,
            reference_base: frame.reference_base,
        };
        if self.probed {
            self.record_return_event(callee_name);
        }
        self.store_return_value(frame.destination, value)?;
        Ok(Flow::Continue)
    }

    fn resolve_continuation(&self, frame: &ControlFrame<'_>) -> Result<usize, Fault> {
        let fast = frame
            .function
            .continuations
            .get(frame.return_point)
            .copied()
            .ok_or(INVALID_BYTECODE)?;
        if self.probed {
            Ok(frame
                .function
                .fast_to_probed_returns
                .get(fast)
                .copied()
                .unwrap_or(fast))
        } else {
            Ok(fast)
        }
    }

    fn record_return_event(&mut self, callee_name: String) {
        let line = self.current_line();
        let depth = self.current_depth();
        self.events.push(TraceEvent {
            class: TraceClass::Return,
            line,
            depth,
            payload: Some(EventPayload::Return {
                nombre: callee_name,
            }),
        });
    }

    fn store_return_value(
        &mut self,
        destination: Option<Register>,
        value: Option<RuntimeValue>,
    ) -> Result<(), Fault> {
        match (destination, value) {
            (Some(register), Some(RuntimeValue::Scalar(word)))
                if register.class == RegisterClass::Scalar =>
            {
                self.set_scalar(register.index, word)
            }
            (Some(register), Some(RuntimeValue::Reference(handle)))
                if register.class == RegisterClass::Reference =>
            {
                self.set_reference(register.index, handle)
            }
            (Some(_), Some(_)) => Err(INVALID_BYTECODE),
            (None | Some(_), None) | (None, Some(_)) => Ok(()),
        }
    }
}
