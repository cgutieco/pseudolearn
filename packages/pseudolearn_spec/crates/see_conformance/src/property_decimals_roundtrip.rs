use crate::property_scenarios::Scenario;
use serde_json::json;

const MANTISSA_RANGE: u64 = 4_503_599_627_370_495;
const MAXIMUM_SHIFT: u64 = 60;

pub(crate) fn scenario(seed: u64, sample: u32, profile: &str) -> Scenario {
    let mixed = seed
        .wrapping_add(u64::from(sample))
        .wrapping_mul(6_364_136_223_846_793_005)
        .wrapping_add(1_442_695_040_888_963_407);
    let mantissa = (mixed >> 11)
        .checked_rem(MANTISSA_RANGE)
        .unwrap_or(0)
        .saturating_add(1);
    let shift = (mixed >> 3).checked_rem(MAXIMUM_SHIFT + 1).unwrap_or(0);
    Scenario {
        request: json!({
            "kind": "execute",
            "program": program(mantissa, shift, profile),
            "profile": profile
        }),
        expected: Some(json!({"salida": "1\n", "terminacion": "completed"})),
        traced: false,
    }
}

fn program(mantissa: u64, shift: u64, profile: &str) -> String {
    match profile {
        "es" => format!(
            "Algoritmo P\nDefinir x Como Real <- {mantissa}.0;\nDefinir i Como Entero <- 0;\nDefinir texto Como Cadena;\nMientras i < {shift} Hacer\nx <- x / 2.0;\ni <- i + 1;\nFinMientras\ntexto <- Decimales(x, {shift});\nSi Decimales(AReal(texto), {shift}) = texto Entonces\nEscribir 1;\nSiNo\nEscribir 0;\nFinSi\nFinAlgoritmo\n"
        ),
        _ => format!(
            "algorithm P\ndefine x as real <- {mantissa}.0;\ndefine i as integer <- 0;\ndefine text as string;\nwhile i < {shift} do\nx <- x / 2.0;\ni <- i + 1;\nendWhile\ntext <- decimals(x, {shift});\nif decimals(toReal(text), {shift}) = text then\nwrite 1;\nelse\nwrite 0;\nendIf\nendAlgorithm\n"
        ),
    }
}
