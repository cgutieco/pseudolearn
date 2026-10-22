use crate::errors::ApiError;
use crate::execution_resource::usage;
use crate::model::{
    ApiHelpCoordinateUnit, ApiHelpDetail, ApiHelpEntry, ApiHelpQueryPosition, ApiHelpQueryRequest,
    ApiHelpQueryResponse,
};
use crate::resources::{ApiSession, Resource};
use pseudolearn_service::{HoverCategory, HoverOutcome, Position};
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
    let help = editing
        .document
        .queries()
        .hover(position)
        .map(|outcome| entry(outcome, request.detail));
    let response = ApiHelpQueryResponse {
        revision: editing.revision.to_string(),
        language: request.language,
        detail: request.detail,
        position: request.position,
        help,
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
    }
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
