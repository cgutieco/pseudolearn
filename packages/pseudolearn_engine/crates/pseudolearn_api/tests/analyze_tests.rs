use pseudolearn_api::{AnalyzeRequest, execute_analyze};
use std::time::Instant;

fn generate_benchmark_program(
    target_lines: usize,
    profile_code: &str,
    is_incomplete: bool,
) -> String {
    let mut builder = String::new();
    let is_english = profile_code == "en";
    if is_english {
        builder.push_str("algorithm BenchmarkThroughput\n");
        builder.push_str("  define accumulator as integer\n");
        builder.push_str("  accumulator <- 0\n");
    } else {
        builder.push_str("Algoritmo RendimientoAnalisis\n");
        builder.push_str("  Definir acumulador Como Entero\n");
        builder.push_str("  acumulador <- 0\n");
    }
    let statement_count = target_lines.saturating_sub(5);
    for _ in 0..statement_count {
        if is_english {
            builder.push_str("  accumulator <- accumulator + 1\n");
        } else {
            builder.push_str("  acumulador <- acumulador + 1\n");
        }
    }
    if is_incomplete {
        builder.push_str("  acumulador <- \"sin cerrar\n");
    }
    if is_english {
        builder.push_str("end algorithm\n");
    } else {
        builder.push_str("FinAlgoritmo\n");
    }
    builder
}

fn measure_sample(
    program_source: &str,
    profile_code: &str,
    strictness_mode: &str,
    repetition_count: usize,
) -> Vec<u128> {
    let request = AnalyzeRequest {
        program: program_source.to_owned(),
        profile: profile_code.to_owned(),
        strictness: strictness_mode.to_owned(),
    };
    let mut durations_microseconds = Vec::new();
    for _ in 0..repetition_count {
        let clock_start = Instant::now();
        let _ = execute_analyze(&request);
        durations_microseconds.push(clock_start.elapsed().as_micros());
    }
    durations_microseconds.sort_unstable();
    durations_microseconds
}

fn compute_percentile(sorted_samples: &[u128], percentage: usize) -> u128 {
    if sorted_samples.is_empty() {
        return 0;
    }
    let sample_count = sorted_samples.len();
    let sample_bound = sample_count.saturating_sub(1);
    let computed_index = sample_count
        .saturating_mul(percentage)
        .checked_div(100)
        .unwrap_or(0)
        .min(sample_bound);
    sorted_samples.get(computed_index).copied().unwrap_or(0)
}

fn build_configuration_result(
    lines_target: usize,
    profile_code: &str,
    strictness_mode: &str,
    is_incomplete: bool,
) -> serde_json::Value {
    let source = generate_benchmark_program(lines_target, profile_code, is_incomplete);
    let sample_durations = measure_sample(&source, profile_code, strictness_mode, 10);
    let median_micros = compute_percentile(&sample_durations, 50);
    let p95_micros = compute_percentile(&sample_durations, 95);
    let lines_u128 = u128::try_from(lines_target).unwrap_or(0);
    let throughput = if median_micros > 0 {
        lines_u128
            .saturating_mul(1_000_000)
            .checked_div(median_micros)
            .unwrap_or(0)
    } else {
        0
    };
    serde_json::json!({
        "lines": lines_target,
        "bytes": source.len(),
        "profile": profile_code,
        "strictness": strictness_mode,
        "incomplete": is_incomplete,
        "median_microseconds": median_micros,
        "p95_microseconds": p95_micros,
        "throughput_lines_per_second": throughput,
    })
}

#[test]
fn measures_e08_throughput_and_records_results() {
    let mut results_array = Vec::new();
    for lines_count in [1_000, 10_000, 50_000] {
        for profile in ["es", "en"] {
            for strictness in ["strict", "flexible"] {
                for incomplete in [false, true] {
                    let entry =
                        build_configuration_result(lines_count, profile, strictness, incomplete);
                    results_array.push(entry);
                }
            }
        }
    }
    let payload = serde_json::json!({
        "protocol": "PERF.PROTOCOL#R1",
        "experiment": "E-08",
        "machine": "Apple M2 / macOS arm64",
        "results": results_array,
    });
    let output_path = concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../../pseudolearn_spec/results/r4-e08-throughput.json"
    );
    let content = serde_json::to_string_pretty(&payload).unwrap_or_default();
    assert!(std::fs::write(output_path, content).is_ok());
}
