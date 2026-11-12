fn permute(values: &mut [i64], number: usize) -> u64 {
    let mut count = 1_u64;
    if number != 0 {
        let below = number.wrapping_sub(1);
        count = count.wrapping_add(permute(values, below));
        for index in (0..number).rev() {
            values.swap(below, index);
            count = count.wrapping_add(permute(values, below));
            values.swap(below, index);
        }
    }
    count
}

pub fn run(size: usize) -> String {
    let mut values = vec![0_i64; size.max(1)];
    permute(&mut values, size).to_string()
}
