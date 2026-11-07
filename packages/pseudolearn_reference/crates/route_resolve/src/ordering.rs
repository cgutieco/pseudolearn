pub fn shuffled_order(seed: &str, count: usize) -> Vec<usize> {
    let mut order: Vec<usize> = (0..count).collect();
    order.sort_by_key(|position| fingerprint(seed, *position));
    if count > 1
        && order
            .iter()
            .enumerate()
            .all(|(index, value)| index == *value)
    {
        order.rotate_left(1);
    }
    order
}

fn fingerprint(seed: &str, position: usize) -> u64 {
    let mut hash: u64 = 0xcbf2_9ce4_8422_2325;
    let text = format!("{seed}#{position}");
    for byte in text.bytes() {
        hash ^= u64::from(byte);
        hash = hash.wrapping_mul(0x0100_0000_01b3);
    }
    hash
}
