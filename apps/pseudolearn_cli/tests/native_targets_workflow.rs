use std::path::PathBuf;

const WORKFLOW: &str = "../../.github/workflows/verify-native-targets.yml";

fn triggers(workflow: &str) -> Result<Vec<String>, String> {
    let mut lines = workflow.lines().skip_while(|line| !line.starts_with("on:"));
    let declaration = lines.next().ok_or("the workflow declares no triggers")?;
    if declaration.trim_end() != "on:" {
        return Err(format!("inline trigger list: {declaration}"));
    }
    Ok(lines
        .take_while(|line| line.is_empty() || line.starts_with(' '))
        .filter(|line| line.len() > 2 && line.starts_with("  ") && !line.starts_with("   "))
        .filter_map(|line| line.trim().split(':').next().map(str::to_owned))
        .collect())
}

fn manual_only(workflow: &str) -> Result<(), String> {
    let declared = triggers(workflow)?;
    if declared == ["workflow_dispatch"] {
        Ok(())
    } else {
        Err(format!(
            "triggers other than workflow_dispatch: {declared:?}"
        ))
    }
}

#[test]
fn the_native_targets_workflow_only_runs_when_dispatched_by_hand() -> Result<(), String> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(WORKFLOW);
    let workflow = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
    manual_only(&workflow)
}

#[test]
fn an_automatic_trigger_is_rejected() {
    for automatic in [
        "on:\n  workflow_dispatch: {}\n  push:\n    branches: [master]\njobs:\n",
        "on:\n  pull_request:\njobs:\n",
        "on:\n  workflow_dispatch:\n  schedule:\n    - cron: '0 0 * * *'\n",
        "on:\n  pull_request_target:\n  workflow_dispatch:\n",
        "on: [push, workflow_dispatch]\njobs:\n",
        "on: workflow_dispatch\n",
        "name: Missing\njobs:\n",
    ] {
        assert!(manual_only(automatic).is_err(), "{automatic}");
    }
}

#[test]
fn a_dispatch_only_declaration_is_accepted() {
    assert_eq!(
        manual_only(
            "name: X\n\non:\n  workflow_dispatch:\n    inputs:\n      level:\n        type: string\n\njobs:\n"
        ),
        Ok(())
    );
}
