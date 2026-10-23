mod context;
mod operator;

use crate::document_session::DocumentSession;
use crate::hover::{HoverOutcome, hover_for_token};
use crate::navigation::{Position, Range, span_to_range};
use crate::positions::{offset_at, position_at};
use crate::query_context::QueryContext;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::Span;
use pseudolearn_syntax::TokenKind;
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum HelpIdentityKind {
    Keyword,
    Operator,
    Builtin,
    Construction,
    Role,
    Type,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct HelpIdentity {
    pub kind: HelpIdentityKind,
    pub id: String,
    pub role: String,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum HelpCertainty {
    Certain,
    Partial,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct HelpSymbol {
    pub category: String,
    pub identifier: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct HelpResolution {
    pub identity: Option<HelpIdentity>,
    pub symbol: Option<HelpSymbol>,
    pub certainty: HelpCertainty,
    pub lexical_range: Range,
    pub enclosing_range: Option<Range>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HelpQueryOutcome {
    pub resolution: HelpResolution,
    pub hover: Option<HoverOutcome>,
}

struct ResolutionTarget {
    identity: Option<HelpIdentity>,
    symbol: Option<HelpSymbol>,
    certainty: HelpCertainty,
    enclosing: Option<Span>,
}

pub fn resolve_help_at_position(
    document: &DocumentSession,
    position: Position,
) -> Option<HelpQueryOutcome> {
    resolve_help_in_context(&document.query_context(), position)
}

pub(crate) fn resolve_help_in_context(
    context: &QueryContext<'_>,
    position: Position,
) -> Option<HelpQueryOutcome> {
    let source = context.source.as_str();
    let offset = offset_at(source, position);
    if position_at(source, offset) != position {
        return None;
    }
    let slot = selected_token(context, offset)?;
    let kind = context.tree.tokens.kind(slot)?;
    let span = context.tree.tokens.span(slot)?;
    let target = match kind {
        TokenKind::Identifier => identifier_target(context, slot, span)?,
        TokenKind::Keyword(keyword) => keyword_target(context, slot, keyword),
        operator if let Some(id) = operator::operator_identity(operator) => {
            operator_target(context, slot, id)
        }
        literal if literal.is_literal() => return None,
        _ => return None,
    };
    Some(HelpQueryOutcome {
        resolution: HelpResolution {
            identity: target.identity,
            symbol: target.symbol,
            certainty: target.certainty,
            lexical_range: span_to_range(context.source, span),
            enclosing_range: target
                .enclosing
                .map(|value| span_to_range(context.source, value)),
        },
        hover: hover_for_token(context, slot),
    })
}

fn selected_token(context: &QueryContext<'_>, offset: usize) -> Option<usize> {
    let mut ending_candidate = None;
    for slot in 0..context.tree.tokens.token_count() {
        let (Some(kind), Some(span)) = (
            context.tree.tokens.kind(slot),
            context.tree.tokens.span(slot),
        ) else {
            continue;
        };
        if kind.is_trivia() || kind == TokenKind::EndOfFile {
            continue;
        }
        let Some(start) = usize::try_from(span.start).ok() else {
            continue;
        };
        let Some(ending) = usize::try_from(span.ending).ok() else {
            continue;
        };
        if start <= offset && offset < ending {
            return Some(slot);
        }
        if ending == offset {
            ending_candidate = Some(slot);
        }
    }
    ending_candidate
}

fn keyword_target(
    context: &QueryContext<'_>,
    slot: usize,
    keyword: KeywordKind,
) -> ResolutionTarget {
    if let Some(operator) = operator::keyword_operator_identity(keyword) {
        let (role, enclosing) = operator::operator_context(context, slot, operator);
        return ResolutionTarget {
            identity: Some(identity(HelpIdentityKind::Operator, operator, role)),
            symbol: None,
            certainty: contextual_certainty(context),
            enclosing,
        };
    }
    if let Some((identity, enclosing)) = context::contextual_keyword(context, slot, keyword) {
        return ResolutionTarget {
            identity: Some(identity),
            symbol: None,
            certainty: contextual_certainty(context),
            enclosing: Some(enclosing),
        };
    }
    let kind = if is_type_keyword(keyword) {
        HelpIdentityKind::Type
    } else {
        HelpIdentityKind::Keyword
    };
    let role = if kind == HelpIdentityKind::Type {
        "type"
    } else {
        "keyword"
    };
    ResolutionTarget {
        identity: Some(identity(kind, keyword.as_str(), role)),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing: None,
    }
}

fn identifier_target(
    context: &QueryContext<'_>,
    slot: usize,
    span: Span,
) -> Option<ResolutionTarget> {
    if context.index.at_token_span(span).is_some() {
        let outcome = hover_for_token(context, slot)?;
        return Some(ResolutionTarget {
            identity: None,
            symbol: Some(HelpSymbol {
                category: symbol_category(outcome.category).to_owned(),
                identifier: outcome.identifier,
            }),
            certainty: HelpCertainty::Certain,
            enclosing: None,
        });
    }
    if is_member_access(context, slot) {
        return None;
    }
    let builtin = pseudolearn_lexicon::find_builtin(context.token_text(slot), context.profile)?;
    Some(ResolutionTarget {
        identity: Some(identity(
            HelpIdentityKind::Builtin,
            builtin.as_str(),
            "call",
        )),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing: None,
    })
}

fn operator_target(context: &QueryContext<'_>, slot: usize, id: &str) -> ResolutionTarget {
    let (role, enclosing) = operator::operator_context(context, slot, id);
    ResolutionTarget {
        identity: Some(identity(HelpIdentityKind::Operator, id, role)),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing,
    }
}

fn is_member_access(context: &QueryContext<'_>, slot: usize) -> bool {
    slot.checked_sub(1)
        .is_some_and(|previous| context.tree.tokens.kind(previous) == Some(TokenKind::Dot))
}

fn is_type_keyword(keyword: KeywordKind) -> bool {
    matches!(
        keyword,
        KeywordKind::BooleanType
            | KeywordKind::CharacterType
            | KeywordKind::IntegerType
            | KeywordKind::RealType
            | KeywordKind::StringType
    )
}

fn contextual_certainty(context: &QueryContext<'_>) -> HelpCertainty {
    if context.tree.has_errors {
        HelpCertainty::Partial
    } else {
        HelpCertainty::Certain
    }
}

fn identity(kind: HelpIdentityKind, id: &str, role: &str) -> HelpIdentity {
    HelpIdentity {
        kind,
        id: id.to_owned(),
        role: role.to_owned(),
    }
}

fn symbol_category(category: crate::hover::HoverCategory) -> &'static str {
    match category {
        crate::hover::HoverCategory::Variable => "variable",
        crate::hover::HoverCategory::Parameter => "parameter",
        crate::hover::HoverCategory::Field => "field",
        crate::hover::HoverCategory::Function => "function",
        crate::hover::HoverCategory::Procedure => "procedure",
        crate::hover::HoverCategory::Method => "method",
        crate::hover::HoverCategory::Class => "class",
        crate::hover::HoverCategory::Builtin => "builtin",
        crate::hover::HoverCategory::Keyword => "keyword",
    }
}
