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

fn completed(response: &ExecuteResponse) -> bool {
    response.termination.get("kind") == Some(&serde_json::json!("completed"))
}

#[test]
fn a_class_field_holds_a_record_and_exposes_its_leaves() {
    let program = format!(
        "{POINT}class Holder\npublic define p as Point;\nmethod constructor()\nthis.p <- Point(1, 2);\nendMethod\nendClass\nalgorithm P\ndefine h as Holder <- new Holder();\nwrite h.p.x;\nh.p.y <- 9;\nwrite h.p.y;\ndefine q as Point <- h.p;\nwrite q.x + q.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "1\n9\n10\n", "{:?}", response.diagnostics);
    assert!(completed(&response));
}

#[test]
fn assigning_a_record_copies_it_by_value() {
    let program = format!(
        "{POINT}class Holder\npublic define p as Point;\nmethod constructor()\nthis.p <- Point(1, 2);\nendMethod\nendClass\nalgorithm P\ndefine h as Holder <- new Holder();\ndefine q as Point <- h.p;\nq.x <- 50;\nwrite h.p.x;\nh.p <- q;\nq.x <- 60;\nwrite h.p.x;\nwrite h.p = q;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(
        response.output, "1\n50\nfalse\n",
        "{:?}",
        response.diagnostics
    );
}

#[test]
fn a_subclass_uses_a_record_field_of_its_base_and_copy_duplicates_it() {
    let program = format!(
        "{POINT}class Base\npublic define p as Point;\nmethod constructor()\nthis.p <- Point(3, 4);\nendMethod\nendClass\nclass Derived extends Base\npublic method Sum() as integer\nreturn this.p.x + this.p.y;\nendMethod\nendClass\nalgorithm P\ndefine d as Derived <- new Derived();\ndefine c as Derived <- copy(d);\nc.p.x <- 100;\nwrite d.Sum();\nwrite c.Sum();\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "7\n104\n", "{:?}", response.diagnostics);
}

#[test]
fn a_nested_record_field_is_addressed_through_every_level() {
    let program = format!(
        "{POINT}record Line\ndefine a, b as Point;\nendRecord\nclass Holder\npublic define l as Line;\nmethod constructor()\nthis.l <- Line(Point(1, 2), Point(3, 4));\nendMethod\nendClass\nalgorithm P\ndefine h as Holder <- new Holder();\nh.l.b.y <- 8;\nwrite h.l.a.x + h.l.b.y;\nh.l.a <- Point(5, 6);\nwrite h.l.a.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "9\n6\n", "{:?}", response.diagnostics);
}

#[test]
fn a_record_field_cannot_be_named_twice() {
    let program = format!(
        "{POINT}class Holder\npublic define p as Point;\npublic define p as Point;\nendClass\nalgorithm P\nendAlgorithm\n"
    );
    let response = run(program);
    assert!(
        response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "duplicateMember")
    );
}
