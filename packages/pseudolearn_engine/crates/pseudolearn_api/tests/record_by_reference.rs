use pseudolearn_api::{ExecuteRequest, ExecuteResponse, execute_program};

const POINT: &str = "record Point\ndefine x, y as integer;\nendRecord\n";

fn run(program: String) -> ExecuteResponse {
    execute_program(&ExecuteRequest {
        program,
        profile: "en".to_owned(),
        gc_stress: true,
        ..Default::default()
    })
}

fn codes(response: &ExecuteResponse) -> Vec<String> {
    response
        .diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code.clone())
        .collect()
}

#[test]
fn a_record_variable_passed_by_reference_is_updated_in_place() {
    let program = format!(
        "{POINT}subroutine Shift(p as Point by reference)\np.x <- p.x + 10;\np.y <- 0;\nendSubroutine\nalgorithm P\ndefine q as Point <- Point(1, 2);\nShift(q);\nwrite q.x;\nwrite q.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "11\n0\n", "{:?}", codes(&response));
}

#[test]
fn a_record_field_of_an_object_passed_by_reference_is_updated_in_place() {
    let program = format!(
        "{POINT}class Holder\npublic define p as Point;\nmethod constructor()\nthis.p <- Point(1, 2);\nendMethod\nendClass\nsubroutine Reset(p as Point by reference)\np <- Point(0, 0);\nendSubroutine\nalgorithm P\ndefine h as Holder <- new Holder();\nReset(h.p);\nwrite h.p.x + h.p.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "0\n", "{:?}", codes(&response));
}

#[test]
fn a_nested_record_passed_by_reference_aliases_only_its_leaves() {
    let program = format!(
        "{POINT}record Line\ndefine a, b as Point;\nendRecord\nsubroutine Bump(p as Point by reference)\np.x <- p.x + 1;\nendSubroutine\nalgorithm P\ndefine l as Line <- Line(Point(1, 2), Point(3, 4));\nBump(l.b);\nwrite l.a.x;\nwrite l.b.x;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "1\n4\n", "{:?}", codes(&response));
}

#[test]
fn a_mismatched_record_type_by_reference_is_rejected() {
    let program = format!(
        "{POINT}record Other\ndefine x, y as integer;\nendRecord\nsubroutine Shift(p as Point by reference)\np.x <- 1;\nendSubroutine\nalgorithm P\ndefine q as Other <- Other(1, 2);\nShift(q);\nendAlgorithm\n"
    );
    let response = run(program);
    assert!(codes(&response).contains(&"byReferenceArgumentTypeMismatch".to_owned()));
}

#[test]
fn a_record_literal_cannot_be_passed_by_reference() {
    let program = format!(
        "{POINT}subroutine Shift(p as Point by reference)\np.x <- 1;\nendSubroutine\nalgorithm P\nShift(Point(1, 2));\nendAlgorithm\n"
    );
    let response = run(program);
    assert!(codes(&response).contains(&"byReferenceArgumentRequiresDesignator".to_owned()));
}

#[test]
fn a_method_receives_a_record_by_reference() {
    let program = format!(
        "{POINT}class Mover\npublic method Push(p as Point by reference)\np.x <- p.x * 2;\nendMethod\nendClass\nalgorithm P\ndefine m as Mover <- new Mover();\ndefine q as Point <- Point(4, 5);\nm.Push(q);\nwrite q.x;\nwrite q.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(
        response.output,
        "8\n5\n",
        "{:?} {:?}",
        codes(&response),
        response.termination
    );
}
