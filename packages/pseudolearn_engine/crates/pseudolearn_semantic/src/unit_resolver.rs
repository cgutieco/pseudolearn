use crate::hir::{FunctionKind, HirClass, HirFunction};
use crate::identities::{ClassId, FunctionId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
    crate::generic_registry::collect(session);
    register_classes(session);
    crate::type_declarations::register(session);
    crate::generic_discard::check_records(session);
    register_functions(session);
    register_members(session);
    crate::constant_registry::evaluate_all(session);
}

pub(crate) fn register_classes(session: &mut AnalysisSession<'_>) {
    let classes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::ClassUnit)
        .map(|(index, _)| index)
        .collect();
    for node in classes {
        register_class(session, node);
    }
}

pub(crate) fn register_functions(session: &mut AnalysisSession<'_>) {
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| matches!(node.kind, NodeKind::AlgorithmUnit | NodeKind::Subprogram))
        .map(|(index, _)| index)
        .filter(|node| !crate::generic_registry::is_generic(session, *node))
        .collect();
    for node in nodes {
        register_function(session, node, None);
    }
}

pub(crate) fn register_members(session: &mut AnalysisSession<'_>) {
    for class in 0..session.module.classes.len() {
        session.enter_class(class);
        crate::class_registry::members(session, ClassId(u32::try_from(class).unwrap_or(u32::MAX)));
    }
}

fn register_class(session: &mut AnalysisSession<'_>, node: usize) {
    let Some(name_node) = session.child(node, NodeKind::Identifier) else {
        return;
    };
    let name = session.name(name_node);
    let identifier = ClassId(u32::try_from(session.module.classes.len()).unwrap_or(u32::MAX));
    if session.classes.contains_key(&name) {
        session.named_report(DiagnosticCode::DuplicateClass, name_node, &name);
        return;
    }
    session.classes.insert(name.clone(), identifier);
    let link_name = session.link_name(&name);
    session.tag_class();
    session.module.classes.push(HirClass {
        name: link_name,
        superclass: None,
        fields: Vec::new(),
        methods: Vec::new(),
        virtual_slots: Vec::new(),
        constructor: None,
        span: session.span(node),
        syntax: node,
    });
}

pub(crate) fn register_function(
    session: &mut AnalysisSession<'_>,
    node: usize,
    owner: Option<ClassId>,
) -> FunctionId {
    let name_node = session.child(node, NodeKind::Identifier).unwrap_or(node);
    let name = session.name(name_node);
    let result = session
        .child(node, NodeKind::Type)
        .map(|node| crate::type_resolution::resolve(session, node))
        .unwrap_or_else(|| session.module.types.intern(Type::Unit));
    check_member_result(session, node, (owner, result));
    let kind = function_kind(session, node, result);
    let identifier = FunctionId(u32::try_from(session.module.functions.len()).unwrap_or(u32::MAX));
    let top_level = owner.is_none() && kind != FunctionKind::Main;
    let link_name = session.link_name_if(top_level, &name);
    session.tag_function();
    if top_level {
        register_name(session, &name, name_node, identifier);
    }
    let closing = session.closing_span(node);
    session.module.functions.push(HirFunction {
        kind,
        name: link_name,
        owner,
        parameters: Vec::new(),
        result,
        body: Vec::new(),
        span: session.span(node),
        closing_span: closing,
        syntax: node,
        private: false,
    });
    open_scopes(session);
    session.current = identifier;
    crate::local_registry::parameters(session, node);

    identifier
}

fn check_member_result(
    session: &mut AnalysisSession<'_>,
    node: usize,
    signature: (Option<ClassId>, crate::identities::TypeId),
) {
    let (owner, result) = signature;
    if owner.is_some()
        && matches!(session.module.types.get(result), Type::Record(_))
        && crate::variant_types::get(session, &session.module.types.get(result)).is_none()
    {
        session.report(DiagnosticCode::RecordMemberSignatureNotSupported, node);
    }
}

fn open_scopes(session: &mut AnalysisSession<'_>) {
    session.bindings = crate::block_scopes::BlockScopes::default();
    session.bindings.enter();
}

fn register_name(
    session: &mut AnalysisSession<'_>,
    name: &str,
    node: usize,
    identifier: FunctionId,
) {
    if session.functions.contains_key(name) || session.generics.functions.contains_key(name) {
        session.named_report(DiagnosticCode::DuplicateSubroutine, node, name);
        return;
    }
    if session.classes.contains_key(name) {
        session.named_report(DiagnosticCode::ClassAndSubroutineSameName, node, name);
    }
    session.functions.insert(name.to_owned(), identifier);
}

fn function_kind(
    session: &AnalysisSession<'_>,
    node: usize,
    result: crate::identities::TypeId,
) -> FunctionKind {
    match session.kind(node) {
        NodeKind::AlgorithmUnit => FunctionKind::Main,
        NodeKind::MethodMember => FunctionKind::Method,
        NodeKind::ConstructorMember => FunctionKind::Constructor,
        _ if session.module.types.get(result) == Type::Unit => FunctionKind::Procedure,
        _ => FunctionKind::Function,
    }
}
