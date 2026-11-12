use crate::mean;

fn variance(samples: &[f64]) -> Result<f64, String> {
    if samples.len() < 2 {
        return Err("Variance requires two samples".to_owned());
    }
    let average = mean(samples)?;
    let count =
        u32::try_from(samples.len().saturating_sub(1)).map_err(|error| error.to_string())?;
    Ok(samples
        .iter()
        .map(|value| (value - average).powi(2))
        .sum::<f64>()
        / f64::from(count))
}

pub fn detect(samples: &[f64]) -> Result<Vec<usize>, String> {
    mean(samples)?;
    let mut candidates = Vec::new();
    for boundary in 5..=samples.len().saturating_sub(5) {
        let left = samples.get(..boundary).ok_or("Left segment")?;
        let right = samples.get(boundary..).ok_or("Right segment")?;
        let first = mean(left)?;
        let second = mean(right)?;
        let left_count = f64::from(u32::try_from(left.len()).map_err(|error| error.to_string())?);
        let right_count = f64::from(u32::try_from(right.len()).map_err(|error| error.to_string())?);
        let error = (variance(left)? / left_count + variance(right)? / right_count).sqrt();
        let difference = (first - second).abs();
        if difference > 0.05 * first.abs().max(second.abs()) && difference > 3.3 * error {
            candidates.push(boundary);
        }
    }
    Ok(candidates)
}
