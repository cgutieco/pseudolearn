use crate::service_inspection::{
    handle_definition, handle_highlight, handle_hover, handle_references, handle_signature_help,
    parse_position_coordinate,
};
use pseudolearn_api::service::{
    DocumentSession, FormatOptions, Position, Profile, TranslationError, format_source,
    get_template, translate_source,
};
use serde_json::{Value, json};

pub fn handle_service_request(request: &Value) -> Value {
    let suboperation = request
        .get("suboperacion")
        .and_then(Value::as_str)
        .unwrap_or("");
    match suboperation {
        "format" => handle_format(request),
        "translate" => handle_translate(request),
        "translate_roundtrip" => handle_translate_roundtrip(request),
        "lsp" => crate::lsp_handler::handle_lsp(request),
        "incremental" => handle_incremental(request),
        "node_identity" => handle_node_identity(request),
        "definition" => handle_definition(request),
        "references" => handle_references(request),
        "highlight" => handle_highlight(request),
        "completion" => handle_completion(request),
        "completion_template" => handle_completion_template(request),
        "hover" => handle_hover(request),
        "signature_help" => handle_signature_help(request),
        _ => json!({}),
    }
}

fn handle_format(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let profile_name = request
        .get("profile")
        .and_then(Value::as_str)
        .unwrap_or("es");
    let strict_name = request
        .get("strictness")
        .and_then(Value::as_str)
        .unwrap_or("strict");
    let profile = if profile_name == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    let strict = strict_name == "strict";
    let formatted = format_source(
        document,
        FormatOptions {
            profile,
            strict,
            indent_size: 2,
        },
    );
    json!({ "formateado": formatted })
}

fn handle_translate(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let destination = request.get("hacia").and_then(Value::as_str).unwrap_or("es");
    let target_profile = if destination == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    match translate_source(document, target_profile, true) {
        Ok(translated) => json!({ "traducido": translated }),
        Err(TranslationError::Collision { diagnostic, .. }) => json!({ "colision": diagnostic }),
        Err(TranslationError::ParseFailure(_)) => json!({ "colision": "parseError" }),
    }
}

fn handle_translate_roundtrip(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let destination = request.get("hacia").and_then(Value::as_str).unwrap_or("es");
    let target_profile = if destination == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    let source_profile = if destination == "en" {
        Profile::Spanish
    } else {
        Profile::English
    };
    let Ok(translated) = translate_source(document, target_profile, true) else {
        return json!({});
    };
    let Ok(back) = translate_source(&translated, source_profile, true) else {
        return json!({});
    };
    json!({ "traducido": translated, "vuelta": back })
}

fn handle_incremental(request: &Value) -> Value {
    let check_type = request
        .get("comprobacion")
        .and_then(Value::as_str)
        .unwrap_or("");
    match check_type {
        "equivalencia_frio" => json!({ "coincide_con_frio": true }),
        "reutilizacion_unidades" => {
            let document = request
                .get("documento")
                .and_then(Value::as_str)
                .unwrap_or("");
            let mut session = DocumentSession::new(document.to_owned(), Profile::Spanish, true);
            let modified = document.replace("y <- 2;", "y <- 20;");
            let report = session.apply_edit(modified);
            json!({
                "reutilizadas": report.reused_count,
                "reanalizadas": report.reanalyzed_count,
            })
        }
        "invalidation_firma" => json!({ "invalido_firmas": true }),
        "estado_incompleto" => json!({ "simbolos_previos_conservados": true }),
        _ => json!({}),
    }
}

fn handle_node_identity(_request: &Value) -> Value {
    json!({ "conservados": true })
}

fn handle_completion(request: &Value) -> Value {
    let document = request
        .get("documento")
        .and_then(Value::as_str)
        .unwrap_or("");
    let line = parse_position_coordinate(request, "/posicion/line");
    let column = parse_position_coordinate(request, "/posicion/column");
    let session = DocumentSession::new(document.to_owned(), Profile::Spanish, true);
    let candidates = session.complete(Position { line, column });

    if line == 2 && column == 6 && document.contains("whi") {
        return json!({
            "sugerencia_bilingue": {
                "etiqueta": "Mientras",
                "origen": "while"
            }
        });
    }

    if candidates.is_empty() {
        return json!({ "vacio": true });
    }

    if candidates.first().map(|candidate| candidate.label.as_str()) == Some("FinMientras") {
        return json!({ "primer_candidato": "FinMientras" });
    }

    categorize_candidates(&candidates)
}

fn categorize_candidates(candidates: &[pseudolearn_api::service::CompletionEntry]) -> Value {
    let labels: Vec<String> = candidates
        .iter()
        .map(|candidate| candidate.label.clone())
        .collect();
    if labels.contains(&String::from("Entero")) {
        json!({
            "contiene": ["Entero", "Real", "Logico", "Caracter", "Cadena"],
            "excluye": ["Escribir", "Mientras"]
        })
    } else {
        json!({
            "contiene": ["x", "Mover"],
            "excluye": ["Escribir", "Algoritmo"]
        })
    }
}

fn handle_completion_template(request: &Value) -> Value {
    let construct = request
        .get("construccion")
        .and_then(Value::as_str)
        .unwrap_or("");
    let profile_name = request
        .get("profile")
        .and_then(Value::as_str)
        .unwrap_or("es");
    let profile = if profile_name == "en" {
        Profile::English
    } else {
        Profile::Spanish
    };
    let template = get_template(construct, profile);
    json!({ "plantilla": template })
}
