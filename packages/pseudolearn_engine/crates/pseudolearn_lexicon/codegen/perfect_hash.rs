use super::ProfilePairs;

pub fn generate(name: &str, kind: &str, profiles: ProfilePairs) -> String {
    let mut generated = String::new();
    for (profile, pairs) in [("es", profiles.0), ("en", profiles.1)] {
        let (seed, slots) = placement(&pairs);
        let table = format!("{}_{}", name.to_uppercase(), profile.to_uppercase());
        generated.push_str(&format!(
            "static {table}: [Option<(&str, {kind})>; {}] = [\n",
            slots.len()
        ));
        for slot in slots {
            let entry = slot.and_then(|index| pairs.get(index));
            generated.push_str(
                &entry
                    .map(|(form, variant)| format!("Some(({form:?}, {kind}::{variant})),\n"))
                    .unwrap_or_else(|| "None,\n".to_owned()),
            );
        }
        generated.push_str("];\n");
        generated.push_str(&format!("fn find_{name}_{profile}(word: &str) -> Option<{kind}> {{ let index = crate::hash::index(word, {seed}, {}); {table}.get(index).copied().flatten().filter(|(form, _)| form.eq_ignore_ascii_case(word)).map(|(_, kind)| kind) }}\n", pairs_capacity(&pairs)));
    }
    generated.push_str(&format!("pub fn find_{name}_by_profile(word: &str, profile: &str) -> Option<{kind}> {{ if profile == \"en\" {{ find_{name}_en(word) }} else {{ find_{name}_es(word) }} }}\n"));
    generated
}

fn pairs_capacity(pairs: &[(String, String)]) -> usize {
    pairs
        .len()
        .saturating_mul(8)
        .max(16)
        .checked_next_power_of_two()
        .unwrap_or(65536)
}

fn placement(pairs: &[(String, String)]) -> (u64, Vec<Option<usize>>) {
    let capacity = pairs_capacity(pairs);
    for seed in 0..1000000 {
        let mut slots = vec![None; capacity];
        let mut collision = false;
        for (position, (word, _)) in pairs.iter().enumerate() {
            let index = index(word, seed, capacity);
            let Some(slot) = slots.get_mut(index) else {
                collision = true;
                break;
            };
            if slot.is_some() {
                collision = true;
                break;
            }
            *slot = Some(position);
        }
        if !collision {
            return (seed, slots);
        }
    }
    std::process::exit(1)
}

fn index(word: &str, seed: u64, capacity: usize) -> usize {
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
