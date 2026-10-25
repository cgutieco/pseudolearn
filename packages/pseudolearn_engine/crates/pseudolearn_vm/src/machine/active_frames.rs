use std::collections::BTreeMap;

use pseudolearn_bytecode::{Register, ValueType};
use pseudolearn_runtime::Handle;

use super::Machine;

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
