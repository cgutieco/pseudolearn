use crate::aot::statistics::mean;
use serde_json::{Value, json};

struct LinearParameters {
    slope: f64,
    intercept: f64,
    mean_duration: f64,
}

pub(super) fn points_for(
    results: &[Value],
    category: &str,
    depth: Option<usize>,
) -> Vec<(usize, f64)> {
    results
        .iter()
        .filter(|result| text_of(result, "category") == category)
        .filter(|result| {
            depth.is_none_or(|expected| {
                number_of(result, "json_nodes") == expected.saturating_add(1)
            })
        })
        .filter_map(|result| {
            let size = if category == "http_body" {
                number_of(result, "body_bytes")
            } else {
                number_of(result, "input_bytes")
            };
            let average = result
                .get("mean_process_nanoseconds")
                .and_then(Value::as_f64)?;
            Some((size, average))
        })
        .collect()
}

pub(super) fn linear_fit(points: &[(usize, f64)]) -> Option<Value> {
    let (sizes, durations) = fit_values(points)?;
    let parameters = fit_parameters(&sizes, &durations)?;
    Some(json!({
        "slope_nanoseconds_per_byte": parameters.slope,
        "intercept_nanoseconds": parameters.intercept,
        "r_squared": fit_determination(&sizes, &durations, &parameters),
        "observations": points.len(),
    }))
}

fn fit_values(points: &[(usize, f64)]) -> Option<(Vec<f64>, Vec<f64>)> {
    if points.len() < 2 {
        return None;
    }
    let sizes = points
        .iter()
        .map(|(size, _)| u32::try_from(*size).map(f64::from))
        .collect::<Result<Vec<_>, _>>()
        .ok()?;
    let durations = points
        .iter()
        .map(|(_, duration)| *duration)
        .collect::<Vec<_>>();
    Some((sizes, durations))
}

fn fit_parameters(sizes: &[f64], durations: &[f64]) -> Option<LinearParameters> {
    let mean_size = mean(sizes);
    let mean_duration = mean(durations);
    let covariance = sizes
        .iter()
        .zip(durations)
        .map(|(size, duration)| (size - mean_size) * (duration - mean_duration))
        .sum::<f64>();
    let size_variance = sizes
        .iter()
        .map(|size| (size - mean_size) * (size - mean_size))
        .sum::<f64>();
    if size_variance == 0.0 {
        return None;
    }
    let slope = covariance / size_variance;
    Some(LinearParameters {
        slope,
        intercept: mean_duration - slope * mean_size,
        mean_duration,
    })
}

fn fit_determination(sizes: &[f64], durations: &[f64], parameters: &LinearParameters) -> f64 {
    let total_variance = durations
        .iter()
        .map(|duration| (duration - parameters.mean_duration).powi(2))
        .sum::<f64>();
    let residual = sizes
        .iter()
        .zip(durations)
        .map(|(size, duration)| {
            let difference = duration - (parameters.intercept + parameters.slope * size);
            difference * difference
        })
        .sum::<f64>();
    if total_variance == 0.0 {
        1.0
    } else {
        1.0 - residual / total_variance
    }
}

fn text_of(value: &Value, name: &str) -> String {
    value
        .get(name)
        .and_then(Value::as_str)
        .map_or_else(String::new, str::to_owned)
}

fn number_of(value: &Value, name: &str) -> usize {
    value
        .get(name)
        .and_then(Value::as_u64)
        .and_then(|number| usize::try_from(number).ok())
        .unwrap_or(0)
}
