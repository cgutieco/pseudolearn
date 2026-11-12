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
fn a_method_receives_and_returns_a_record() {
    let program = format!(
        "{POINT}class Mover\npublic method Shift(p as Point) as Point\nreturn Point(p.x + 1, p.y + 2);\nendMethod\nendClass\nalgorithm P\ndefine m as Mover <- new Mover();\ndefine q as Point <- m.Shift(Point(1, 1));\nwrite q.x;\nwrite q.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "2\n3\n", "{:?}", response.diagnostics);
    assert!(completed(&response));
}

#[test]
fn an_override_keeps_the_record_signature_through_virtual_dispatch() {
    let program = format!(
        "{POINT}class Base\npublic method Move(p as Point) as Point\nreturn p;\nendMethod\nendClass\nclass Derived extends Base\npublic method Move(p as Point) as Point\nreturn Point(p.x * 10, p.y * 10);\nendMethod\nendClass\nalgorithm P\ndefine item as Base <- new Derived();\ndefine q as Point <- item.Move(Point(1, 2));\nwrite q.x;\nwrite q.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "10\n20\n", "{:?}", response.diagnostics);
}

#[test]
fn a_constructor_and_super_call_accept_a_record_parameter() {
    let program = format!(
        "{POINT}class Base\nprivate define sum as integer;\nmethod constructor(p as Point)\nthis.sum <- p.x + p.y;\nendMethod\npublic method Sum() as integer\nreturn this.sum;\nendMethod\nendClass\nclass Derived extends Base\nmethod constructor(p as Point)\nsuper.constructor(p);\nendMethod\nendClass\nalgorithm P\ndefine d as Derived <- new Derived(Point(3, 4));\nwrite d.Sum();\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "7\n", "{:?}", response.diagnostics);
}

#[test]
fn an_interface_signature_may_use_records() {
    let program = format!(
        "{POINT}interface Mapper\nmethod Map(p as Point) as Point;\nendInterface\nclass Doubler implements Mapper\npublic method Map(p as Point) as Point\nreturn Point(p.x * 2, p.y * 2);\nendMethod\nendClass\nalgorithm P\ndefine d as Doubler <- new Doubler();\ndefine q as Point <- d.Map(Point(5, 6));\nwrite q.x;\nwrite q.y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "10\n12\n", "{:?}", response.diagnostics);
}

#[test]
fn a_mismatched_record_argument_is_rejected() {
    let program = format!(
        "{POINT}record Other\ndefine x, y as integer;\nendRecord\nclass Mover\npublic method Shift(p as Point) as Point\nreturn p;\nendMethod\nendClass\nalgorithm P\ndefine m as Mover <- new Mover();\ndefine q as Point <- m.Shift(Other(1, 1));\nendAlgorithm\n"
    );
    let response = run(program);
    assert!(!completed(&response));
    assert!(!response.diagnostics.is_empty());
}
