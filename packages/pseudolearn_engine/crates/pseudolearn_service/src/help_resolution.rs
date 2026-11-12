mod context;
mod generic_roles;
mod identifier;
mod module_directive;
mod module_roles;
mod operator;
mod record_access_roles;
mod record_roles;
mod selection;

use crate::document_session::DocumentSession;
use crate::help_catalog::HelpLocale;
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
    pub token_identity: Option<String>,
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

pub fn resolve_help_with_locale(
    document: &DocumentSession,
    position: Position,
    locale: HelpLocale,
) -> Option<HelpQueryOutcome> {
    resolve_help_in_context(&document.localized_query_context(locale), position)
}

pub fn resolve_help_with_imports(
    document: &DocumentSession,
    position: Position,
    locale: HelpLocale,
    imported_types: &[(u32, u32)],
) -> Option<HelpQueryOutcome> {
    let mut context = document.localized_query_context(locale);
    context.imported_types = imported_types;
    resolve_help_in_context(&context, position)
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
    let slot = selection::selected_token(context, offset)?;
    let kind = context.tree.tokens.kind(slot)?;
    let span = context.tree.tokens.span(slot)?;
    let target = token_target(context, slot, kind, span)?;
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
        token_identity: selection::token_identity(context, slot, kind),
    })
}

fn token_target(
    context: &QueryContext<'_>,
    slot: usize,
    kind: TokenKind,
    span: Span,
) -> Option<ResolutionTarget> {
    match kind {
        _ if let Some(role) = module_roles::type_import(context, slot) => {
            Some(role_target(context, role))
        }
        TokenKind::Dot | TokenKind::LeftBracket | TokenKind::RightBracket => Some(role_target(
            context,
            record_access_roles::record_access(context, slot, kind)?,
        )),
        TokenKind::Identifier => identifier::target(context, slot, span),
        TokenKind::Keyword(keyword) => Some(keyword_target(context, slot, keyword)),
        operator if let Some(id) = operator::operator_identity(operator) => {
            Some(operator_target(context, slot, id))
        }
        TokenKind::BooleanLiteral(value) => Some(boolean_target(context, value)),
        _ => None,
    }
}

pub(crate) fn module_directive_context(
    context: &QueryContext<'_>,
    slot: usize,
) -> Option<(HelpIdentity, Span, &'static str)> {
    module_directive::module_directive(context, slot)
}

fn boolean_target(context: &QueryContext<'_>, value: bool) -> ResolutionTarget {
    let id = if value { "booleanTrue" } else { "booleanFalse" };
    ResolutionTarget {
        identity: Some(identity(HelpIdentityKind::Keyword, id, "literal")),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing: None,
    }
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
    if let Some((identity, enclosing)) = record_roles::record_keyword(context, slot, keyword)
        .or_else(|| public_signature(context, slot, keyword))
        .or_else(|| context::contextual_keyword(context, slot, keyword))
    {
        return ResolutionTarget {
            identity: Some(identity),
            symbol: None,
            certainty: contextual_certainty(context),
            enclosing: Some(enclosing),
        };
    }
    let (kind, role) = if is_type_keyword(keyword) {
        (HelpIdentityKind::Type, "type")
    } else {
        (HelpIdentityKind::Keyword, "keyword")
    };
    ResolutionTarget {
        identity: Some(identity(kind, keyword.as_str(), role)),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing: None,
    }
}

fn public_signature(
    context: &QueryContext<'_>,
    slot: usize,
    keyword: KeywordKind,
) -> Option<(HelpIdentity, Span)> {
    (keyword == KeywordKind::PublicVisibility)
        .then(|| module_roles::public_signature(context, slot))
        .flatten()
}

fn role_target(context: &QueryContext<'_>, role: (HelpIdentity, Span)) -> ResolutionTarget {
    ResolutionTarget {
        identity: Some(role.0),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing: Some(role.1),
    }
}

fn operator_target(context: &QueryContext<'_>, slot: usize, id: &str) -> ResolutionTarget {
    if let Some((identity, enclosing)) = generic_roles::generic_bracket(context, slot, id) {
        return ResolutionTarget {
            identity: Some(identity),
            symbol: None,
            certainty: contextual_certainty(context),
            enclosing: Some(enclosing),
        };
    }
    let (role, enclosing) = operator::operator_context(context, slot, id);
    ResolutionTarget {
        identity: Some(identity(HelpIdentityKind::Operator, id, role)),
        symbol: None,
        certainty: contextual_certainty(context),
        enclosing,
    }
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
