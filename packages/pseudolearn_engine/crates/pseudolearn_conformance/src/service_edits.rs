use crate::service_edit_request::edits_of;
use crate::service_request::{ServiceRequest, seed_of, strings_of};
use pseudolearn_api::service::edit_probe::{
    identity_stable, incremental_matches_cold, unit_local_edit,
};
use pseudolearn_api::service::{IdentityCheck, IncrementalProbe};
use serde_json::{Value, json};

pub fn handle_incremental(request: &ServiceRequest<'_>) -> Value {
    let mut session = request.session();
    let report = session.apply_text_edits(&edits_of(request));
    match request.text("comprobacion") {
        "equivalencia_frio" => json!({ "coincide_con_frio": session.matches_cold_analysis() }),
        "reutilizacion_unidades" => {
            json!({ "sin_cambios": report.unchanged_count, "afectadas": report.affected_count })
        }
        "invalidation_firma" => json!({ "invalido_firmas": report.signature_invalidated }),
        "estado_incompleto" => {
            let known: Vec<&str> = session
                .analysis
                .symbols
                .iter()
                .map(|symbol| symbol.name.as_str())
                .collect();
            let kept = strings_of(request, "simbolos")
                .iter()
                .all(|name| known.contains(&name.as_str()));
            json!({ "simbolos_previos_conservados": kept && !session.diagnostics().is_empty() })
        }
        other => json!({ "error": format!("unsupported check: {other}") }),
    }
}

pub fn handle_node_identity(request: &ServiceRequest<'_>) -> Value {
    let check = match request.text("comprobacion") {
        "unidades_vecinas_estables" | "otras_unidades_invariantes" => IdentityCheck::NeighbourUnits,
        "sentencias_previas_estables" => IdentityCheck::PreviousStatements,
        "nodos_semanticos_estables" => IdentityCheck::SemanticNodes,
        other => return json!({ "error": format!("unsupported check: {other}") }),
    };
    let Some(edit) = edits_of(request).into_iter().next() else {
        return json!({ "error": "missing edit" });
    };
    let stable = identity_stable(request.text("documento"), &edit, check, request.profile());
    json!({ "conservados": stable })
}

pub fn handle_random_probe(request: &ServiceRequest<'_>) -> Value {
    let program = request.text("documento");
    match request.text("comprobacion") {
        "incremental_frio" => json!({
            "coincide_con_frio": incremental_matches_cold(
                program,
                IncrementalProbe {
                    profile: request.profile(),
                    strict: request.strict(),
                    seed: seed_of(request),
                    steps: 8,
                })
        }),
        "identidad_local" => match unit_local_edit(program, request.profile(), seed_of(request)) {
            Some(edit) => json!({
                "aplicable": true,
                "conservados": identity_stable(
                    program, &edit, IdentityCheck::NeighbourUnits, request.profile())
            }),
            None => json!({ "aplicable": false }),
        },
        other => json!({ "error": format!("unsupported probe: {other}") }),
    }
}
