use pseudolearn_api::{ExecuteRequest, ExecuteResponse, execute_program};
use serde_json::json;

fn run(program: String) -> ExecuteResponse {
    execute_program(&ExecuteRequest {
        program,
        profile: "en".to_owned(),
        gc_stress: true,
        ..Default::default()
    })
}

fn wide_record(leaves: usize) -> String {
    let fields = (0..leaves)
        .map(|index| format!("f{index}"))
        .collect::<Vec<_>>()
        .join(", ");
    format!("record Wide\ndefine {fields} as integer;\nendRecord\n")
}

fn codes(response: &ExecuteResponse) -> Vec<String> {
    response
        .diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code.clone())
        .collect()
}

fn completed(response: &ExecuteResponse) -> bool {
    response.termination.get("kind") == Some(&json!("completed"))
}

#[test]
fn a_record_at_the_array_leaf_limit_works_as_an_element() {
    let program = format!(
        "{}algorithm P\ndimension a[2] as Wide;\na[1].f7 <- 5;\nwrite a[1].f7;\nendAlgorithm\n",
        wide_record(1_024)
    );
    let response = run(program);
    assert_eq!(response.output, "5\n", "{:?}", codes(&response));
    assert!(completed(&response));
}

#[test]
fn a_record_over_the_array_leaf_limit_is_rejected_as_an_element() {
    let program = format!(
        "{}algorithm P\ndimension a[2] as Wide;\nendAlgorithm\n",
        wide_record(1_025)
    );
    assert_eq!(codes(&run(program)), vec!["recordArrayTooWide".to_owned()]);
}

#[test]
fn a_record_over_the_array_leaf_limit_is_rejected_as_an_array_parameter() {
    let program = format!(
        "{}subroutine Take(items[] as Wide)\nendSubroutine\nalgorithm P\nendAlgorithm\n",
        wide_record(1_025)
    );
    assert!(codes(&run(program)).contains(&"recordArrayTooWide".to_owned()));
}

#[test]
fn a_record_with_the_maximum_leaves_works_as_a_class_field() {
    let program = format!(
        "{}class Holder\npublic define w as Wide;\nendClass\nalgorithm P\ndefine h as Holder <- new Holder();\nh.w.f7 <- 5;\nwrite h.w.f7;\nendAlgorithm\n",
        wide_record(65_535)
    );
    let response = run(program);
    assert_eq!(response.output, "5\n", "{:?}", codes(&response));
    assert!(completed(&response));
}

#[test]
fn an_invalid_element_index_fails_before_the_by_reference_call_runs() {
    let program = "record Point\ndefine x, y as integer;\nendRecord\nsubroutine Move(p as Point by reference)\nwrite 9;\nendSubroutine\nalgorithm P\ndimension a[2] as Point;\nwrite 1;\nMove(a[5]);\nwrite 2;\nendAlgorithm\n".to_owned();
    let response = run(program);
    assert_eq!(response.output, "1\n");
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("failed")),
        "{:?}",
        response.termination
    );
}

#[test]
fn a_closure_over_an_object_passes_and_returns_a_record_through_a_method() {
    let program = "record Point\ndefine x, y as integer;\nendRecord\nclass Mirror\npublic method Flip(p as Point) as Point\nreturn Point(p.y, p.x);\nendMethod\nendClass\nalgorithm P\ndefine m as Mirror <- new Mirror();\ndefine flip as subroutine(Point) as Point <- subroutine(p as Point) as Point\nreturn m.Flip(p);\nendSubroutine;\ndefine r as Point <- flip(Point(1, 2));\nwrite r.x;\nwrite r.y;\nendAlgorithm\n".to_owned();
    let response = run(program);
    assert_eq!(response.output, "2\n1\n", "{:?}", codes(&response));
    assert!(completed(&response));
}

#[test]
fn an_object_held_by_a_record_element_stays_shared_after_the_element_is_copied() {
    let program = "class Box\npublic define n as integer;\nendClass\nrecord Slot\ndefine box as Box;\ndefine tag as integer;\nendRecord\nalgorithm P\ndimension a[2] as Slot;\ndefine b as Box <- new Box();\nb.n <- 1;\na[0] <- Slot(b, 7);\ndefine q as Slot <- a[0];\nq.box.n <- 42;\nwrite a[0].box.n;\nwrite a[0].tag;\nendAlgorithm\n".to_owned();
    let response = run(program);
    assert_eq!(response.output, "42\n7\n", "{:?}", codes(&response));
    assert!(completed(&response));
}
