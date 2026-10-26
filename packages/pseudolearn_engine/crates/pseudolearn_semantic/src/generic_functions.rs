use crate::generic_state::{GenericTemplate, INSTANCE_LIMIT};
use crate::hir::{FunctionKind, HirFunction};
use crate::identities::{FunctionId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_syntax::NodeKind;

struct SavedState {
    bindings: crate::block_scopes::BlockScopes,
    current: FunctionId,
    returned: bool,
    pending: std::collections::BTreeSet<crate::identities::LocalId>,
    controls: Vec<crate::identities::LocalId>,
    control: crate::control_context::ControlContext,
    closures: Vec<crate::function_model::ClosureFrame>,
    declarations: std::collections::BTreeMap<usize, Vec<crate::identities::LocalId>>,
    environment: Vec<(String, TypeId)>,
}

impl SavedState {
    fn take(session: &mut AnalysisSession<'_>) -> Self {
        Self {
            bindings: std::mem::take(&mut session.bindings),
            current: session.current,
            returned: session.returned,
            pending: std::mem::take(&mut session.pending_results),
            controls: std::mem::take(&mut session.controls),
            control: std::mem::take(&mut session.control),
            closures: std::mem::take(&mut session.closure_stack),
            declarations: std::mem::take(&mut session.declarations),
            environment: std::mem::take(&mut session.generic.environment),
        }
    }

    fn restore(self, session: &mut AnalysisSession<'_>) {
        session.bindings = self.bindings;
        session.current = self.current;
        session.returned = self.returned;
        session.pending_results = self.pending;
        session.controls = self.controls;
        session.control = self.control;
        session.closure_stack = self.closures;
        session.declarations = self.declarations;
        session.generic.environment = self.environment;
    }
}

pub(crate) fn instantiate(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (arguments, origin): (Vec<TypeId>, usize),
) -> Option<FunctionId> {
    if !crate::interface_constraints::check(session, template, &arguments, origin) {
        return None;
    }
    let key = (session.unit, template.node, arguments.clone());
    if let Some(existing) = session.generic.functions.get(&key) {
        return Some(*existing);
    }
    let name = template_name(session, template)?;
    if session.generic.instance_count() >= INSTANCE_LIMIT {
        crate::generic_records::report_limit(session, origin, &name);
        return None;
    }
    session.generic.instantiated = true;
    let diagnostics = session.diagnostics.len();
    let saved = SavedState::take(session);
    let function = register(session, template, (&name, &arguments));
    session.generic.functions.insert(key, function);
    let index = usize::try_from(function.0).unwrap_or(usize::MAX);
    crate::flow::function(session, index);
    session.called.insert(function);
    saved.restore(session);
    crate::generic_discard::dedupe(&mut session.diagnostics, diagnostics);
    Some(function)
}

fn template_name(session: &AnalysisSession<'_>, template: &GenericTemplate) -> Option<String> {
    let name_node = session.child(template.node, NodeKind::Identifier)?;
    Some(session.name(name_node))
}

fn register(
    session: &mut AnalysisSession<'_>,
    template: &GenericTemplate,
    (name, arguments): (&str, &[TypeId]),
) -> FunctionId {
    session.generic.environment = template
        .parameters
        .iter()
        .cloned()
        .zip(arguments.iter().copied())
        .collect();
    let result = session
        .child(template.node, NodeKind::Type)
        .map(|kind| crate::type_resolution::resolve(session, kind))
        .unwrap_or_else(|| session.module.types.intern(Type::Unit));
    let identifier = FunctionId(u32::try_from(session.module.functions.len()).unwrap_or(u32::MAX));
    let unit_name =
        crate::generic_labels::instance_name(session, &session.link_name(name), arguments);
    session.tag_function();
    session.module.functions.push(HirFunction {
        kind: kind_for(session, result),
        name: unit_name,
        owner: None,
        parameters: Vec::new(),
        result,
        body: Vec::new(),
        span: session.span(template.node),
        closing_span: session.closing_span(template.node),
        syntax: template.node,
        private: false,
    });
    session.current = identifier;
    session.bindings = crate::block_scopes::BlockScopes::default();
    session.bindings.enter();
    crate::local_registry::parameters(session, template.node);
    identifier
}

fn kind_for(session: &AnalysisSession<'_>, result: TypeId) -> FunctionKind {
    if session.module.types.get(result) == Type::Unit {
        FunctionKind::Procedure
    } else {
        FunctionKind::Function
    }
}
