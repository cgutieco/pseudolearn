use pseudolearn_api::{ApiDiagnostic, ExecuteRequest, execute_program};
use serde_json::json;

fn inference_request(state_at: Option<usize>) -> ExecuteRequest {
    ExecuteRequest {
        program: "algorithm P\nvalue <- 1;\nwrite value;\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        strictness: "flexible".to_owned(),
        state_at,
        ..Default::default()
    }
}

fn has_inference_warning(diagnostics: &[ApiDiagnostic]) -> bool {
    diagnostics.iter().any(|diagnostic| {
        diagnostic.code == "undeclaredVariable" && diagnostic.severity == "warning"
    })
}

#[test]
fn execution_preserves_analysis_warnings_on_bulk_path() {
    let response = execute_program(&inference_request(None));

    assert!(has_inference_warning(&response.diagnostics));
    assert_eq!(response.output, "1\n");
    assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
}

#[test]
fn execution_preserves_analysis_warnings_on_stepped_path() {
    let response = execute_program(&inference_request(Some(0)));

    assert!(has_inference_warning(&response.diagnostics));
    assert_eq!(response.output, "1\n");
    assert!(response.state_at.is_some());
}

#[test]
fn execution_rejects_programs_with_analysis_errors() {
    let mut request = inference_request(None);
    request.strictness = "strict".to_owned();
    let response = execute_program(&request);

    assert_eq!(response.termination.get("kind"), Some(&json!("failed")));
    assert!(
        response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "undeclaredVariable")
    );
}

#[test]
fn cell_backed_accumulators_survive_loop_joins() {
    let program = "SubProceso Change(value Como Entero Por Referencia)\nvalue <- value + 7;\nFinSubProceso\nAlgoritmo Cells\nDefinir index, sum Como Entero;\nsum <- 0;\nPara index <- 1 Hasta 4 Con Paso 1 Hacer\nsum <- sum + index;\nFinPara\nChange(sum);\nEscribir sum;\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "17\n");
}
