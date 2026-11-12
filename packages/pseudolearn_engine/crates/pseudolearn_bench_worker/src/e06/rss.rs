use pseudolearn_vm::{TwinMode, machine_remaining_fuel};
use serde_json::{Value, json};

use super::observer::{DEFAULT_BUDGET, Recorder};
use super::programs::storage_case;
use super::runner::{machine_for, run_chunked};

const LEVELS: usize = 10;

fn resident_kibibytes() -> Result<u64, String> {
    let output = std::process::Command::new("ps")
        .args(["-o", "rss=", "-p", &std::process::id().to_string()])
        .output()
        .map_err(|error| error.to_string())?;
    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse()
        .map_err(|_| "Unreadable resident size".to_owned())
}

pub fn child(mode: &str) -> Result<(), String> {
    let idle = resident_kibibytes()?;
    let case = storage_case(LEVELS)?;
    let mut machine = machine_for(&case, TwinMode::Fast)?;
    let mut recorder = Recorder::new(DEFAULT_BUDGET);
    let recording = mode == "recorded";
    run_chunked(&mut machine, |current, steps| {
        if recording {
            recorder.after_step(current, steps)?;
        }
        Ok(true)
    })?;
    let consumed = u64::MAX.saturating_sub(machine_remaining_fuel(&machine).statements);
    let live_words = pseudolearn_vm::machine_heap_used_words(&machine);
    println!(
        "{}",
        json!({"mode":mode,"idleKibibytes":idle,"residentKibibytes":resident_kibibytes()?,
            "liveHeapWords":live_words,"consumedStatements":consumed,
            "checkpoints":recorder.store.stats().checkpoints,
            "retainedSlots":recorder.store.stats().retained_slots})
    );
    Ok(())
}

fn spawn(mode: &str) -> Result<Value, String> {
    let executable = std::env::current_exe().map_err(|error| error.to_string())?;
    let output = std::process::Command::new(executable)
        .args(["e06-rss", mode])
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())
}

fn field(report: &Value, name: &str) -> f64 {
    report
        .get(name)
        .and_then(Value::as_u64)
        .map_or(f64::NAN, super::stats::to_float)
}

pub fn measure() -> Result<Value, String> {
    let baseline = spawn("baseline")?;
    let recorded = spawn("recorded")?;
    let extra_bytes =
        (field(&recorded, "residentKibibytes") - field(&baseline, "residentKibibytes")) * 1024.0;
    let footprint_bytes =
        (field(&baseline, "residentKibibytes") - field(&baseline, "idleKibibytes")) * 1024.0;
    let words_bytes = field(&recorded, "liveHeapWords") * 8.0;
    let ratio = extra_bytes / footprint_bytes;
    Ok(
        json!({"id":"E06-RSS","name":"resident memory with recording",
        "criterion":"extra resident bytes <= 2.5x resident footprint of the live heap (words plus descriptors)",
        "extraBytes":extra_bytes,"liveHeapFootprintBytes":footprint_bytes,"ratio":ratio,
        "liveHeapWordBytes":words_bytes,"ratioToWordBytes":extra_bytes / words_bytes,
        "passed":ratio <= 2.5,"baseline":baseline,"recorded":recorded}),
    )
}
