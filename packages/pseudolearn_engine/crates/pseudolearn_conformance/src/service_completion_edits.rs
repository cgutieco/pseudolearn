use crate::service_request::{ServiceRequest, position_of};
use pseudolearn_api::service::{
    Insertion, apply_change, apply_changes, build_insertion, offset_at, on_type, position_at,
    template_outline,
};
use serde_json::{Value, json};

pub fn handle_stops(request: &ServiceRequest<'_>) -> Value {
    match template_outline(request.text("construccion"), request.profile()) {
        Some(outline) => {
            let stops: Vec<Value> = outline
                .stops
                .iter()
                .map(|stop| {
                    json!({
                        "indice": stop.index,
                        "rol": stop.role.name(),
                        "marcador": stop.marker
                    })
                })
                .collect();
            json!({ "paradas": stops, "fragmento": outline.snippet })
        }
        None => json!({}),
    }
}

pub fn handle_accept(request: &ServiceRequest<'_>) -> Value {
    let session = request.session();
    let result = session.queries().complete_with_edit(position_of(request));
    let wanted = request.text("candidato");
    let Some(entry) = result.entries.iter().find(|entry| entry.label == wanted) else {
        return json!({ "error": "candidate not offered" });
    };
    let insertion = build_insertion(entry, &result.text_edit, session.text(), session.profile);
    let text = apply_change(session.text(), &insertion.edit);
    json!({
        "texto": text,
        "seleccion": selection_json(&text, &insertion)
    })
}

fn selection_json(text: &str, insertion: &Insertion) -> Value {
    let corner = |offset: usize| {
        let position = position_at(text, offset);
        json!({ "line": position.line, "column": position.column })
    };
    json!({ "inicio": corner(insertion.selection.0), "fin": corner(insertion.selection.1) })
}

pub fn handle_on_type(request: &ServiceRequest<'_>) -> Value {
    let session = request.session();
    let Some(typed) = request.text("caracter").chars().next() else {
        return json!({ "error": "missing typed character" });
    };
    let cursor = offset_at(session.text(), position_of(request));
    let outcome = on_type(&session, cursor, typed);
    let text = apply_changes(session.text(), &outcome.edits);
    let position = position_at(&text, outcome.cursor);
    json!({
        "texto": text,
        "cursor": { "line": position.line, "column": position.column }
    })
}
