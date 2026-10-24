use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const SPANISH_MAIN: &str =
    "Importar app.util Como U;\nAlgoritmo P\nU.Informe();\nEscribir 1 = 1;\nFinAlgoritmo\n";
const ENGLISH_LIBRARY: &str = "public subroutine Informe()\nwrite 1 = 1;\nendSubroutine\n";
const ENGLISH_MAIN: &str =
    "import app.util as U;\nalgorithm P\nU.Informe();\nwrite 1 = 1;\nendAlgorithm\n";
const SPANISH_LIBRARY: &str = "Publico SubProceso Informe()\nEscribir 1 = 1;\nFinSubProceso\n";

fn manifest(extra: &str) -> String {
    format!(
        "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n{extra}"
    )
}

fn files(main: &str, library: &str, profiles: [Option<&str>; 2]) -> Value {
    let entry = |path: &str, id: u32, text: &str, profile: Option<&str>| {
        let mut file = json!({"path": path, "source_id": id, "text": text});
        if let (Some(name), Some(object)) = (profile, file.as_object_mut()) {
            object.insert("profile".to_owned(), json!(name));
        }
        file
    };
    json!([
        entry("app/main", 1, main, profiles[0]),
        entry("app/util", 2, library, profiles[1])
    ])
}

fn run(operation: &str, project: Value, profile: Option<&str>) -> Value {
    let mut arguments = json!({"project": project, "entry": "app/main", "strictness": "strict"});
    if let (Some(name), Some(object)) = (profile, arguments.as_object_mut()) {
        object.insert("profile".to_owned(), json!(name));
    }
    ApiSession::default().call(operation, &arguments)
}

fn with_manifest(extra: &str, files: Value) -> Value {
    json!({
        "project_id": "1",
        "revision_id": "1",
        "manifests": [{"location": "app", "text": manifest(extra)}],
        "files": files
    })
}

fn output(outcome: &Value) -> Option<&str> {
    outcome.get("value")?.get("output")?.as_str()
}

fn first_code(outcome: &Value) -> Option<&str> {
    outcome
        .get("value")?
        .get("diagnostics")?
        .get(0)?
        .get("code")?
        .as_str()
}

fn lexeme(outcome: &Value) -> Option<&str> {
    outcome
        .get("value")?
        .get("diagnostics")?
        .get(0)?
        .get("arguments")?
        .get("lexeme")?
        .as_str()
}

#[test]
fn logical_values_follow_the_profile_of_the_file_that_prints_them() {
    let project = with_manifest(
        "",
        files(SPANISH_MAIN, ENGLISH_LIBRARY, [Some("es"), Some("en")]),
    );
    assert_eq!(
        output(&run("execute_project", project, None)),
        Some("true\nVerdadero\n")
    );
    let reverse = with_manifest(
        "",
        files(ENGLISH_MAIN, SPANISH_LIBRARY, [Some("en"), Some("es")]),
    );
    assert_eq!(
        output(&run("execute_project", reverse, None)),
        Some("Verdadero\ntrue\n")
    );
}

#[test]
fn request_profile_and_interface_language_do_not_change_the_program() {
    for request in [None, Some("es"), Some("en")] {
        let project = with_manifest(
            "",
            files(SPANISH_MAIN, ENGLISH_LIBRARY, [Some("es"), Some("en")]),
        );
        let outcome = run("execute_project", project, request);
        assert_eq!(
            output(&outcome),
            Some("true\nVerdadero\n"),
            "request {request:?}"
        );
    }
}

#[test]
fn manifest_exception_overrides_the_package_profile() {
    let extra = "profile = \"en\"\n[profiles]\n\"app/util\" = \"es\"\n";
    let project = with_manifest(extra, files(ENGLISH_MAIN, SPANISH_LIBRARY, [None, None]));
    assert_eq!(
        output(&run("execute_project", project, None)),
        Some("Verdadero\ntrue\n")
    );
}

#[test]
fn file_argument_overrides_the_manifest_exception() {
    let extra = "[profiles]\n\"app/util\" = \"es\"\n";
    let project = with_manifest(
        extra,
        files(SPANISH_MAIN, ENGLISH_LIBRARY, [None, Some("en")]),
    );
    let outcome = run("execute_project", project, None);
    assert_eq!(first_code(&outcome), None, "{outcome}");
    assert_eq!(output(&outcome), Some("true\nVerdadero\n"));
}

#[test]
fn configured_profile_contradicting_the_opening_reports_both_provenances() {
    let extra = "profile = \"en\"\n";
    let project = with_manifest(
        extra,
        json!([{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}]),
    );
    let outcome = run("analyze_project", project, None);
    assert_eq!(first_code(&outcome), Some("profileMismatch"));
    assert_eq!(
        lexeme(&outcome),
        Some("en (manifest package 6:11) <> es (opening)")
    );
}

#[test]
fn contradiction_blocks_execution() {
    let project = with_manifest(
        "[profiles]\n\"app/main\" = \"en\"\n",
        json!([{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}]),
    );
    let outcome = run("execute_project", project, None);
    assert_eq!(first_code(&outcome), Some("profileMismatch"));
    assert_eq!(output(&outcome), None);
}

#[test]
fn request_profile_is_only_a_fallback_for_files_with_an_opening() {
    let project = with_manifest(
        "",
        json!([{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1 = 1;\nFinAlgoritmo\n"}]),
    );
    assert_eq!(
        output(&run("execute_project", project, Some("en"))),
        Some("Verdadero\n")
    );
}

#[test]
fn diagnostic_tokens_use_the_file_profile_and_messages_use_the_request_language() {
    let project = with_manifest(
        "",
        json!([{"path": "app/main", "source_id": 1, "text": "Algoritmo P\nDefinir Mientras Como Entero;\nFinAlgoritmo\n"}]),
    );
    let outcome = run("analyze_project", project, Some("en"));
    let diagnostic = outcome.pointer("/value/diagnostics/0");
    assert_eq!(
        diagnostic.and_then(|found| found.pointer("/arguments/token")),
        Some(&json!("Mientras"))
    );
    let message = diagnostic
        .and_then(|found| found.get("message"))
        .and_then(Value::as_str);
    assert!(
        message.is_some_and(|text| text.contains("reserved")),
        "{message:?}"
    );
}

#[test]
fn unknown_file_profile_is_a_usage_failure() {
    let project = with_manifest("", files(SPANISH_MAIN, SPANISH_LIBRARY, [Some("fr"), None]));
    let outcome = run("analyze_project", project, None);
    assert_eq!(outcome.pointer("/failure/family"), Some(&json!("usage")));
}
