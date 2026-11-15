use pseudolearn_api::{ExecuteRequest, ExecuteResponse, execute_program};
use serde_json::json;

fn execute(body: &str) -> ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: format!("algorithm P\n{body}endAlgorithm\n"),
        profile: "en".to_owned(),
        ..Default::default()
    })
}

#[test]
fn text_queries_answer_over_runtime_texts() {
    let response = execute(
        "define word as string <- padLeft(\"b\", 4, \"😀\");\nwrite startsWith(word, \"😀😀\"), \":\", endsWith(word, \"😀b\"), \":\", contains(word, \"b\"), \":\", substring(word, 2, 3);\nswitch indexOf(word, \"b\") do\nnone: write -1;\nsome(position): write position;\nendSwitch\n",
    );
    assert_eq!(response.termination, json!({"kind": "completed"}));
    assert_eq!(response.output, "true:true:true:😀b\n3\n");
}

#[test]
fn empty_parts_and_empty_slices_are_accepted() {
    let response = execute(
        "define word as string <- padLeft(\"\", 0, \"a\");\nwrite startsWith(word, \"\"), endsWith(word, \"\"), contains(word, \"\"), length(substring(word, 0, -1));\n",
    );
    assert_eq!(response.termination, json!({"kind": "completed"}));
    assert_eq!(response.output, "truetruetrue0\n");
}

#[test]
fn an_out_of_range_slice_still_reports_the_breaking_position() {
    let response = execute(
        "define word as string <- padLeft(\"c\", 3, \"a\");\nwrite substring(word, 1, 7);\n",
    );
    assert_eq!(
        response.termination,
        json!({"kind": "failed", "code": "stringPositionOutOfRange"})
    );
    let arguments = response.diagnostics.first().map(|found| &found.arguments);
    assert_eq!(
        arguments.and_then(|found| found.get("position")),
        Some(&json!(7))
    );
    assert_eq!(
        arguments.and_then(|found| found.get("length")),
        Some(&json!(3))
    );
}
