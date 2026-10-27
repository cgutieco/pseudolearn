use serde_json::{Value, json};

pub const EFFECT_COUNTS: [u32; 3] = [100, 1000, 10_000];

pub struct EffectLoad {
    pub name: &'static str,
    pub count: u32,
    pub source: String,
    pub host: Value,
}

pub fn effect_loads() -> Vec<EffectLoad> {
    let mut loads = Vec::new();
    for count in EFFECT_COUNTS {
        loads.push(console_load(count));
        loads.push(clock_load(count));
        loads.push(file_load(count));
    }
    loads
}

fn console_load(count: u32) -> EffectLoad {
    EffectLoad {
        name: "console",
        count,
        source: format!(
            "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\nMientras i < {count} Hacer\nEscribir i;\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n"
        ),
        host: json!({"max_tape_bytes": TAPE_CEILING}),
    }
}

fn clock_load(count: u32) -> EffectLoad {
    let instants: Vec<u32> = (0..=count).collect();
    EffectLoad {
        name: "clock",
        count,
        source: format!(
            "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir Mutable i Como Entero <- 0;\nMientras i < {count} Hacer\nDescartar clock.Ahora();\ni <- i + 1;\nFinMientras\nRetornar Exito(i);\nFinSubProceso\nAlgoritmo P\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
        ),
        host: json!({
            "permissions": ["reloj"],
            "requested_permissions": ["reloj"],
            "clock": instants,
            "max_tape_bytes": TAPE_CEILING,
        }),
    }
}

fn file_load(count: u32) -> EffectLoad {
    EffectLoad {
        name: "file",
        count,
        source: format!(
            "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir Mutable i Como Entero <- 0;\nMientras i < {count} Hacer\nDescartar file.LeerTexto();\ni <- i + 1;\nFinMientras\nRetornar Exito(i);\nFinSubProceso\nAlgoritmo P\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
        ),
        host: json!({
            "permissions": ["archivos_lectura"],
            "requested_permissions": ["archivos_lectura"],
            "files": {"a": "0123456789012345678901234567890123456789012345678901234567890123"},
            "max_tape_bytes": TAPE_CEILING,
        }),
    }
}

const TAPE_CEILING: u64 = 1 << 30;

pub fn grows_linearly(points: &[(u64, u64)]) -> bool {
    let [(count_a, bytes_a), (count_b, bytes_b), (count_c, bytes_c)] = points else {
        return false;
    };
    let (Some(first_count), Some(second_count)) =
        (count_b.checked_sub(*count_a), count_c.checked_sub(*count_b))
    else {
        return false;
    };
    let (Some(first_bytes), Some(second_bytes)) =
        (bytes_b.checked_sub(*bytes_a), bytes_c.checked_sub(*bytes_b))
    else {
        return false;
    };
    if first_count == 0 || second_count == 0 || first_bytes == 0 {
        return false;
    }
    let left = u128::from(first_bytes).saturating_mul(u128::from(second_count));
    let right = u128::from(second_bytes).saturating_mul(u128::from(first_count));
    let difference = left.abs_diff(right);
    difference.saturating_mul(20) <= left
}
