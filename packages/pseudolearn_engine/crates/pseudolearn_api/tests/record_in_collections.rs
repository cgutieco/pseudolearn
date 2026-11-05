use pseudolearn_api::{ExecuteRequest, execute_program};

#[test]
fn a_vector_of_records_stores_independent_copies() {
    let program = "record Point\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine values as vector<Point> <- vector();\ndefine mutable p as Point <- Point(1, 2);\nvalues.append(p);\np.x <- 9;\nwrite values[0].x;\nwrite p.x;\nendAlgorithm\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "en".to_owned(),
        gc_stress: true,
        ..Default::default()
    });
    assert_eq!(response.output, "1\n9\n", "{:?}", response.diagnostics);
}
