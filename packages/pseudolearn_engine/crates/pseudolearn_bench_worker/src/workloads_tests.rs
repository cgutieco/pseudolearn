use crate::workloads;
use pseudolearn_api::execute_analyze;

#[test]
fn generates_all_configurations_and_validates_completed_and_incomplete_programs()
-> Result<(), String> {
    let workloads = workloads::load()?;
    assert_eq!(workloads.len(), 32);
    assert_eq!(
        workloads
            .iter()
            .filter(|workload| workload.name.starts_with("unicode-identifiers-"))
            .count(),
        4
    );
    for workload in workloads {
        for request in &workload.requests {
            let result = execute_analyze(request);
            crate::frontend::validate(&result, &workload)?;
        }
        if !workload.corpus {
            assert_eq!(
                workload
                    .requests
                    .first()
                    .map(|request| request.program.lines().count()),
                usize::try_from(workload.lines).ok()
            );
        }
    }
    Ok(())
}

#[test]
fn rejects_missing_export_vocabulary() {
    assert!(workloads::generated(&serde_json::Value::Null, "en", "strict", (1000, false)).is_err());
}
