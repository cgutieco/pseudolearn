use crate::property_scenarios::Scenario;
use serde_json::json;

const SPAN: u64 = 18_000_000_000_000_000_000;
const OFFSET: i128 = 9_000_000_000_000_000_000;

pub(crate) fn scenario(seed: u64, sample: u32, profile: &str) -> Scenario {
    let instant = instant(seed, sample);
    Scenario {
        request: json!({
            "kind": "execute",
            "program": program(instant, profile),
            "profile": profile
        }),
        expected: Some(json!({"salida": "0\n", "terminacion": "completed"})),
        traced: false,
    }
}

fn instant(seed: u64, sample: u32) -> i128 {
    let mixed = seed
        .wrapping_add(u64::from(sample))
        .wrapping_mul(6_364_136_223_846_793_005)
        .wrapping_add(1_442_695_040_888_963_407);
    i128::from(mixed.checked_rem(SPAN).unwrap_or(0)).saturating_sub(OFFSET)
}

fn program(instant: i128, profile: &str) -> String {
    match profile {
        "es" => format!(
            "SubProceso Vuelta(semilla Como Entero)\nSegun AnalizarFechaHora(FechaHoraUtc(semilla).FormatoIsoPreciso()) Hacer\nNada: Escribir \"none\";\nAlgo(vuelta): Escribir vuelta.Instante() - semilla;\nFinSegun\nFinSubProceso\nAlgoritmo P\nVuelta({instant});\nFinAlgoritmo\n"
        ),
        _ => format!(
            "subroutine Back(seed as integer)\nswitch parseDateTime(dateTimeUtc(seed).isoFormatPrecise()) do\nnone: write \"none\";\nsome(back): write back.instant() - seed;\nendSwitch\nendSubroutine\nalgorithm P\nBack({instant});\nendAlgorithm\n"
        ),
    }
}
