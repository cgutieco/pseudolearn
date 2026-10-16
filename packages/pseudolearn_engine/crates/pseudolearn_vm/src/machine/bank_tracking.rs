use super::Machine;

impl Machine<'_> {
    pub(super) fn mark_frame_dirty_from(&self, position: usize) {
        self.frame_dirty_from
            .set(self.frame_dirty_from.get().min(position));
    }

    pub(super) fn mark_scalar_dirty(&self, position: usize) {
        if self.bank_delta_tracking.get() {
            self.scalar_dirty_from
                .set(self.scalar_dirty_from.get().min(position));
        }
    }

    pub(super) fn mark_reference_dirty(&self, position: usize) {
        if self.bank_delta_tracking.get() {
            self.reference_dirty_from
                .set(self.reference_dirty_from.get().min(position));
        }
    }

    pub(super) fn mark_defined_dirty(&self, position: usize) {
        if self.bank_delta_tracking.get() {
            self.defined_dirty_from
                .set(self.defined_dirty_from.get().min(position));
        }
    }

    pub(super) fn begin_bank_delta_tracking(&self) {
        self.bank_delta_tracking.set(true);
        self.reset_bank_delta_tracking();
    }

    pub(super) fn reset_bank_delta_tracking(&self) {
        self.scalar_dirty_from.set(self.scalar_limit);
        self.reference_dirty_from.set(self.reference_limit);
        self.defined_dirty_from.set(self.scalar_limit);
    }
}
