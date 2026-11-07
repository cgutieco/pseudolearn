use reference_engine::ApiEngine;
use reference_model::{CodeEngine, ExecutionRequest, Profile};

const PROGRAM: &str = "Proceso Hola\n  Escribir \"Año: \", 2026;\nFinProceso\n";

fn request(code: &str) -> ExecutionRequest {
    ExecutionRequest {
        code: code.to_owned(),
        profile: Profile::Spanish,
        inputs: Vec::new(),
        host: None,
        trace: false,
        statement_limit: None,
        depth_limit: None,
    }
}

#[test]
fn tokenizes_with_character_offsets() {
    let tokens = ApiEngine.tokenize(PROGRAM, Profile::Spanish);
    let first = tokens.first();
    assert_eq!(first.map(|token| (token.start, token.end)), Some((0, 7)));
    assert_eq!(
        first.and_then(|token| token.keyword.clone()),
        Some("algorithm".to_owned())
    );
    let number = tokens.iter().find(|token| token.kind == "integer_literal");
    let characters: Vec<char> = PROGRAM.chars().collect();
    let text: Option<String> = number.and_then(|token| {
        characters
            .get(token.start..token.end)
            .map(|slice| slice.iter().collect())
    });
    assert_eq!(text, Some("2026".to_owned()));
}

#[test]
fn executes_a_program() {
    let report = ApiEngine.execute(&request(PROGRAM));
    assert_eq!(report.output, "Año: 2026\n");
    assert_eq!(report.termination, "completed");
    assert!(report.diagnostics.is_empty());
}

#[test]
fn reports_diagnostics_in_both_languages() {
    let report = ApiEngine.execute(&request("Proceso P\n  Escribir x;\nFinProceso\n"));
    let first = report.diagnostics.first();
    assert!(first.is_some());
    assert_ne!(
        first.map(|diagnostic| diagnostic.spanish.clone()),
        first.map(|diagnostic| diagnostic.english.clone())
    );
}

#[test]
fn traces_when_asked() {
    let mut traced = request(PROGRAM);
    traced.trace = true;
    let report = ApiEngine.execute(&traced);
    assert!(report.trace.iter().any(|record| record.class == "output"));
}

#[test]
fn rejects_an_invalid_host_document() {
    let mut invalid = request(PROGRAM);
    invalid.host = Some("{".to_owned());
    assert_eq!(ApiEngine.execute(&invalid).termination, "rejected");
}

#[test]
fn translates_and_lowers() {
    let translated = ApiEngine.translate(PROGRAM, Profile::English);
    assert!(
        translated
            .as_deref()
            .is_ok_and(|code| code.contains("Write \"Año: \""))
    );
    let lowered = ApiEngine.intermediate(PROGRAM, Profile::Spanish);
    assert!(lowered.is_ok());
    assert!(ApiEngine.intermediate("Proceso", Profile::Spanish).is_err());
}

#[test]
fn tokenizes_an_empty_text() {
    assert!(ApiEngine.tokenize("", Profile::Spanish).is_empty());
}

const RECURSION: &str = "SubProceso Bajar(n Como Entero) Como Entero\n  Si n = 0 Entonces\n    Retornar 0;\n  FinSi\n  Retornar Bajar(n - 1);\nFinSubProceso\nAlgoritmo Pila\n  Escribir Bajar(50);\nFinAlgoritmo\n";

#[test]
fn a_depth_limit_stops_a_deep_recursion() {
    let mut limited = request(RECURSION);
    limited.depth_limit = Some(10);
    let report = ApiEngine.execute(&limited);
    assert_eq!(report.termination, "failed");
    assert!(
        report
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "recursionDepthExceeded")
    );
}

#[test]
fn a_recursion_within_the_depth_limit_completes() {
    let mut limited = request(RECURSION);
    limited.depth_limit = Some(100);
    let report = ApiEngine.execute(&limited);
    assert_eq!(report.termination, "completed");
    assert_eq!(report.output, "0\n");
}
