pub struct Generator {
    state: u64,
}

impl Generator {
    pub fn new(seed: u64, case: u64) -> Self {
        let mixed = seed
            .wrapping_mul(0x9E37_79B9_7F4A_7C15)
            .wrapping_add(case.wrapping_mul(0xD1B5_4A32_D192_ED03))
            .wrapping_add(1);
        Self { state: mixed }
    }

    pub fn next(&mut self) -> u64 {
        self.state ^= self.state << 13;
        self.state ^= self.state >> 7;
        self.state ^= self.state << 17;
        self.state
    }

    pub fn below(&mut self, bound: usize) -> usize {
        let wide = u64::try_from(bound.max(1)).unwrap_or(1);
        usize::try_from(self.next().checked_rem(wide).unwrap_or(0)).unwrap_or(0)
    }
}

const FRAGMENTS: [&str; 12] = [
    "Si ",
    " Entonces",
    "FinSi",
    "Mientras ",
    "\"",
    "'",
    "(",
    ")",
    "[",
    "\u{1F600}",
    "/*",
    "<-",
];

pub fn mutate_text(source: &str, generator: &mut Generator) -> String {
    let mut characters: Vec<char> = source.chars().collect();
    let rounds = generator.below(4).saturating_add(1);
    for _ in 0..rounds {
        apply(&mut characters, generator);
    }
    characters.into_iter().collect()
}

fn apply(characters: &mut Vec<char>, generator: &mut Generator) {
    let position = generator.below(characters.len().saturating_add(1));
    match generator.below(6) {
        0 => remove_span(characters, position, generator.below(12)),
        1 => duplicate_span(characters, position, generator.below(24)),
        2 => characters.truncate(position),
        3 => insert_fragment(characters, position, generator),
        4 => replace_character(characters, position, generator),
        _ => swap_lines(characters, generator),
    }
}

fn remove_span(characters: &mut Vec<char>, start: usize, length: usize) {
    let end = start.saturating_add(length).min(characters.len());
    if start < end {
        characters.drain(start..end);
    }
}

fn duplicate_span(characters: &mut Vec<char>, start: usize, length: usize) {
    let end = start.saturating_add(length).min(characters.len());
    let copy: Vec<char> = characters.get(start..end).unwrap_or(&[]).to_vec();
    for (offset, character) in copy.into_iter().enumerate() {
        characters.insert(end.saturating_add(offset), character);
    }
}

fn insert_fragment(characters: &mut Vec<char>, position: usize, generator: &mut Generator) {
    let fragment = FRAGMENTS
        .get(generator.below(FRAGMENTS.len()))
        .copied()
        .unwrap_or("");
    for (offset, character) in fragment.chars().enumerate() {
        characters.insert(
            position.saturating_add(offset).min(characters.len()),
            character,
        );
    }
}

fn replace_character(characters: &mut [char], position: usize, generator: &mut Generator) {
    let replacement =
        char::from_u32(u32::try_from(generator.below(0x2FF)).unwrap_or(0x41)).unwrap_or('?');
    if let Some(slot) = characters.get_mut(position) {
        *slot = replacement;
    }
}

fn swap_lines(characters: &mut Vec<char>, generator: &mut Generator) {
    let text: String = characters.iter().collect();
    let mut lines: Vec<&str> = text.split('\n').collect();
    let last = lines.len().saturating_sub(1);
    let first = generator.below(lines.len()).min(last);
    let second = generator.below(lines.len()).min(last);
    lines.swap(first, second);
    *characters = lines.join("\n").chars().collect();
}
