use crate::errors::ApiError;
use crate::execution_resource::usage;
use crate::model::{
    ApiHelpCoordinateUnit, ApiHelpDetail, ApiHelpEntry, ApiHelpIdentity, ApiHelpQueryPosition,
    ApiHelpQueryRequest, ApiHelpQueryResponse, ApiHelpResolution, ApiHelpSymbol, ApiPosition,
    ApiSpan,
};
use crate::resources::{ApiSession, Resource};
use crate::service_help_card;
use pseudolearn_service::{
    HelpCertainty, HelpIdentityKind, HelpLocale, HelpResolution, HoverCategory, HoverOutcome,
    Position, Range, help_content, resolve_help_with_locale,
};
use serde_json::{Value, json};

pub(crate) fn query(session: &ApiSession, arguments: &Value) -> Result<Value, ApiError> {
    let request = parse_request(arguments)?;
    let revision = parse_revision(&request.revision)?;
    let Some(Resource::Editing(editing)) = session.resources.get(&request.resource) else {
        return Err(usage("invalid edit session"));
    };
    if editing.revision != revision {
        return Ok(json!({"stale_revision": editing.revision.to_string()}));
    }
    let position = resolve_position(editing.document.text(), &request.position)?;
    let locale =
        HelpLocale::from_code(&request.language).ok_or_else(|| usage("invalid help language"))?;
    let query = resolve_help_with_locale(&editing.document, position, locale);
    let resolution = query
        .as_ref()
        .map(|outcome| api_resolution(&outcome.resolution));
    let help = query
        .as_ref()
        .and_then(|outcome| outcome.hover.clone())
        .map(|outcome| entry(outcome, request.detail));
    let card = query
        .as_ref()
        .and_then(|outcome| help_content(outcome, locale))
        .map(|content| service_help_card::card(&content, request.detail));
    let response = ApiHelpQueryResponse {
        revision: editing.revision.to_string(),
        language: request.language,
        detail: request.detail,
        position: request.position,
        resolution,
        help,
        card,
    };
    serde_json::to_value(response).map_err(serialization)
}

fn parse_request(arguments: &Value) -> Result<ApiHelpQueryRequest, ApiError> {
    let request: ApiHelpQueryRequest =
        serde_json::from_value(arguments.clone()).map_err(|_| usage("invalid help query"))?;
    if !matches!(request.language.as_str(), "es" | "en") {
        return Err(usage("invalid help language"));
    }
    Ok(request)
}

fn parse_revision(value: &str) -> Result<u64, ApiError> {
    let revision = value
        .parse::<u64>()
        .map_err(|_| usage("invalid revision"))?;
    if revision.to_string() != value {
        return Err(usage("invalid revision"));
    }
    Ok(revision)
}

fn resolve_position(source: &str, position: &ApiHelpQueryPosition) -> Result<Position, ApiError> {
    if position.line == 0 || position.column == 0 {
        return Err(usage("invalid help position"));
    }
    match position.unit {
        ApiHelpCoordinateUnit::UnicodeScalar => scalar_position(source, position),
        ApiHelpCoordinateUnit::Utf16 => utf16_position(source, position),
    }
}

fn scalar_position(source: &str, position: &ApiHelpQueryPosition) -> Result<Position, ApiError> {
    let service_position = Position {
        line: position.line,
        column: position.column,
    };
    let offset = pseudolearn_service::positions::offset_at(source, service_position);
    if pseudolearn_service::positions::position_at(source, offset) != service_position {
        return Err(usage("help position is outside the document line"));
    }
    Ok(service_position)
}

fn utf16_position(source: &str, position: &ApiHelpQueryPosition) -> Result<Position, ApiError> {
    let line = position.line.saturating_sub(1);
    let column = position.column.saturating_sub(1);
    let offset = pseudolearn_service::positions::offset_from_lsp(source, line, column);
    if pseudolearn_service::positions::lsp_position_at(source, offset) != (line, column) {
        return Err(usage("help position is not a UTF-16 boundary"));
    }
    Ok(pseudolearn_service::positions::position_at(source, offset))
}

fn entry(outcome: HoverOutcome, detail: ApiHelpDetail) -> ApiHelpEntry {
    let complete = detail == ApiHelpDetail::Full;
    ApiHelpEntry {
        category: category_name(outcome.category).to_owned(),
        identifier: outcome.identifier,
        type_name: complete.then_some(outcome.type_name),
        is_inferred: complete.then_some(outcome.is_inferred),
        is_intrinsic: complete.then_some(outcome.is_intrinsic),
        signature: if complete { outcome.signature } else { None },
        description: if complete { outcome.description } else { None },
    }
}

fn api_resolution(outcome: &HelpResolution) -> ApiHelpResolution {
    ApiHelpResolution {
        identity: outcome.identity.as_ref().map(|identity| ApiHelpIdentity {
            kind: identity_kind_name(identity.kind).to_owned(),
            id: identity.id.clone(),
            role: identity.role.clone(),
        }),
        symbol: outcome.symbol.as_ref().map(|symbol| ApiHelpSymbol {
            category: symbol.category.clone(),
            identifier: symbol.identifier.clone(),
        }),
        certainty: match outcome.certainty {
            HelpCertainty::Certain => "certain",
            HelpCertainty::Partial => "partial",
        }
        .to_owned(),
        lexical_range: api_span(outcome.lexical_range),
        enclosing_range: outcome.enclosing_range.map(api_span),
    }
}

fn identity_kind_name(kind: HelpIdentityKind) -> &'static str {
    match kind {
        HelpIdentityKind::Keyword => "keyword",
        HelpIdentityKind::Operator => "operator",
        HelpIdentityKind::Builtin => "builtin",
        HelpIdentityKind::Construction => "construction",
        HelpIdentityKind::Role => "role",
        HelpIdentityKind::Type => "type",
    }
}

fn api_span(range: Range) -> ApiSpan {
    ApiSpan::new(
        ApiPosition {
            line: range.start.line,
            column: range.start.column,
        },
        ApiPosition {
            line: range.end.line,
            column: range.end.column,
        },
    )
}

fn category_name(category: HoverCategory) -> &'static str {
    match category {
        HoverCategory::Variable => "variable",
        HoverCategory::Parameter => "parameter",
        HoverCategory::Field => "field",
        HoverCategory::Function => "function",
        HoverCategory::Procedure => "procedure",
        HoverCategory::Method => "method",
        HoverCategory::Class => "class",
        HoverCategory::Builtin => "builtin",
        HoverCategory::Keyword => "keyword",
    }
}

fn serialization(error: serde_json::Error) -> ApiError {
    ApiError::SerializationFailure(error.to_string())
}
