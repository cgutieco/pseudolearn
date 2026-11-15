pub(crate) fn index(word: &str, seed: u64, capacity: usize) -> usize {
    let hash = word
        .bytes()
        .fold(seed.wrapping_add(14695981039346656037), |hash, byte| {
            hash.wrapping_mul(1099511628211)
                .wrapping_add(u64::from(byte.to_ascii_lowercase()))
        });
    let hash = (hash ^ hash.checked_shr(30).unwrap_or(0)).wrapping_mul(0xbf58476d1ce4e5b9);
    let hash = (hash ^ hash.checked_shr(27).unwrap_or(0)).wrapping_mul(0x94d049bb133111eb);
    let hash = hash ^ hash.checked_shr(31).unwrap_or(0);
    usize::try_from(hash & u64::try_from(capacity.saturating_sub(1)).unwrap_or(0)).unwrap_or(0)
}
