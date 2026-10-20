use crate::service_request::ServiceRequest;
use pseudolearn_api::service::{
    FormatOptions, Profile, TranslationError, format_source, get_template, template_parses_cleanly,
    template_stops_valid, translate_source,
};
use serde_json::{Value, json};

pub fn handle_format(request: &ServiceRequest<'_>) -> Value {
    let formatted = format_source(
        request.text("documento"),
        FormatOptions {
            profile: request.profile(),
            strict: request.strict(),
            indent_size: 2,
        },
    );
    json!({ "formateado": formatted })
}

fn destination(request: &ServiceRequest<'_>) -> Profile {
    match request.text("hacia") {
        "en" => Profile::English,
        _ => Profile::Spanish,
    }
}

pub fn handle_translate(request: &ServiceRequest<'_>) -> Value {
    match translate_source(
        request.text("documento"),
        destination(request),
        request.strict(),
    ) {
        Ok(translated) => json!({ "traducido": translated }),
        Err(TranslationError::Collision { diagnostic, .. }) => json!({ "colision": diagnostic }),
        Err(TranslationError::ParseFailure(code)) => json!({ "error_sintaxis": code }),
    }
}

pub fn handle_translate_roundtrip(request: &ServiceRequest<'_>) -> Value {
    let target = destination(request);
    let origin = match target {
        Profile::Spanish => Profile::English,
        Profile::English => Profile::Spanish,
    };
    let strict = request.strict();
    let outcome =
        translate_source(request.text("documento"), target, strict).and_then(|translated| {
            translate_source(&translated, origin, strict).map(|back| (translated, back))
        });
    match outcome {
        Ok((translated, back)) => json!({ "traducido": translated, "vuelta": back }),
        Err(TranslationError::Collision { diagnostic, .. }) => json!({ "colision": diagnostic }),
        Err(TranslationError::ParseFailure(code)) => json!({ "error_sintaxis": code }),
    }
}

pub fn handle_template(request: &ServiceRequest<'_>) -> Value {
    match get_template(request.text("construccion"), request.profile()) {
        Some(template) => json!({ "plantilla": template }),
        None => json!({}),
    }
}

pub fn handle_template_validity(request: &ServiceRequest<'_>) -> Value {
    let construction = request.text("construccion");
    let profile = request.profile();
    json!({ "valida": template_parses_cleanly(construction, profile) && template_stops_valid(construction, profile) })
}
