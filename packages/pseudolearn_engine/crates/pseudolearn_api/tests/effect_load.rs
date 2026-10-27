use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::time::Instant;

fn clock_program(count: usize) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable index Como Entero <- 0;\nMientras index < {count} Hacer\nDefinir instant Como Entero <- Propagar clock.Ahora();\ntotal <- total + instant;\nindex <- index + 1;\nFinMientras\nRetornar Exito(total);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

fn file_program(count: usize) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable index Como Entero <- 0;\nMientras index < {count} Hacer\nDefinir content Como Bytes <- Propagar file.LeerBytes();\ntotal <- total + content.Longitud();\nindex <- index + 1;\nFinMientras\nRetornar Exito(total);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

struct Load {
    program: String,
    host: Value,
    expected_output: String,
    expected_entries: usize,
}

fn clock_load(count: usize) -> Load {
    let instants: Vec<usize> = (1..=count).collect();
    Load {
        program: clock_program(count),
        host: json!({"permissions":["reloj"],"clock":instants}),
        expected_output: format!("{}\n", count.saturating_mul(count.saturating_add(1)) / 2),
        expected_entries: count.saturating_add(2),
    }
}

fn file_load(count: usize, size: usize) -> Load {
    Load {
        program: file_program(count),
        host: json!({"permissions":["archivos_lectura"],"files":{"a":vec![7u8; size]}}),
        expected_output: format!("{}\n", count.saturating_mul(size)),
        expected_entries: count.saturating_add(3),
    }
}

fn record(load: &Load) -> (Value, u128) {
    let request = json!({"kind":"execute","program":load.program,"profile":"es","strictness":"strict",
        "inputs":[],"seed":42,"observe":"none","limits":{"micro_steps":2_000_000_000u64},"host":load.host});
    let start = Instant::now();
    let response = ApiSession::default().call(
        "record",
        &json!({"request":request,"options":{"capture_states":false,"batch_size":100_000}}),
    );
    let elapsed = start.elapsed().as_nanos();
    (response.get("value").cloned().unwrap_or(response), elapsed)
}

fn check(name: &str, load: &Load) {
    let (value, elapsed) = record(load);
    assert_eq!(value.get("output"), Some(&json!(load.expected_output)), "{name}");
    let tape = value.get("effect_tape").cloned().unwrap_or(Value::Null);
    let entries = tape.get("entries").and_then(Value::as_array).map_or(0, Vec::len);
    let console = entries.saturating_sub(load.expected_entries);
    assert!(console <= 1, "{name}: {entries} entries, expected {}", load.expected_entries);
    if std::env::var_os("PSEUDO_EFFECT_LOAD_REPORT").is_some() {
        eprintln!(
            "{}",
            json!({"load":name,"entries":entries,"tape_bytes":tape.to_string().len(),"nanoseconds":elapsed})
        );
    }
}

#[test]
fn clock_loads_record_one_entry_per_effect() {
    for count in [100, 1000, 10_000] {
        check(&format!("clock-{count}"), &clock_load(count));
    }
}

#[test]
fn file_loads_record_one_entry_per_effect() {
    for size in [64, 4096] {
        for count in [100, 1000, 10_000] {
            check(&format!("file-{size}b-{count}"), &file_load(count, size));
        }
    }
}
