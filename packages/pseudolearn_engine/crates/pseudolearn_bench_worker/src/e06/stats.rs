const TWO_POW_32: f64 = 4_294_967_296.0;

pub fn to_float(value: u64) -> f64 {
    let high = u32::try_from(value >> 32).unwrap_or(u32::MAX);
    let low = u32::try_from(value & 0xffff_ffff).unwrap_or(u32::MAX);
    f64::from(high) * TWO_POW_32 + f64::from(low)
}

pub fn count_to_float(count: usize) -> f64 {
    to_float(u64::try_from(count).unwrap_or(u64::MAX))
}

pub fn percentile(values: &[f64], fraction: f64) -> f64 {
    if values.is_empty() {
        return f64::NAN;
    }
    let mut sorted = values.to_vec();
    sorted.sort_by(f64::total_cmp);
    let rank = (count_to_float(sorted.len()) * fraction).ceil().max(1.0);
    let rank_index = (0..sorted.len())
        .find(|candidate| count_to_float(candidate.saturating_add(1)) >= rank)
        .unwrap_or(sorted.len().saturating_sub(1));
    sorted.get(rank_index).copied().unwrap_or(f64::NAN)
}

pub fn median(values: &[f64]) -> f64 {
    percentile(values, 0.5)
}

pub fn geometric_mean(values: &[f64]) -> f64 {
    if values.is_empty() || values.iter().any(|value| *value <= 0.0) {
        return f64::NAN;
    }
    let total: f64 = values.iter().map(|value| value.ln()).sum();
    (total / count_to_float(values.len())).exp()
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Slope {
    pub slope: f64,
    pub margin: f64,
}

impl Slope {
    pub fn is_indistinguishable_from_zero(&self) -> bool {
        self.slope.is_finite() && self.margin.is_finite() && self.slope.abs() <= self.margin
    }
}

pub fn regression_slope(points: &[(f64, f64)]) -> Slope {
    let count = count_to_float(points.len());
    let degrees = points.len().saturating_sub(2);
    if degrees == 0 {
        return Slope {
            slope: f64::NAN,
            margin: f64::NAN,
        };
    }
    let mean_x = points.iter().map(|point| point.0).sum::<f64>() / count;
    let mean_y = points.iter().map(|point| point.1).sum::<f64>() / count;
    let spread_x: f64 = points.iter().map(|point| (point.0 - mean_x).powi(2)).sum();
    let covariance: f64 = points
        .iter()
        .map(|point| (point.0 - mean_x) * (point.1 - mean_y))
        .sum();
    if spread_x == 0.0 {
        return Slope {
            slope: f64::NAN,
            margin: f64::NAN,
        };
    }
    let slope = covariance / spread_x;
    let residuals: f64 = points
        .iter()
        .map(|point| (point.1 - mean_y - slope * (point.0 - mean_x)).powi(2))
        .sum();
    let standard_error = (residuals / count_to_float(degrees) / spread_x).sqrt();
    Slope {
        slope,
        margin: critical_value(degrees) * standard_error,
    }
}

fn critical_value(degrees: usize) -> f64 {
    match degrees {
        0..=9 => 2.31,
        10..=29 => 2.05,
        30..=59 => 2.0,
        _ => 1.98,
    }
}
