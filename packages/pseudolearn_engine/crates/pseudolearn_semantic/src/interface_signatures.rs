use crate::function_model::FunctionSignature;
use crate::hir::Passing;
use crate::interface_model::InterfaceMethod;
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize) -> InterfaceMethod {
    let name = session
        .child(node, NodeKind::Identifier)
        .map(|node| session.name(node))
        .unwrap_or_default();
    let result = session
        .child(node, NodeKind::Type)
        .map(|node| crate::type_resolution::resolve(session, node))
        .unwrap_or_else(|| session.module.types.intern(Type::Unit));
    let parameters = session
        .child(node, NodeKind::Parameters)
        .map(|node| session.children(node))
        .unwrap_or_default();
    let parameters = parameters
        .into_iter()
        .map(|node| parameter(session, node))
        .collect();
    let opener = session.options.profile.fold_word(session.lexeme(node));
    let pure = opener == "funcion" || opener == "function";
    InterfaceMethod {
        name,
        signature: FunctionSignature { parameters, result },
        span: session.span(node),
        pure,
    }
}

fn parameter(
    session: &mut AnalysisSession<'_>,
    node: usize,
) -> (crate::identities::TypeId, Passing) {
    let mut kind = crate::local_registry::parameter_type(session, node);
    let array = session.has_token(node, TokenKind::LeftBracket);
    if array {
        kind = crate::local_registry::array_parameter_type(session, node, kind);
    }
    let reference = session.has_token(node, TokenKind::Keyword(KeywordKind::ByReference));
    (
        kind,
        if reference || array {
            Passing::Reference
        } else {
            Passing::Value
        },
    )
}

pub(crate) fn matches(
    session: &AnalysisSession<'_>,
    expected: &FunctionSignature,
    function: crate::identities::FunctionId,
) -> bool {
    let Some(function) = crate::hierarchy::function(session, function) else {
        return false;
    };
    function.result == expected.result
        && function.parameters.len() == expected.parameters.len()
        && function
            .parameters
            .iter()
            .zip(&expected.parameters)
            .all(|(local, (kind, passing))| {
                usize::try_from(local.0)
                    .ok()
                    .and_then(|index| session.module.locals.get(index))
                    .is_some_and(|local| local.type_id == *kind && local.passing == *passing)
            })
}
