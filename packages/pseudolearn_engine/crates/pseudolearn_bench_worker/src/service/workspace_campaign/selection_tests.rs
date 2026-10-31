use crate::service::workspace_campaign::selection::Selection;

fn arguments(values: &[&str]) -> Vec<String> {
    values.iter().map(|value| (*value).to_owned()).collect()
}

#[test]
fn repeated_filters_select_the_requested_groups() -> Result<(), String> {
    let selection = Selection::parse(&arguments(&[
        "--load",
        "files-10",
        "--load",
        "files-1000-extended",
        "--scenario",
        "body-edit",
        "--scenario",
        "rename",
    ]))?;
    assert!(selection.is_partial());
    assert_eq!(selection.expected_groups().len(), 4);
    Ok(())
}

#[test]
fn unknown_load_scenario_and_option_are_rejected() {
    assert!(Selection::parse(&arguments(&["--load", "files-11"])).is_err());
    assert!(Selection::parse(&arguments(&["--scenario", "missing"])).is_err());
    assert!(Selection::parse(&arguments(&["--unknown", "value"])).is_err());
}

#[test]
fn missing_filter_values_are_rejected() {
    assert!(Selection::parse(&arguments(&["--load"])).is_err());
    assert!(Selection::parse(&arguments(&["--scenario"])).is_err());
}

#[test]
fn an_unfiltered_selection_contains_every_sampled_group() {
    let selection = Selection::default();
    assert!(!selection.is_partial());
    assert_eq!(selection.expected_groups().len(), 28);
}
