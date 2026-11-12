use pseudolearn_vm::MachineDelta;

#[derive(Clone, Debug, PartialEq)]
pub struct Checkpoint {
    pub event_index: usize,
    pub statement_index: u64,
    pub undo: Option<MachineDelta>,
}

impl Checkpoint {
    pub fn retained_slots(&self) -> usize {
        self.undo.as_ref().map_or(0, MachineDelta::copied_slots)
    }
}
