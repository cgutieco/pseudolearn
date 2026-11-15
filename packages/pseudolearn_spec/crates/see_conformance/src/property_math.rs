use crate::math_arguments::{MathFunction, arguments};
use crate::math_contrast::{self, MathOutcome};
use crate::property_scenarios::Scenario;
use serde_json::json;

pub(crate) fn scenario(seed: u64, sample: u32) -> Result<Scenario, String> {
    let functions = [
        MathFunction::Tangent,
        MathFunction::ArcSine,
        MathFunction::ArcCosine,
        MathFunction::Arctangent2,
        MathFunction::Logarithm2,
        MathFunction::Logarithm10,
    ];
    let index = usize::try_from(sample).map_err(|error| error.to_string())?;
    let function = *functions
        .get(
            index
                .checked_rem(functions.len())
                .ok_or("missing functions")?,
        )
        .ok_or("missing function")?;
    let values = arguments(function, 1, seed.wrapping_add(u64::from(sample)));
    let values = values.first().ok_or("missing arguments")?;
    let expected = math_contrast::expected(function, values)?;
    let source = values
        .iter()
        .map(|value| literal(*value))
        .collect::<Vec<_>>()
        .join(",");
    let (program, expected) = program(function, &source, expected);
    Ok(Scenario {
        request: json!({"kind":"execute", "program":program, "profile":"en"}),
        expected: Some(expected),
        traced: false,
    })
}

fn literal(value: f64) -> String {
    let text = value.to_string();
    if text.contains('.') {
        text
    } else {
        format!("{text}.0")
    }
}

fn program(
    function: MathFunction,
    source: &str,
    expected: MathOutcome,
) -> (String, serde_json::Value) {
    match expected {
        MathOutcome::Finite(bits) => {
            let value = literal(f64::from_bits(bits));
            (
                format!(
                    "algorithm P\nwrite {}({source}) = {value};\nendAlgorithm\n",
                    function.name()
                ),
                json!({"salida": "true\n", "terminacion": "completed"}),
            )
        }
        MathOutcome::NonFinite => (
            format!(
                "algorithm P\nwrite {}({source});\nendAlgorithm\n",
                function.name()
            ),
            json!({"fallo": {"codigo": "nonFiniteRealResult"}}),
        ),
    }
}
