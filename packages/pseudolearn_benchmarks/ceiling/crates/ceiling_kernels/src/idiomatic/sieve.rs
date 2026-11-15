pub fn run(size: usize) -> String {
    let mut flags = vec![true; size.saturating_add(1)];
    let mut count = 0_u32;
    for index in 2..=size {
        if flags.get(index).copied().unwrap_or(false) {
            count = count.wrapping_add(1);
            for flag in flags
                .iter_mut()
                .skip(index.wrapping_add(index))
                .step_by(index)
            {
                *flag = false;
            }
        }
    }
    count.to_string()
}
