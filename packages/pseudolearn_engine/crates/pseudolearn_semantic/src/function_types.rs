use crate::function_model::FunctionSignature;
use crate::hir::{HirRecord, Passing};
use crate::identities::{FunctionId, RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn get(session: &AnalysisSession<'_>, kind: &Type) -> Option<FunctionSignature> {
    let Type::Record(record) = kind else {
        return None;
    };
    session.module.function_types.get(record).cloned()
}

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize) -> TypeId {
    let mut parameters = Vec::new();
    let mut result = session.module.types.intern(Type::Unit);
    for child in session.children(node) {
        if session.kind(child) == NodeKind::FunctionParameterType {
            if let Some(parameter) = parameter(session, child) {
                parameters.push(parameter);
            }
        } else if session.kind(child) == NodeKind::Type {
            result = crate::type_resolution::resolve(session, child);
        }
    }
    intern(session, FunctionSignature { parameters, result }, node)
}

pub(crate) fn signature(session: &AnalysisSession<'_>, function: FunctionId) -> FunctionSignature {
    let function = usize::try_from(function.0)
        .ok()
        .and_then(|index| session.module.functions.get(index));
    let parameters = function
        .into_iter()
        .flat_map(|function| &function.parameters)
        .filter_map(|local| {
            usize::try_from(local.0)
                .ok()
                .and_then(|index| session.module.locals.get(index))
        })
        .map(|local| (local.type_id, local.passing))
        .collect();
    FunctionSignature {
        parameters,
        result: function
            .map(|function| function.result)
            .unwrap_or(TypeId(u32::MAX)),
    }
}

pub(crate) fn intern(
    session: &mut AnalysisSession<'_>,
    signature: FunctionSignature,
    node: usize,
) -> TypeId {
    if let Some(record) = session
        .module
        .function_types
        .iter()
        .find_map(|(record, existing)| (*existing == signature).then_some(*record))
    {
        return session.module.types.intern(Type::Record(record));
    }
    let integer = session.module.types.intern(Type::Integer);
    let reference = session.module.types.intern(Type::String);
    let record = RecordId(u32::try_from(session.module.records.len()).unwrap_or(u32::MAX));
    session.module.records.push(HirRecord {
        name: format!("$function{}", record.0),
        fields: Vec::new(),
        leaf_types: vec![integer, reference],
        leaf_names: vec!["code".to_owned(), "environment".to_owned()],
        span: session.span(node),
        syntax: node,
    });
    session.module.function_types.insert(record, signature);
    session.module.types.intern(Type::Record(record))
}

pub(crate) fn reject_operands(
    session: &mut AnalysisSession<'_>,
    operands: (
        crate::identities::ExpressionId,
        crate::identities::ExpressionId,
    ),
    node: usize,
) -> bool {
    if crate::function_containment::contains(session, session.expression_type(operands.0))
        || crate::function_containment::contains(session, session.expression_type(operands.1))
    {
        session.report(
            pseudolearn_diagnostics::DiagnosticCode::IncompatibleOperandTypes,
            node,
        );
        return true;
    }
    false
}

fn parameter(session: &mut AnalysisSession<'_>, node: usize) -> Option<(TypeId, Passing)> {
    let syntax = session.child(node, NodeKind::Type)?;
    let kind = crate::type_resolution::resolve(session, syntax);
    let passing = if session.has_token(node, TokenKind::Keyword(KeywordKind::ByReference)) {
        Passing::Reference
    } else {
        Passing::Value
    };
    Some((kind, passing))
}
