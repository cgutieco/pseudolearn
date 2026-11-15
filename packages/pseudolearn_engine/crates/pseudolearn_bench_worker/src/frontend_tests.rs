use crate::workloads::Workload;
use pseudolearn_api::AnalyzeResponse;

#[test]
fn rejects_missing_tree_and_false_success_for_incomplete_source() {
    let workload = Workload {
        requests: Vec::new(),
        name: "invalid".to_owned(),
        lines: 1,
        bytes: 0,
        incomplete: true,
        corpus: false,
    };
    assert!(
        crate::frontend::validate(
            &AnalyzeResponse::new(false, Vec::new(), Vec::new()),
            &workload
        )
        .is_err()
    );
    assert!(
        crate::frontend::validate(
            &AnalyzeResponse::new(true, Vec::new(), Vec::new()),
            &workload
        )
        .is_err()
    );
}
