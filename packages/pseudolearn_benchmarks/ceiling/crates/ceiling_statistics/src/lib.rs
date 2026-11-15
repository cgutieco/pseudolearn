#![forbid(unsafe_code)]

pub mod change_points;

pub fn mean(samples: &[f64]) -> Result<f64, String> {
    if samples.is_empty() || samples.iter().any(|value| !value.is_finite()) {
        return Err("Expected finite nonempty samples".to_owned());
    }
    let count = u32::try_from(samples.len()).map_err(|error| error.to_string())?;
    Ok(samples.iter().sum::<f64>() / f64::from(count))
}

pub fn geometric(samples: &[f64]) -> Result<f64, String> {
    if samples.iter().any(|value| *value <= 0.0) {
        return Err("Expected positive samples".to_owned());
    }
    Ok(mean(&samples.iter().map(|value| value.ln()).collect::<Vec<_>>())?.exp())
}

pub fn confidence(samples: &[f64]) -> Result<[f64; 2], String> {
    mean(samples)?;
    let mut seed = 42_u64;
    let mut estimates = Vec::new();
    for _ in 0..1000 {
        let mut selected = Vec::new();
        for _ in samples {
            seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1);
            let count = u64::try_from(samples.len()).map_err(|error| error.to_string())?;
            let index = usize::try_from(
                seed.wrapping_shr(32)
                    .checked_rem(count)
                    .ok_or("Empty bootstrap")?,
            )
            .map_err(|error| error.to_string())?;
            selected.push(*samples.get(index).ok_or("Bootstrap index")?);
        }
        estimates.push(mean(&selected)?);
    }
    estimates.sort_by(f64::total_cmp);
    Ok([
        *estimates.get(25).ok_or("Lower quantile")?,
        *estimates.get(974).ok_or("Upper quantile")?,
    ])
}

pub fn ratio(numerator: &[f64], denominator: &[f64]) -> Result<Vec<f64>, String> {
    if numerator.is_empty()
        || numerator.len() != denominator.len()
        || denominator.iter().any(|value| *value <= 0.0)
    {
        return Err("Unpaired or nonpositive process means".to_owned());
    }
    let result: Vec<_> = numerator
        .iter()
        .zip(denominator)
        .map(|(left, right)| left / right)
        .collect();
    mean(&result)?;
    Ok(result)
}
