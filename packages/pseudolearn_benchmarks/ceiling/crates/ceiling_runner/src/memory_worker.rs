use crate::corpus::Workload;
use ceiling_kernels::collection::{Collector, Statistics, run as execute};
use serde_json::json;
use std::time::{Duration, Instant};

pub fn run() -> Result<(), String> {
    let workloads = workloads()?;
    let collectors = [
        Collector::SizeClasses,
        Collector::Lines,
        Collector::ReferenceCounts,
    ];
    for workload in workloads {
        for collector in collectors {
            let forced = execute(&workload.name, workload.size, collector, true)
                .map_err(|error| format!("{} forced {collector:?}: {error:?}", workload.name))?;
            crate::worker::validate(&forced.0, &workload.expected)?;
        }
        for iteration in 0_u32..30 {
            for offset in 0_u32..3 {
                let index = usize::try_from(
                    iteration
                        .wrapping_add(offset)
                        .checked_rem(3)
                        .ok_or("Missing variants")?,
                )
                .map_err(|error| error.to_string())?;
                let collector = *collectors.get(index).ok_or("Missing collector")?;
                let row = measure(&workload, collector, iteration)?;
                println!("{row}");
            }
        }
    }
    Ok(())
}

fn workloads() -> Result<Vec<Workload>, String> {
    let mut workloads = crate::corpus::load("medicion")?;
    workloads.push(Workload {
        name: "storage-deep".to_owned(),
        family: "allocation".to_owned(),
        size: 6,
        expected: "1365".to_owned(),
    });
    workloads.push(Workload {
        name: "list-churn".to_owned(),
        family: "allocation".to_owned(),
        size: 8192,
        expected: "8192".to_owned(),
    });
    Ok(workloads)
}

fn measure(
    workload: &Workload,
    collector: Collector,
    iteration: u32,
) -> Result<serde_json::Value, String> {
    let mut elapsed = Duration::ZERO;
    let mut repetitions = 0_u32;
    let mut statistics = Statistics::default();
    while elapsed < Duration::from_millis(5) {
        let start = Instant::now();
        let result = execute(&workload.name, workload.size, collector, false)
            .map_err(|error| format!("{} {collector:?}: {error:?}", workload.name))?;
        elapsed = elapsed.saturating_add(start.elapsed());
        crate::worker::validate(&result.0, &workload.expected)?;
        statistics = result.1;
        repetitions = repetitions.checked_add(1).ok_or("Repetition overflow")?;
    }
    let pauses = statistics
        .pauses
        .iter()
        .map(|pause| {
            json!({
                "nanoseconds":pause.elapsed.as_secs_f64() * 1e9,
                "markedWords":pause.marked_words,"sweptWords":pause.swept_words
            })
        })
        .collect::<Vec<_>>();
    Ok(
        json!({"workload":workload.name,"collector":format!("{collector:?}"),"iteration":iteration,
        "nanoseconds":elapsed.as_secs_f64() * 1e9 / f64::from(repetitions),"repetitions":repetitions,
        "peakWords":statistics.peak_words,"changedBlocks":statistics.changed_blocks,"pauses":pauses,
        "forcedOutputVerified":true,"validated":true}),
    )
}
