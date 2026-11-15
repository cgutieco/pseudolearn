use std::collections::BTreeMap;

use pseudolearn_bytecode::{Register, SourceSpan, ValueType};
use pseudolearn_runtime::{Handle, TaskId};

use super::{Machine, image};
use crate::VmTrap;
use crate::load::LoadedFunction;

#[derive(Clone, Debug)]
pub struct ActiveFrameInspection<'program> {
    pub function_name: &'program str,
    pub names: BTreeMap<Register, String>,
    pub scalar_base: usize,
    pub reference_base: usize,
    pub receiver_handle: Option<Handle>,
    pub scalar_types: &'program [ValueType],
    pub reference_types: &'program [ValueType],
}

impl<'program> Machine<'program> {
    pub fn active_frames_count(&self) -> usize {
        self.frames.len().saturating_add(1)
    }

    pub fn active_frame<'machine>(
        &'machine self,
        frame_position: usize,
    ) -> Option<ActiveFrameInspection<'machine>> {
        let total_frames = self.active_frames_count();
        if frame_position >= total_frames {
            return None;
        }
        if frame_position < self.frames.len() {
            let frame = self.frames.get(frame_position)?;
            Some(ActiveFrameInspection {
                function_name: if frame.function.name.trim_start_matches('@') == "main" {
                    &self.program.inner.name
                } else {
                    &frame.function.name
                },
                names: crate::machine::lexical_names::suspended(self, frame),
                scalar_base: frame.scalar_base,
                reference_base: frame.reference_base,
                receiver_handle: frame_receiver(self, frame.reference_base),
                scalar_types: &frame.function.scalar_types,
                reference_types: &frame.function.reference_types,
            })
        } else {
            Some(ActiveFrameInspection {
                function_name: if self.current.name.trim_start_matches('@') == "main" {
                    &self.program.inner.name
                } else {
                    &self.current.name
                },
                names: crate::machine::lexical_names::current(self),
                scalar_base: self.cursor.scalar_base,
                reference_base: self.cursor.reference_base,
                receiver_handle: frame_receiver(self, self.cursor.reference_base),
                scalar_types: &self.current.scalar_types,
                reference_types: &self.current.reference_types,
            })
        }
    }
}

fn frame_receiver(machine: &Machine<'_>, reference_base: usize) -> Option<Handle> {
    let handle_word = machine.references.get(reference_base).copied()?;
    if handle_word == 0 {
        None
    } else {
        Some(Handle(handle_word))
    }
}

impl Machine<'_> {
    pub fn frame_name(&self, position: usize) -> Option<&str> {
        let function = if position == self.frames.len() {
            &self.current
        } else {
            &self.frames.get(position)?.function
        };
        let name = function.name.trim_start_matches('@');
        Some(if name == "main" {
            &self.program.inner.name
        } else {
            name
        })
    }

    pub fn task_inspection(&self, task: u64) -> Result<Machine<'_>, VmTrap> {
        let context = if task != self.current_task_id() {
            Some(
                self.tasks
                    .contexts
                    .get(&TaskId(task))
                    .cloned()
                    .ok_or_else(|| VmTrap::new("invalidTaskReference", None))?,
            )
        } else {
            None
        };
        let mut options = self.options.clone();
        options.cancelled = None;
        let mut inspection =
            image::resume_machine(&self.program, image::snapshot_machine(self), options)?;
        if let Some(context) = context {
            context
                .restore(&mut inspection)
                .map_err(|_| VmTrap::new("invalidTaskReference", None))?;
            inspection.tasks.current = TaskId(task);
        }
        Ok(inspection)
    }

    pub fn frame_location(&self, position: usize) -> Option<SourceSpan> {
        if position == self.frames.len() {
            return self.current_span();
        }
        let frame = self.frames.get(position)?;
        let mut counter = *frame.function.continuations.get(frame.return_point)?;
        if self.probed {
            counter = *frame.function.fast_to_probed_returns.get(counter)?;
        }
        frame
            .function
            .span(counter.saturating_sub(1), self.probed)
            .or(frame.function.declaration_span)
    }
}

impl Machine<'_> {
    pub fn active_frame_window(
        &self,
        position: usize,
        range: (usize, usize),
    ) -> Option<(ActiveFrameInspection<'_>, usize)> {
        let (function, scalar_base, reference_base, names, total) =
            self.window_basis(position, range)?;
        let receiver_handle = self
            .references
            .get(reference_base)
            .copied()
            .filter(|handle| *handle != 0)
            .map(Handle);
        Some((
            ActiveFrameInspection {
                function_name: self.frame_name(position)?,
                names,
                scalar_base,
                reference_base,
                receiver_handle,
                scalar_types: &function.scalar_types,
                reference_types: &function.reference_types,
            },
            total,
        ))
    }
}

type WindowBasis<'machine> = (
    &'machine LoadedFunction,
    usize,
    usize,
    BTreeMap<Register, String>,
    usize,
);

impl Machine<'_> {
    fn window_basis(&self, position: usize, range: (usize, usize)) -> Option<WindowBasis<'_>> {
        if position == self.frames.len() {
            let (names, total) = super::lexical_names::current_window(self, range);
            return Some((
                &self.current,
                self.cursor.scalar_base,
                self.cursor.reference_base,
                names,
                total,
            ));
        }
        let frame = self.frames.get(position)?;
        let (names, total) = super::lexical_names::suspended_window(self, frame, range);
        Some((
            &frame.function,
            frame.scalar_base,
            frame.reference_base,
            names,
            total,
        ))
    }
}
