use crate::hir::HirLocal;
use crate::identities::LocalId;
use crate::session::AnalysisSession;
use std::collections::BTreeSet;

pub(crate) struct FlowBindings {
    locals: Vec<HirLocal>,
    functions: usize,
    classes: usize,
    constants: Vec<crate::constant_registry::ConstantEntry>,
    invalid: BTreeSet<LocalId>,
}

impl FlowBindings {
    pub(crate) fn capture(session: &AnalysisSession<'_>) -> Self {
        Self {
            locals: session.module.locals.clone(),
            functions: session.module.functions.len(),
            classes: session.module.classes.len(),
            constants: session.constants.clone(),
            invalid: session.invalid.clone(),
        }
    }

    pub(crate) fn restore(&self, session: &mut AnalysisSession<'_>) {
        session.module.functions.truncate(self.functions);
        session.module.units.functions.truncate(self.functions);
        session.generic.functions.clear();
        session.generic.environment.clear();
        session.module.classes.truncate(self.classes);
        session.module.closures.clear();
        session.module.function_values.clear();
        session.closure_stack.clear();
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
        session.module.local_visibility.clear();
        session.module.locals = locals;
        session.constants.clone_from(&self.constants);
        session.declarations.clear();
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
