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
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
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

#[test]
fn switch_cases_match_every_label_in_source_order() {
    for (selector, expected) in [(1, "0\n"), (4, "0\n"), (7, "1\n"), (8, "-1\n")] {
        let program = format!(
            "Algoritmo P\nSegun {selector} Hacer\n1, 2, 3, 4, 5:\nEscribir 0;\n6, 7:\nEscribir 1;\nDe Otro Modo:\nEscribir -1;\nFinSegun\nFinAlgoritmo\n"
        );
        let response = execute_program(&ExecuteRequest {
            program,
            profile: "es".to_owned(),
            strictness: "strict".to_owned(),
            ..Default::default()
        });
        assert_eq!(response.termination.get("kind"), Some(&json!("completed")));
        assert_eq!(response.output, expected);
    }
}

#[test]
fn subclass_methods_dispatch_through_base_type_arrays() {
    let program = "class Shape\npublic method Area() as real\nreturn 0.0;\nendMethod\nendClass\nclass Square extends Shape\nprivate define side as integer;\nmethod constructor(aSide as integer)\nthis.side <- aSide;\nendMethod\npublic method Area() as real\nreturn this.side * this.side;\nendMethod\nendClass\nclass Circle extends Shape\nprivate define radius as integer;\nmethod constructor(aRadius as integer)\nthis.radius <- aRadius;\nendMethod\npublic method Area() as real\nreturn this.radius * this.radius * 3.14;\nendMethod\nendClass\nalgorithm P\ndimension shapes[2] as Shape;\nshapes[0] <- new Square(5);\nshapes[1] <- new Circle(5);\nwrite shapes[0].Area();\nwrite shapes[1].Area();\nendAlgorithm\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "en".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "25.0\n78.5\n");
}
