use crate::service::help_campaign::documents::Generator;

pub const RESAMPLES: usize = 10_000;
const SEGMENT_MINIMUM: usize = 5;
const RELATIVE_THRESHOLD: f64 = 0.05;
const STANDARD_ERROR_THRESHOLD: f64 = 3.3;

pub fn mean(values: &[f64]) -> Option<f64> {
    let count = u32::try_from(values.len()).ok().map(f64::from)?;
    (count > 0.0).then(|| values.iter().sum::<f64>() / count)
}

pub fn percentile(values: &[f64], percent: usize) -> Option<f64> {
    let mut sorted = values.to_vec();
    sorted.sort_by(f64::total_cmp);
    let rank = percent.checked_mul(sorted.len())?.div_ceil(100).max(1);
    sorted.get(rank.checked_sub(1)?).copied()
}

pub fn confidence_interval<Statistic>(
    groups: &[Vec<f64>],
    seed: u64,
    statistic: Statistic,
) -> Option<(f64, f64)>
where
    Statistic: Fn(&[Vec<f64>]) -> Option<f64>,
{
    if groups.is_empty() {
        return None;
    }
    let mut generator = Generator::new(seed);
    let mut outcomes = Vec::with_capacity(RESAMPLES);
    for _ in 0..RESAMPLES {
        let resample: Vec<Vec<f64>> = (0..groups.len())
            .filter_map(|_| groups.get(generator.below(groups.len())).cloned())
            .collect();
        outcomes.push(statistic(&resample)?);
    }
    outcomes.sort_by(f64::total_cmp);
    let lower = outcomes.get(RESAMPLES.checked_mul(25)? / 1000).copied()?;
    let upper = outcomes.get(RESAMPLES.checked_mul(975)? / 1000).copied()?;
    Some((lower, upper))
}

pub fn pooled_percentile(groups: &[Vec<f64>], percent: usize) -> Option<f64> {
    let pooled: Vec<f64> = groups.iter().flatten().copied().collect();
    percentile(&pooled, percent)
}

pub fn mean_of_means(groups: &[Vec<f64>]) -> Option<f64> {
    let means: Vec<f64> = groups.iter().filter_map(|group| mean(group)).collect();
    mean(&means)
}

pub fn change_points(samples: &[f64]) -> Vec<usize> {
    let mut candidates = Vec::new();
    for split in SEGMENT_MINIMUM..=samples.len().saturating_sub(SEGMENT_MINIMUM) {
        let (left, right) = samples.split_at(split);
        let (Some(left_mean), Some(right_mean)) = (mean(left), mean(right)) else {
            continue;
        };
        let error = standard_error(left, left_mean).hypot(standard_error(right, right_mean));
        let difference = (right_mean - left_mean).abs();
        let relative = if left_mean > 0.0 {
            difference / left_mean
        } else {
            0.0
        };
        if relative > RELATIVE_THRESHOLD && difference > STANDARD_ERROR_THRESHOLD * error {
            candidates.push(split);
        }
    }
    candidates
}

fn standard_error(values: &[f64], average: f64) -> f64 {
    let count = u32::try_from(values.len()).ok().map_or(1.0, f64::from);
    let variance = values
        .iter()
        .map(|value| (value - average).powi(2))
        .sum::<f64>()
        / (count - 1.0).max(1.0);
    (variance / count).sqrt()
}
