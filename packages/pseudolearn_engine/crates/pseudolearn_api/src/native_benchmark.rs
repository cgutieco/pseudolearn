use crate::ir_execution::compile_source_with_warnings;
use crate::native_build::{NativeBuildFailure, NativeBuildRequest, settings_of};
use pseudolearn_aot_rt::{ExecutableMetadata, encode_metadata};
use pseudolearn_codegen::{TargetConfig, compile_module_to_benchmark_object};

const ENTRY_FUNCTION_NAME: &str = "main";

#[derive(Debug)]
pub struct BenchmarkObject {
    pub bytes: Vec<u8>,
    pub metadata: Vec<u8>,
    pub entry_symbol: String,
}

pub fn build_benchmark_object(
    request: &NativeBuildRequest,
) -> Result<BenchmarkObject, NativeBuildFailure> {
    let (module, _warnings) =
        compile_source_with_warnings(&request.program, &request.profile, &request.strictness)
            .map_err(NativeBuildFailure::Rejected)?;
    let settings = settings_of(request);
    let compiled = compile_module_to_benchmark_object(&module, &TargetConfig::host(), &settings)
        .map_err(|error| NativeBuildFailure::Backend(error.to_string()))?;
    let entry_symbol = compiled
        .function_symbols
        .iter()
        .find(|symbol| symbol.name.trim_start_matches('@') == ENTRY_FUNCTION_NAME)
        .map(|symbol| symbol.symbol.clone())
        .ok_or_else(|| NativeBuildFailure::Backend("module without main function".to_owned()))?;
    let metadata = ExecutableMetadata {
        settings,
        sites: compiled.fault_sites,
        classes: compiled.classes,
    };
    Ok(BenchmarkObject {
        bytes: compiled.bytes,
        metadata: encode_metadata(&metadata),
        entry_symbol,
    })
}
