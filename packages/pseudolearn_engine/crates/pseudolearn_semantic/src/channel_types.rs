use crate::hir::HirRecord;
use crate::identities::{RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_syntax::NodeKind;

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize, name: &str) -> Option<Type> {
    if crate::collection_types::identity(session, name) != Some("channelType") {
        return None;
    }
    let arguments = session
        .child(node, NodeKind::TypeArguments)
        .map(|arguments| session.children(arguments))
        .unwrap_or_default();
    if arguments.len() != 1 {
        crate::generic_names::count_mismatch(session, node, (name, 1, arguments.len()));
        return Some(Type::Error);
    }
    let element = crate::type_resolution::resolve(session, *arguments.first()?);
    if !crate::task_failure_types::transferable(session, element) {
        session.report(DiagnosticCode::ChannelElementNotTransferable, node);
    }
    if let Some(record) = session
        .module
        .channels
        .iter()
        .find_map(|(record, found)| (*found == element).then_some(*record))
    {
        return Some(Type::Record(record));
    }
    let record = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    let integer = session.module.types.intern(Type::Integer);
    session.module.records.push(HirRecord {
        name: format!("$channel:{}", element.0),
        fields: Vec::new(),
        leaf_types: vec![integer],
        leaf_names: vec!["identity".to_owned()],
        span: session.span(node),
        syntax: node,
    });
    session.module.channels.insert(record, element);
    Some(Type::Record(record))
}

pub(crate) fn element(session: &AnalysisSession<'_>, kind: &Type) -> Option<TypeId> {
    let Type::Record(record) = kind else {
        return None;
    };
    session.module.channels.get(record).copied()
}

pub(crate) fn reject_operands(
    session: &mut AnalysisSession<'_>,
    operands: (crate::ExpressionId, crate::ExpressionId),
    node: usize,
) -> bool {
    if [operands.0, operands.1]
        .into_iter()
        .any(|operand| element(session, &session.expression_type(operand)).is_some())
    {
        session.report(DiagnosticCode::IncompatibleOperandTypes, node);
        true
    } else {
        false
    }
}
