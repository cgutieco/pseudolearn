use pseudolearn_aot_rt::decode_metadata;
use pseudolearn_api::{
    ExecuteRequest, NativeBuildFailure, build_benchmark_object, conformance_build_request,
};

fn request(program: &str) -> pseudolearn_api::NativeBuildRequest {
    conformance_build_request(&ExecuteRequest {
        program: program.to_owned(),
        ..ExecuteRequest::default()
    })
}

fn contains(haystack: &[u8], needle: &[u8]) -> bool {
    haystack
        .windows(needle.len())
        .any(|window| window == needle)
}

#[test]
fn a_valid_program_yields_an_object_without_an_entry_point_and_its_metadata() -> Result<(), String>
{
    let object = build_benchmark_object(&request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"))
        .map_err(|error| format!("{error:?}"))?;
    assert!(object.entry_symbol.starts_with("__pl_fn_"));
    assert!(!contains(&object.bytes, b"pseudolearn_aot_main"));
    assert!(decode_metadata(&object.metadata).is_some());
    Ok(())
}

#[test]
fn a_rejected_program_reports_its_diagnostics() {
    let outcome = build_benchmark_object(&request("Algoritmo P\nEscribir total;\nFinAlgoritmo\n"));
    assert!(matches!(outcome, Err(NativeBuildFailure::Rejected(_))));
}
