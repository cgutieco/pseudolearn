use super::context::smallest_node;
use super::{HelpIdentity, HelpIdentityKind, identity};
use crate::query_context::QueryContext;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::Span;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(super) fn record_keyword(
    context: &QueryContext<'_>,
    slot: usize,
    keyword: KeywordKind,
) -> Option<(HelpIdentity, Span)> {
    match keyword {
        KeywordKind::ByReference => record_parameter(context, slot)
            .map(|span| (role("parameter", "pgl01_record_by_reference"), span)),
        KeywordKind::TypeConnector if member_signature(context, slot) => {
            record_parameter(context, slot)
                .map(|span| (role("parameter", "pgl01_record_member_signature"), span))
        }
        KeywordKind::PublicVisibility | KeywordKind::PrivateVisibility => {
            type_visibility(context, slot)
        }
        _ => None,
    }
}

fn role(id: &str, name: &str) -> HelpIdentity {
    identity(HelpIdentityKind::Role, id, name)
}

fn record_parameter(context: &QueryContext<'_>, slot: usize) -> Option<Span> {
    let (_, span) = smallest_node(context, slot, |kind| kind == NodeKind::Parameter)?;
    let names_record = (0..context.tree.tokens.token_count())
        .filter(|index| context.tree.tokens.kind(*index) == Some(TokenKind::Identifier))
        .filter(|index| {
            context
                .tree
                .tokens
                .span(*index)
                .is_some_and(|token| token.start >= span.start && token.ending <= span.ending)
        })
        .skip(1)
        .any(|index| {
            let name = context.token_text(index);
            context
                .analysis
                .module
                .records
                .iter()
                .any(|record| record.name == name)
        });
    names_record.then_some(span)
}

fn member_signature(context: &QueryContext<'_>, slot: usize) -> bool {
    smallest_node(context, slot, |kind| {
        matches!(
            kind,
            NodeKind::MethodMember | NodeKind::ConstructorMember | NodeKind::InterfaceSignature
        )
    })
    .is_some()
        && smallest_node(context, slot, |kind| kind == NodeKind::Parameter).is_some()
}

fn type_visibility(context: &QueryContext<'_>, slot: usize) -> Option<(HelpIdentity, Span)> {
    let next = (slot.checked_add(1)?..context.tree.tokens.token_count()).find(|index| {
        context
            .tree
            .tokens
            .kind(*index)
            .is_some_and(|kind| !kind.is_trivia())
    })?;
    let declares_type = match context.tree.tokens.kind(next)? {
        TokenKind::Keyword(
            KeywordKind::RecordKeyword | KeywordKind::EnumKeyword | KeywordKind::ConstantKeyword,
        ) => true,
        TokenKind::Identifier => {
            let word = context.token_text(next);
            matches!(
                pseudolearn_syntax::contextual_identity(
                    &context.profile.fold_word(word),
                    context.profile.as_str()
                ),
                Some("interfaceKeyword" | "variantKeyword")
            )
        }
        _ => false,
    };
    let span = context.tree.tokens.span(slot)?;
    declares_type.then(|| (role("moduleUnit", "pgl02_type_visibility"), span))
}
