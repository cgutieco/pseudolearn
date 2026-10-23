use crate::service_request::{ServiceRequest, position_of, strings_of};
use pseudolearn_api::service::{
    CompletionEntry, HelpCertainty, HelpIdentityKind, HelpLocale, HighlightKind, Range,
    resolve_help_at_position, resolve_help_with_locale,
};
use serde_json::{Map, Value, json};

fn range_json(range: Range) -> Value {
    json!({
        "start": { "line": range.start.line, "column": range.start.column },
        "end": { "line": range.end.line, "column": range.end.column }
    })
}

pub fn handle_completion(request: &ServiceRequest<'_>) -> Value {
    let candidates = request
        .session()
        .queries()
        .complete_with_edit(position_of(request))
        .entries;
    let labels: Vec<&str> = candidates
        .iter()
        .map(|entry| entry.label.as_str())
        .collect();
    match request.text("proyeccion") {
        "contiene" => project_membership(request, &labels),
        "primer_candidato" => match labels.first() {
            Some(label) => json!({ "primer_candidato": label }),
            None => json!({}),
        },
        "sugerencia_bilingue" => project_bilingual_hint(&candidates),
        "detalle" => project_detail(&candidates, request.text("candidato")),
        "en_linea" => project_inline(&candidates),
        "vacio" => json!({ "vacio": candidates.is_empty() }),
        "rango" => {
            let wanted = request.text("esperado");
            let rank = labels
                .iter()
                .position(|label| *label == wanted)
                .map_or(0, |slot| slot.saturating_add(1));
            json!({ "rango": rank })
        }
        "determinista" => {
            let again = request
                .session()
                .queries()
                .complete_with_edit(position_of(request))
                .entries;
            json!({ "determinista": !candidates.is_empty() && again == candidates })
        }
        other => json!({ "error": format!("unsupported projection: {other}") }),
    }
}

fn project_membership(request: &ServiceRequest<'_>, labels: &[&str]) -> Value {
    let present: Vec<String> = strings_of(request, "contiene")
        .into_iter()
        .filter(|name| labels.contains(&name.as_str()))
        .collect();
    let absent: Vec<String> = strings_of(request, "excluye")
        .into_iter()
        .filter(|name| !labels.contains(&name.as_str()))
        .collect();
    json!({ "contiene": present, "excluye": absent })
}

fn project_detail(candidates: &[CompletionEntry], wanted: &str) -> Value {
    let found = candidates.iter().find(|entry| entry.label == wanted);
    match found.and_then(|entry| entry.detail_key.as_ref().map(|key| (entry, key))) {
        Some((entry, key)) => json!({
            "detalle": {
                "etiqueta": entry.label,
                "clave": key,
                "argumentos": entry.detail_arguments
            }
        }),
        None => json!({}),
    }
}

fn project_inline(candidates: &[CompletionEntry]) -> Value {
    match candidates.iter().find(|entry| entry.inline) {
        Some(entry) => json!({ "en_linea": entry.label }),
        None => json!({ "en_linea": null }),
    }
}

fn project_bilingual_hint(candidates: &[CompletionEntry]) -> Value {
    let hint = candidates.iter().find_map(|entry| {
        entry
            .bilingual_origin
            .as_ref()
            .map(|origin| (&entry.label, origin))
    });
    match hint {
        Some((label, origin)) => {
            json!({ "sugerencia_bilingue": { "etiqueta": label, "origen": origin } })
        }
        None => json!({}),
    }
}

pub fn handle_hover(request: &ServiceRequest<'_>) -> Value {
    if request.text("proyeccion") == "resolucion" {
        return project_resolution(request);
    }
    if request.text("proyeccion") == "descripcion" {
        return project_description(request);
    }
    let Some(outcome) = request.session().queries().hover(position_of(request)) else {
        return json!({});
    };
    match request.text("proyeccion") {
        "tipo" => json!({ "tipo": outcome.type_name, "inferido": outcome.is_inferred }),
        "intrinseca" => {
            json!({ "es_intrinseca": outcome.is_intrinsic, "identificador": outcome.identifier })
        }
        other => json!({ "error": format!("unsupported projection: {other}") }),
    }
}

fn project_description(request: &ServiceRequest<'_>) -> Value {
    let document = request.session();
    let locale = HelpLocale::from_code(request.text("idioma"))
        .unwrap_or_else(|| HelpLocale::from_profile(request.profile()));
    let description = resolve_help_with_locale(&document, position_of(request), locale)
        .and_then(|outcome| outcome.hover)
        .and_then(|hover| hover.description);
    match description {
        Some(text) => json!({ "descripcion": text }),
        None => json!({}),
    }
}

fn project_resolution(request: &ServiceRequest<'_>) -> Value {
    let document = request.session();
    let Some(outcome) = resolve_help_at_position(&document, position_of(request)) else {
        return json!({ "resolucion": null });
    };
    let resolution = outcome.resolution;
    let mut value = Map::new();
    value.insert(
        "certainty".to_owned(),
        json!(match resolution.certainty {
            HelpCertainty::Certain => "certain",
            HelpCertainty::Partial => "partial",
        }),
    );
    if let Some(identity) = resolution.identity {
        value.insert(
            "identity".to_owned(),
            json!({
                "kind": identity_kind_name(identity.kind),
                "id": identity.id,
                "role": identity.role
            }),
        );
    }
    if let Some(symbol) = resolution.symbol {
        value.insert(
            "symbol".to_owned(),
            json!({
                "category": symbol.category,
                "identifier": symbol.identifier
            }),
        );
    }
    json!({ "resolucion": value })
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

pub fn handle_signature_help(request: &ServiceRequest<'_>) -> Value {
    match request
        .session()
        .queries()
        .signature_help(position_of(request))
    {
        Some(help) => json!({ "parametro_activo": help.active_parameter, "firma": help.signature }),
        None => json!({}),
    }
}

pub fn handle_definition(request: &ServiceRequest<'_>) -> Value {
    match request.session().queries().definition(position_of(request)) {
        Some(range) => json!({ "definicion": range_json(range) }),
        None => json!({}),
    }
}

pub fn handle_references(request: &ServiceRequest<'_>) -> Value {
    let ranges: Vec<Value> = request
        .session()
        .queries()
        .references(position_of(request))
        .into_iter()
        .map(range_json)
        .collect();
    json!({ "referencias": ranges })
}

pub fn handle_highlight(request: &ServiceRequest<'_>) -> Value {
    let entries: Vec<Value> = request
        .session()
        .queries()
        .highlights(position_of(request))
        .into_iter()
        .map(|entry| {
            let kind = match entry.kind {
                HighlightKind::Read => "read",
                HighlightKind::Write => "write",
            };
            json!({ "rango": range_json(entry.range), "tipo": kind })
        })
        .collect();
    json!({ "destacados": entries })
}
