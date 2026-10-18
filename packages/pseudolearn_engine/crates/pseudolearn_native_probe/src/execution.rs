use crate::measurement::Configuration;
use crate::output::Output;
use ceiling_kernels::variant::Experiment;
use pseudolearn_aot_rt::{AotConfig, AotSession, AotStreams, EntryFunction, decode_metadata};
use std::io::Cursor;
use std::time::Instant;

pub(crate) fn native(
    entry: EntryFunction,
    configuration: &Configuration,
) -> Result<(u64, Option<serde_json::Value>), String> {
    let (mut session, output) = prepare(configuration)?;
    let started = Instant::now();
    entry(session.context_pointer());
    let elapsed = started.elapsed();
    if session.context().fault_status != 0
        || output.text().map_err(|error| error.to_string())? != configuration.expected
    {
        return Err("Native result or termination mismatch".to_owned());
    }
    Ok((
        u64::try_from(elapsed.as_nanos()).map_err(|error| error.to_string())?,
        telemetry(&session),
    ))
}

pub(crate) fn ceiling(configuration: &Configuration) -> Result<u64, String> {
    let mut experiment = Experiment::new(4).map_err(|error| format!("{error:?}"))?;
    let started = Instant::now();
    let result = experiment
        .run(
            &configuration.workload,
            std::hint::black_box(configuration.size),
        )
        .map_err(|error| format!("{error:?}"))?;
    let elapsed = started.elapsed();
    if result != configuration.expected.trim_end_matches('\n') {
        return Err("Ceiling result mismatch".to_owned());
    }
    u64::try_from(elapsed.as_nanos()).map_err(|error| error.to_string())
}

pub(crate) fn machine(
    program: &pseudolearn_api::PreparedProgram,
    request: &pseudolearn_api::ExecuteRequest,
    expected: &str,
) -> Result<u64, String> {
    let started = Instant::now();
    let response = pseudolearn_api::execute_prepared(program, request);
    let elapsed = started.elapsed();
    if response.output != expected
        || response
            .termination
            .get("kind")
            .and_then(serde_json::Value::as_str)
            != Some("completed")
    {
        return Err("VM result or termination mismatch".to_owned());
    }
    u64::try_from(elapsed.as_nanos()).map_err(|error| error.to_string())
}

#[cfg(feature = "telemetry")]
fn telemetry(session: &AotSession) -> Option<serde_json::Value> {
    let memory = session.engine().heap().statistics();
    let accesses = session.engine().statistics();
    Some(
        serde_json::json!({"allocations":memory.allocations,"heapGrowths":memory.heap_growths,
        "collections":memory.collections,"reachabilityWalks":memory.reachability_walks,
        "layoutCopies":memory.layout_copies,"initializedWords":memory.initialized_words,
        "cellLoads":accesses.cell_loads,"cellStores":accesses.cell_stores,"cellsCreated":accesses.cells_created,
        "rootBuilds":accesses.root_builds,"rootCellsScanned":accesses.root_cells_scanned}),
    )
}

#[cfg(not(feature = "telemetry"))]
fn telemetry(_session: &AotSession) -> Option<serde_json::Value> {
    None
}

fn prepare(configuration: &Configuration) -> Result<(AotSession, Output), String> {
    let metadata = decode_metadata(&configuration.metadata).ok_or("Invalid metadata")?;
    let config = AotConfig {
        limits: metadata.settings.limits,
        seed: metadata.settings.seed,
        boolean_words: metadata.settings.boolean_words,
    };
    let output = Output::default();
    let mut session = AotSession::new(
        config,
        metadata.sites,
        AotStreams {
            input: Box::new(Cursor::new(configuration.input.clone().into_bytes())),
            output: Box::new(output.clone()),
        },
    );
    for (index, class) in metadata.classes.iter().enumerate() {
        session
            .engine_mut()
            .register_class(
                u32::try_from(index).map_err(|error| error.to_string())?,
                class,
            )
            .map_err(|error| format!("{error:?}"))?;
    }
    if metadata.settings.forced_collection {
        session.engine_mut().force_collection();
    }
    Ok((session, output))
}
