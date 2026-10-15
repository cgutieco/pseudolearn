use crate::hir::{FunctionKind, HirClass, HirFunction};
use crate::identities::{ClassId, FunctionId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn register(session: &mut AnalysisSession<'_>) {
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
    let nodes: Vec<_> = session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| matches!(node.kind, NodeKind::AlgorithmUnit | NodeKind::Subprogram))
        .map(|(index, _)| index)
        .collect();
    for node in nodes {
        register_function(session, node, None);
    }
    for class in 0..session.module.classes.len() {
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
    session.module.classes.push(HirClass {
        name,
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
    let kind = function_kind(session, node, result);
    let identifier = FunctionId(u32::try_from(session.module.functions.len()).unwrap_or(u32::MAX));
    if owner.is_none() && kind != FunctionKind::Main {
        register_name(session, &name, name_node, identifier);
    }
    let closing = session.closing_span(node);
    session.module.functions.push(HirFunction {
        kind,
        name,
        owner,
        parameters: Vec::new(),
        result,
        body: Vec::new(),
        span: session.span(node),
        closing_span: closing,
        syntax: node,
        private: false,
    });
    session.local_names.push(std::collections::BTreeMap::new());
    session.current = identifier;
    crate::local_registry::parameters(session, node);
    crate::local_registry::declarations(session, node);
    identifier
}

fn register_name(
    session: &mut AnalysisSession<'_>,
    name: &str,
    node: usize,
    identifier: FunctionId,
) {
    if session.functions.contains_key(name) {
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
