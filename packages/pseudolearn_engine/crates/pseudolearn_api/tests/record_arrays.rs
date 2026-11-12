use pseudolearn_api::{ExecuteRequest, ExecuteResponse, execute_program};

const POINT: &str = "record Point\ndefine x, y as integer;\nendRecord\n";
const MIXED: &str = "record Mixed\ndefine id as integer;\ndefine ratio as real;\ndefine label as string;\nendRecord\n";

fn run(program: String) -> ExecuteResponse {
    execute_program(&ExecuteRequest {
        program,
        profile: "en".to_owned(),
        gc_stress: true,
        ..Default::default()
    })
}

fn report(response: &ExecuteResponse) -> String {
    format!("{:?} {:?}", response.diagnostics, response.termination)
}

#[test]
fn elements_are_written_and_read_as_whole_records_and_by_leaf() {
    let program = format!(
        "{POINT}algorithm P\ndimension a[3] as Point;\na[0] <- Point(1, 2);\na[1] <- Point(3, 4);\na[2].x <- 5;\na[2].y <- 6;\nwrite a[0].x + a[1].y + a[2].x;\ndefine q as Point <- a[1];\nwrite q.x;\nwrite a[1] = Point(3, 4);\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "10\n3\ntrue\n", "{}", report(&response));
}

#[test]
fn reading_an_element_copies_it_independently() {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[0] <- Point(1, 2);\ndefine q as Point <- a[0];\nq.x <- 99;\nwrite a[0].x;\na[1] <- q;\nq.y <- 77;\nwrite a[1].y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "1\n2\n", "{}", report(&response));
}

#[test]
fn an_array_passed_to_a_subroutine_shares_its_elements() {
    let program = format!(
        "{POINT}subroutine Fill(items[] as Point)\nitems[0] <- Point(7, 8);\nitems[1].y <- 9;\nendSubroutine\nalgorithm P\ndimension a[2] as Point;\na[1] <- Point(1, 1);\nFill(a);\nwrite a[0].x;\nwrite a[1].y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "7\n9\n", "{}", report(&response));
}

#[test]
fn leaves_of_different_kinds_live_in_one_record_array() {
    let program = format!(
        "{MIXED}algorithm P\ndimension a[2] as Mixed;\na[0] <- Mixed(1, 2.5, \"one\");\na[1] <- Mixed(2, 3.5, \"two\");\nwrite a[1].label;\nwrite a[0].ratio + a[1].ratio;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "two\n6.0\n", "{}", report(&response));
}

#[test]
fn a_leaf_of_an_unset_element_is_trapped_when_read() {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[0].x <- 1;\nwrite a[0].x;\nwrite a[0].y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "1\n", "{}", report(&response));
    assert_eq!(
        response.termination.get("kind"),
        Some(&serde_json::json!("failed"))
    );
}

#[test]
fn an_out_of_range_index_traps_before_any_leaf_is_touched() {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[2] <- Point(1, 1);\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(
        response.termination.get("kind"),
        Some(&serde_json::json!("failed"))
    );
}

#[test]
fn a_two_dimensional_array_of_records_is_addressed_by_both_indices() {
    let program = format!(
        "{POINT}algorithm P\ndimension grid[2, 2] as Point;\ngrid[1, 0] <- Point(4, 5);\nwrite grid[1, 0].y;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "5\n", "{}", report(&response));
}

#[test]
fn an_element_can_be_passed_by_reference() {
    let program = format!(
        "{POINT}subroutine Bump(p as Point by reference)\np.x <- p.x + 1;\nendSubroutine\nalgorithm P\ndimension a[2] as Point;\na[1] <- Point(1, 1);\nBump(a[1]);\nwrite a[1].x;\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "2\n", "{}", report(&response));
}

#[test]
fn a_single_field_record_array_works() {
    let program = "record One\ndefine v as integer;\nendRecord\nalgorithm P\ndimension a[1] as One;\na[0] <- One(3);\nwrite a[0].v;\nendAlgorithm\n".to_owned();
    let response = run(program);
    assert_eq!(response.output, "3\n", "{}", report(&response));
}

#[test]
fn a_for_each_binding_receives_a_copy_of_every_record_element() {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[0] <- Point(1, 2);\na[1] <- Point(3, 4);\nfor each p in a do\nwrite p.x + p.y;\nendFor\nendAlgorithm\n"
    );
    let response = run(program);
    assert_eq!(response.output, "3\n7\n", "{}", report(&response));
}
