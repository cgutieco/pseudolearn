use crate::pg_workloads::{Workload, closures, expansive_generic_source, generics};
use pseudolearn_api::{ExecuteRequest, execute_prepared, prepare_program};

fn output_of(source: &str, gc_stress: bool) -> Result<String, String> {
    let request = ExecuteRequest {
        program: source.to_owned(),
        gc_stress,
        ..Default::default()
    };
    let program = prepare_program(&request).map_err(|diagnostics| format!("{diagnostics:?}"))?;
    Ok(execute_prepared(&program, &request).output)
}

fn assert_same_output(workload: &Workload) -> Result<(), String> {
    let candidate = output_of(&workload.candidate, false)?;
    let control = output_of(&workload.control, false)?;
    if candidate.is_empty() || candidate != control {
        return Err(format!("{}: {candidate:?} != {control:?}", workload.name));
    }
    Ok(())
}

#[test]
fn generic_workloads_match_their_non_generic_controls() -> Result<(), String> {
    generics().iter().try_for_each(assert_same_output)
}

#[test]
fn closure_workloads_match_their_direct_controls() -> Result<(), String> {
    closures().iter().try_for_each(assert_same_output)
}

#[test]
fn closures_survive_forced_collection_without_alias_or_loss() -> Result<(), String> {
    for workload in closures() {
        let calm = output_of(&workload.candidate, false)?;
        let stressed = output_of(&workload.candidate, true)?;
        if calm != stressed {
            return Err(format!("{}: collection changed the output", workload.name));
        }
    }
    Ok(())
}

#[test]
fn expansive_generic_is_rejected_by_the_typed_limit() {
    let request = ExecuteRequest {
        program: expansive_generic_source(),
        ..Default::default()
    };
    assert!(prepare_program(&request).is_err());
}

#[test]
fn workload_names_are_unique_and_sources_differ() {
    let mut names: Vec<String> = generics()
        .into_iter()
        .chain(closures())
        .map(|workload| workload.name)
        .collect();
    let total = names.len();
    names.sort();
    names.dedup();
    assert_eq!(names.len(), total);
    assert!(
        generics()
            .iter()
            .all(|workload| workload.candidate != workload.control)
    );
}
