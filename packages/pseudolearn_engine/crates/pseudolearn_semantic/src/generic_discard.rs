use crate::session::AnalysisSession;
use pseudolearn_diagnostics::Diagnostic;

pub(crate) struct Snapshot {
    classes: usize,
    functions: usize,
    locals: usize,
    expressions: usize,
    statements: usize,
}

impl Snapshot {
    pub(crate) fn capture(session: &AnalysisSession<'_>) -> Self {
        Self {
            classes: session.module.classes.len(),
            functions: session.module.functions.len(),
            locals: session.module.locals.len(),
            expressions: session.module.expressions.kinds.len(),
            statements: session.module.statements.kinds.len(),
        }
    }

    pub(crate) fn discard(&self, session: &mut AnalysisSession<'_>) {
        self.truncate_columns(session);
        crate::generic_classes::truncate(session, self.classes);
        let (functions, locals) = (self.functions, self.locals);
        session.module.units.functions.truncate(functions);
        session
            .generic
            .functions
            .retain(|_, found| below(found.0, functions));
        session
            .module
            .closures
            .retain(|found, _| below(found.0, functions));
        session
            .module
            .function_values
            .retain(|found, wrapper| below(found.0, functions) && below(wrapper.0, functions));
        session.called.retain(|found| below(found.0, functions));
        session.reads.retain(|found| below(found.0, locals));
        session.writes.retain(|found| below(found.0, locals));
        session.invalid.retain(|found| below(found.0, locals));
        session
            .module
            .record_locals
            .retain(|found, _| below(found.0, locals));
        session
            .module
            .local_visibility
            .retain(|found, _| below(found.0, locals));
    }

    fn truncate_columns(&self, session: &mut AnalysisSession<'_>) {
        session.module.functions.truncate(self.functions);
        session.module.locals.truncate(self.locals);
        session.assignment.locals.scopes.forget_from(self.locals);
        session.initialized.truncate(self.locals);
        let expressions = &mut session.module.expressions;
        expressions.kinds.truncate(self.expressions);
        expressions.types.truncate(self.expressions);
        expressions.value_classes.truncate(self.expressions);
        expressions.spans.truncate(self.expressions);
        session.module.statements.kinds.truncate(self.statements);
        session.module.statements.spans.truncate(self.statements);
    }
}

fn below(identifier: u32, bound: usize) -> bool {
    usize::try_from(identifier).is_ok_and(|slot| slot < bound)
}

pub(crate) fn dedupe(diagnostics: &mut Vec<Diagnostic>, from: usize) {
    let mut index = from.min(diagnostics.len());
    while index < diagnostics.len() {
        let repeated = diagnostics.get(index).is_some_and(|candidate| {
            diagnostics
                .iter()
                .take(index)
                .any(|earlier| earlier.code == candidate.code && earlier.span == candidate.span)
        });
        if repeated {
            diagnostics.remove(index);
        } else {
            index = index.saturating_add(1);
        }
    }
}

pub(crate) fn check_functions(session: &mut AnalysisSession<'_>) {
    for unit in 0..session.units.len() {
        session.switch_unit(unit);
        check_unit_templates(session);
    }
}

fn check_unit_templates(session: &mut AnalysisSession<'_>) {
    let templates = own_templates(session, |scope| &scope.functions);
    for template in templates {
        let snapshot = Snapshot::capture(session);
        session.generic.begin_definition();
        let arguments = crate::generic_opaque::arguments(session, &template);
        crate::generic_functions::instantiate(session, &template, (arguments, template.node));
        session.generic.defining = false;
        snapshot.discard(session);
    }
    let classes = own_templates(session, |scope| &scope.classes);
    for template in classes {
        let snapshot = Snapshot::capture(session);
        session.generic.begin_definition();
        let arguments = crate::generic_opaque::arguments(session, &template);
        crate::generic_classes::instantiate(session, &template, arguments, template.node);
        session.generic.defining = false;
        snapshot.discard(session);
    }
    for template in own_templates(session, |scope| &scope.interfaces) {
        session.generic.begin_definition();
        let arguments = crate::generic_opaque::arguments(session, &template);
        crate::generic_interfaces::define(session, &template, arguments);
        session.generic.defining = false;
    }
}

pub(crate) fn check_records(session: &mut AnalysisSession<'_>) {
    let templates = own_templates(session, |scope| &scope.records);
    for template in templates {
        session.generic.begin_definition();
        let arguments = crate::generic_opaque::arguments(session, &template);
        crate::generic_records::instantiate(session, &template, arguments, template.node);
        session.generic.defining = false;
    }
    let variants = own_templates(session, |scope| &scope.variants);
    for template in variants {
        session.generic.begin_definition();
        let arguments = crate::generic_opaque::arguments(session, &template);
        crate::generic_variants::instantiate(session, &template, arguments, template.node);
        session.generic.defining = false;
    }
}

fn own_templates(
    session: &AnalysisSession<'_>,
    table: impl Fn(
        &crate::generic_state::GenericScope,
    ) -> &std::collections::BTreeMap<String, crate::generic_state::GenericTemplate>,
) -> Vec<crate::generic_state::GenericTemplate> {
    table(&session.generics)
        .values()
        .filter(|template| template.unit == session.unit)
        .cloned()
        .collect()
}
