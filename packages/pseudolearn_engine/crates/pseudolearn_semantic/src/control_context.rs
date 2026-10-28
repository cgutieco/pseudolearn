use crate::identities::LocalId;
use std::collections::BTreeSet;

#[derive(Clone, Debug, Default)]
pub(crate) struct DeferredEffects {
    pub consumed: BTreeSet<LocalId>,
    pub produced: BTreeSet<LocalId>,
}

#[derive(Clone, Debug, Default)]
pub(crate) struct ControlContext {
    pub loops: u32,
    pub cleaning: bool,
    pub task_scopes: u32,
    pub awaiting_task_handle: bool,
    pub deferred: Vec<Vec<DeferredEffects>>,
}
