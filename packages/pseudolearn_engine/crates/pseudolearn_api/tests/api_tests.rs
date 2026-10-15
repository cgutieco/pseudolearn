use pseudolearn_api::{AnalyzeRequest, execute_analyze};

#[test]
fn analyzes_valid_program() {
    let request = AnalyzeRequest {
        program: "Algoritmo Test\n  Definir a Como Entero\n  a <- 1\n  Escribir a\nFinAlgoritmo\n"
            .to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
    };
    let response = execute_analyze(&request);
    assert_eq!(response.kind, "analyze");
    assert!(response.tree);
    assert_eq!(response.diagnostics, Vec::new());
}

#[test]
fn reports_diagnostics_for_invalid_program() {
    let request = AnalyzeRequest {
        program: "Algoritmo Test\n  a <- 1\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
    };
    let response = execute_analyze(&request);
    assert_eq!(response.kind, "analyze");
    assert!(response.tree);
    assert!(!response.diagnostics.is_empty());
}
