use serde_json::{Value, json};

pub struct Summary {
    pub mean: f64,
    pub median: f64,
    pub mad: f64,
    pub iqr: f64,
    pub p95: f64,
    pub min: f64,
    pub max: f64,
}

pub fn summarize(samples: &[f64]) -> Option<Summary> {
    if samples.is_empty() {
        return None;
    }
    let mut sorted = samples.to_vec();
    sorted.sort_by(f64::total_cmp);
    let count = u32::try_from(sorted.len()).ok().map(f64::from)?;
    let median = percentile(&sorted, 50)?;
    let mut deviations: Vec<f64> = sorted.iter().map(|value| (value - median).abs()).collect();
    deviations.sort_by(f64::total_cmp);
    Some(Summary {
        mean: sorted.iter().sum::<f64>() / count,
        median,
        mad: percentile(&deviations, 50)?,
        iqr: percentile(&sorted, 75)? - percentile(&sorted, 25)?,
        p95: percentile(&sorted, 95)?,
        min: *sorted.first()?,
        max: *sorted.last()?,
    })
}

fn percentile(sorted: &[f64], percent: usize) -> Option<f64> {
    let rank = percent.checked_mul(sorted.len())?.div_ceil(100).max(1);
    sorted.get(rank.checked_sub(1)?).copied()
}

impl Summary {
    pub fn to_json(&self) -> Value {
        json!({
            "mean": round(self.mean),
            "median": round(self.median),
            "mad": round(self.mad),
            "iqr": round(self.iqr),
            "p95": round(self.p95),
            "min": round(self.min),
            "max": round(self.max),
        })
    }
}

pub fn round(value: f64) -> f64 {
    (value * 1000.0).round() / 1000.0
}

pub fn percent(part: usize, total: usize) -> f64 {
    let (Ok(part), Ok(total)) = (u32::try_from(part), u32::try_from(total)) else {
        return 0.0;
    };
    if total == 0 {
        return 0.0;
    }
    round(f64::from(part) * 100.0 / f64::from(total))
}
