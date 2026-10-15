use see_conformance::math_arguments::MathFunction;
use see_conformance::math_contrast::{MathOutcome, expected, format_arguments, format_outcome};
use serde_json::{Value, json};

const MISMATCH_SAMPLE: usize = 20;

pub struct Row {
    pub arguments: Vec<f64>,
    pub engine: MathOutcome,
}

pub struct Mismatch {
    arguments: Vec<f64>,
    expected: MathOutcome,
    engine: MathOutcome,
}

pub struct Summary {
    pub checked: usize,
    pub non_finite: usize,
    pub mismatches: Vec<Mismatch>,
}

impl Summary {
    pub fn to_json(&self) -> Value {
        let sample = self
            .mismatches
            .iter()
            .take(MISMATCH_SAMPLE)
            .map(|mismatch| {
                json!({
                    "arguments": format_arguments(&mismatch.arguments),
                    "expected": format_outcome(mismatch.expected),
                    "engine": format_outcome(mismatch.engine),
                })
            })
            .collect::<Vec<_>>();
        json!({
            "checked": self.checked,
            "nonFiniteExpected": self.non_finite,
            "mismatches": self.mismatches.len(),
            "mismatchSample": sample,
        })
    }
}

pub fn compare(function: MathFunction, rows: &[Row]) -> Result<Summary, String> {
    let workers = std::thread::available_parallelism().map_or(1, std::num::NonZeroUsize::get);
    let chunk = rows.len().div_ceil(workers).max(1);
    let partial = std::thread::scope(|scope| {
        let handles = rows
            .chunks(chunk)
            .map(|slice| scope.spawn(move || compare_slice(function, slice)))
            .collect::<Vec<_>>();
        handles
            .into_iter()
            .map(|handle| {
                handle
                    .join()
                    .map_err(|_| "Math contrast worker failed".to_owned())?
            })
            .collect::<Result<Vec<_>, String>>()
    })?;
    let mut summary = Summary {
        checked: 0,
        non_finite: 0,
        mismatches: Vec::new(),
    };
    for part in partial {
        summary.checked = summary.checked.saturating_add(part.checked);
        summary.non_finite = summary.non_finite.saturating_add(part.non_finite);
        summary.mismatches.extend(part.mismatches);
    }
    Ok(summary)
}

fn compare_slice(function: MathFunction, rows: &[Row]) -> Result<Summary, String> {
    let mut summary = Summary {
        checked: 0,
        non_finite: 0,
        mismatches: Vec::new(),
    };
    for row in rows {
        let oracle = expected(function, &row.arguments)?;
        summary.checked = summary.checked.saturating_add(1);
        if oracle == MathOutcome::NonFinite {
            summary.non_finite = summary.non_finite.saturating_add(1);
        }
        if oracle != row.engine {
            summary.mismatches.push(Mismatch {
                arguments: row.arguments.clone(),
                expected: oracle,
                engine: row.engine,
            });
        }
    }
    Ok(summary)
}
