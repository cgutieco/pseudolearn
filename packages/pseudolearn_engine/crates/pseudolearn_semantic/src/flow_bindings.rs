use crate::hir::HirLocal;
use crate::identities::LocalId;
use crate::session::AnalysisSession;
use std::collections::{BTreeMap, BTreeSet};

pub(crate) struct FlowBindings {
    locals: Vec<HirLocal>,
    names: Vec<BTreeMap<String, LocalId>>,
    invalid: BTreeSet<LocalId>,
}

impl FlowBindings {
    pub(crate) fn capture(session: &AnalysisSession<'_>) -> Self {
        Self {
            locals: session.module.locals.clone(),
            names: session.local_names.clone(),
            invalid: session.invalid.clone(),
        }
    }

    pub(crate) fn restore(&self, session: &mut AnalysisSession<'_>) {
        let mut locals = self.locals.clone();
        for (index, local) in locals.iter_mut().enumerate() {
            if local.parameter
                && let Some(inferred) = session.module.locals.get(index)
            {
                local.type_id = inferred.type_id;
            }
        }
        session
            .module
            .record_locals
            .retain(|local, _| usize::try_from(local.0).is_ok_and(|index| index < locals.len()));
        session.module.locals = locals;
        session.local_names.clone_from(&self.names);
        session.invalid.clone_from(&self.invalid);
        session.inferred.clear();
        session.initialized = session
            .module
            .locals
            .iter()
            .map(|local| local.parameter)
            .collect();
    }
}
