use pseudolearn_bytecode::{Register, RegisterClass};
use std::sync::Arc;

use super::{Cursor, LoadedFunction, Machine, TaskContext};
use crate::load::{CallSite, Definition, Move};
use crate::{Fault, evaluate::INVALID_BYTECODE};

impl Machine<'_> {
    pub(super) fn create_task_context(
        &self,
        site_index: u32,
    ) -> Result<(TaskContext, Register), Fault> {
        let site = self.call_site(site_index)?;
        let destination = site.destination.ok_or(INVALID_BYTECODE)?;
        if destination.class != RegisterClass::Scalar {
            return Err(INVALID_BYTECODE);
        }
        let callee = self
            .program
            .inner
            .functions
            .get(site.function)
            .cloned()
            .ok_or(INVALID_BYTECODE)?;
        let context = self.child_context(&site, callee, site.function)?;
        Ok((context, destination))
    }

    fn call_site(&self, index: u32) -> Result<CallSite, Fault> {
        self.current
            .calls
            .get(usize::try_from(index).map_err(|_| INVALID_BYTECODE)?)
            .copied()
            .ok_or(INVALID_BYTECODE)
    }

    fn child_context(
        &self,
        site: &CallSite,
        callee: Arc<LoadedFunction>,
        callee_index: usize,
    ) -> Result<TaskContext, Fault> {
        let arguments = self
            .current
            .moves
            .get(site.arguments_start..site.arguments_end)
            .ok_or(INVALID_BYTECODE)?;
        let entry_position = self.entry_position(&callee);
        let mut context = TaskContext {
            current_function_index: callee_index,
            cursor: Cursor {
                program_counter: entry_position,
                scalar_base: 0,
                reference_base: 0,
            },
            root_position: entry_position,
            scalar_limit: callee.scalar_window,
            reference_limit: callee.reference_window,
            scalars: vec![0; callee.scalar_window],
            defined: vec![false; callee.scalar_window],
            references: vec![0; callee.reference_window],
            frames: Vec::new(),
            cells: Vec::new(),
            scalar_watermark: 0,
            reference_watermark: 0,
            current: callee,
        };
        self.copy_task_arguments(arguments, &mut context)?;
        Ok(context)
    }

    fn entry_position(&self, callee: &LoadedFunction) -> usize {
        if self.probed {
            callee.fast_to_probed_blocks.first().copied().unwrap_or(0)
        } else {
            0
        }
    }

    fn copy_task_arguments(
        &self,
        arguments: &[Move],
        context: &mut TaskContext,
    ) -> Result<(), Fault> {
        for argument in arguments {
            match argument.class {
                RegisterClass::Scalar => self.copy_scalar_argument(argument, context)?,
                RegisterClass::Reference => self.copy_reference_argument(argument, context)?,
            }
        }
        Ok(())
    }

    fn copy_scalar_argument(
        &self,
        argument: &Move,
        context: &mut TaskContext,
    ) -> Result<(), Fault> {
        let source_index = self
            .cursor
            .scalar_base
            .checked_add(usize::from(argument.source))
            .ok_or(INVALID_BYTECODE)?;
        let destination = usize::from(argument.destination);
        let source = self
            .scalars
            .get(source_index)
            .copied()
            .ok_or(INVALID_BYTECODE)?;
        *context
            .scalars
            .get_mut(destination)
            .ok_or(INVALID_BYTECODE)? = source;
        let defined = self.scalar_argument_is_defined(argument, source_index)?;
        *context
            .defined
            .get_mut(destination)
            .ok_or(INVALID_BYTECODE)? = defined;
        context.scalar_watermark = context.scalar_watermark.max(destination.saturating_add(1));
        Ok(())
    }

    fn scalar_argument_is_defined(
        &self,
        argument: &Move,
        source_index: usize,
    ) -> Result<bool, Fault> {
        match argument.definition {
            Definition::Untracked | Definition::Undefined => Ok(false),
            Definition::Defined => Ok(true),
            Definition::Copied => self
                .defined
                .get(source_index)
                .copied()
                .ok_or(INVALID_BYTECODE),
        }
    }

    fn copy_reference_argument(
        &self,
        argument: &Move,
        context: &mut TaskContext,
    ) -> Result<(), Fault> {
        let source_index = self
            .cursor
            .reference_base
            .checked_add(usize::from(argument.source))
            .ok_or(INVALID_BYTECODE)?;
        let destination = usize::from(argument.destination);
        let source = self
            .references
            .get(source_index)
            .copied()
            .ok_or(INVALID_BYTECODE)?;
        *context
            .references
            .get_mut(destination)
            .ok_or(INVALID_BYTECODE)? = source;
        context.reference_watermark = context
            .reference_watermark
            .max(destination.saturating_add(1));
        Ok(())
    }
}
