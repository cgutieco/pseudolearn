use super::Machine;

impl Machine<'_> {
    pub(super) fn visible_span(&self, position: usize) -> Option<pseudolearn_bytecode::SourceSpan> {
        if self.current.name.starts_with("@__collection.") {
            let frame = self
                .frames
                .iter()
                .rev()
                .find(|frame| !frame.function.name.starts_with("@__collection."))?;
            let fast = *frame.function.continuations.get(frame.return_point)?;
            let position = if self.probed {
                frame
                    .function
                    .fast_to_probed_returns
                    .get(fast)
                    .copied()
                    .unwrap_or(fast)
            } else {
                fast
            };
            return frame.function.span(position.saturating_sub(1), self.probed);
        }
        self.current.span(position, self.probed)
    }
    pub(crate) fn current_depth(&self) -> u32 {
        u32::try_from(
            self.frames
                .iter()
                .filter(|frame| !frame.function.name.starts_with("@__collection."))
                .count()
                .saturating_add(usize::from(
                    !self.current.name.starts_with("@__collection."),
                )),
        )
        .unwrap_or(1)
    }
}
