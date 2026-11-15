pub(crate) const CHARACTER_AT: &str = r#"fn character_at(text: &str, index: i64) -> char {
    usize::try_from(index)
        .ok()
        .and_then(|position| text.chars().nth(position))
        .unwrap_or_else(|| panic!("stringPositionOutOfRange"))
}"#;

pub(crate) const CHARACTER_FROM_CODE: &str = r#"fn character_from_code(code: i64) -> char {
    u32::try_from(code)
        .ok()
        .and_then(char::from_u32)
        .unwrap_or_else(|| panic!("invalidCharacterCode"))
}"#;

pub(crate) const SUBSTRING: &str = r#"fn substring(text: &str, from: i64, to: i64) -> String {
    let length = text.chars().count() as i64;
    if from < 0 || from > length || to + 1 < from || to + 1 > length {
        panic!("stringPositionOutOfRange");
    }
    text.chars().skip(from as usize).take((to + 1 - from) as usize).collect()
}"#;

pub(crate) const TEXT_POSITION: &str = r#"fn text_position(text: &str, part: &str) -> Option<i64> {
    text.find(part).map(|byte| text[..byte].chars().count() as i64)
}"#;

pub(crate) const TEXT_TO_INTEGER: &str = r#"fn text_to_integer(text: &str) -> i64 {
    text.parse::<i64>().unwrap_or_else(|_| panic!("stringToNumberConversionFailed"))
}"#;

pub(crate) const TEXT_TO_REAL: &str = r#"fn text_to_real(text: &str) -> f64 {
    match text.parse::<f64>() {
        Ok(value) if value.is_finite() => value,
        _ => panic!("stringToNumberConversionFailed"),
    }
}"#;

pub(crate) const RANDOM: &str = r#"struct RandomSource {
    words: [u64; 4],
}

impl RandomSource {
    fn seeded(seed: i64) -> Self {
        let mut state = seed as u64;
        let mut words = [0; 4];
        for word in &mut words {
            state = state.wrapping_add(0x9e3779b97f4a7c15);
            let mixed = (state ^ (state >> 30)).wrapping_mul(0xbf58476d1ce4e5b9);
            let mixed = (mixed ^ (mixed >> 27)).wrapping_mul(0x94d049bb133111eb);
            *word = mixed ^ (mixed >> 31);
        }
        RandomSource { words }
    }

    fn next_word(&mut self) -> u64 {
        let [first, second, third, fourth] = self.words;
        let result = second.wrapping_mul(5).rotate_left(7).wrapping_mul(9);
        let shift = second << 17;
        let third = third ^ first;
        let fourth = fourth ^ second;
        let second = second ^ third;
        let first = first ^ fourth;
        self.words = [first, second, third ^ shift, fourth.rotate_left(45)];
        result
    }

    fn next_below(&mut self, bound: u64) -> u64 {
        let remainder = (u64::MAX % bound).wrapping_add(1) % bound;
        let accepted = 0_u64.wrapping_sub(remainder);
        loop {
            let word = self.next_word();
            if remainder == 0 || word < accepted {
                return word % bound;
            }
        }
    }
}

thread_local! {
    static RANDOM: RefCell<RandomSource> = RefCell::new(RandomSource::seeded(random_seed()));
}

fn random(bound: i64) -> i64 {
    if bound <= 0 {
        panic!("invalidRandomBound");
    }
    RANDOM.with(|source| source.borrow_mut().next_below(bound as u64) as i64)
}

fn random_between(low: i64, high: i64) -> i64 {
    if low > high {
        panic!("invalidRandomRange");
    }
    let width = high.abs_diff(low);
    let offset = match width.checked_add(1) {
        Some(span) => RANDOM.with(|source| source.borrow_mut().next_below(span)),
        None => RANDOM.with(|source| source.borrow_mut().next_word()),
    };
    low.wrapping_add_unsigned(offset)
}

fn random_unit() -> f64 {
    let integer = RANDOM.with(|source| source.borrow_mut().next_word()) >> 11;
    ((integer >> 32) as f64 * 4294967296.0 + (integer & 0xffff_ffff) as f64) / 9007199254740992.0
}"#;

pub(crate) const DICTIONARY: &str = r#"#[derive(Clone, Default)]
struct Dictionary<K, V> {
    entries: Vec<(K, V)>,
}

impl<K: PartialEq + Clone, V: Clone> Dictionary<K, V> {
    fn position(&self, key: &K) -> Option<usize> {
        self.entries.iter().position(|(found, _)| found == key)
    }

    fn get(&self, key: &K) -> V {
        match self.position(key) {
            Some(index) => self.entries[index].1.clone(),
            None => panic!("missingDictionaryKey"),
        }
    }

    fn set(&mut self, key: K, value: V) {
        match self.position(&key) {
            Some(index) => self.entries[index].1 = value,
            None => self.entries.push((key, value)),
        }
    }

    fn find(&self, key: &K) -> Option<V> {
        self.position(key).map(|index| self.entries[index].1.clone())
    }

    fn remove(&mut self, key: &K) -> Option<V> {
        self.position(key).map(|index| self.entries.remove(index).1)
    }

    fn len(&self) -> usize {
        self.entries.len()
    }

    fn keys(&self) -> Vec<K> {
        self.entries.iter().map(|(key, _)| key.clone()).collect()
    }

    fn entries(&self) -> Vec<(K, V)> {
        self.entries.clone()
    }
}"#;

pub(crate) const COLLECTION_TEXT: &str = r#"trait Shown {
    fn shown(&self) -> String;
    fn quoted(&self) -> String {
        self.shown()
    }
}

impl Shown for i64 {
    fn shown(&self) -> String {
        self.to_string()
    }
}

impl Shown for f64 {
    fn shown(&self) -> String {
        real_text(*self)
    }
}

impl Shown for bool {
    fn shown(&self) -> String {
        boolean_text(*self).to_string()
    }
}

impl Shown for char {
    fn shown(&self) -> String {
        self.to_string()
    }
    fn quoted(&self) -> String {
        format!("{:?}", self)
    }
}

impl Shown for String {
    fn shown(&self) -> String {
        self.clone()
    }
    fn quoted(&self) -> String {
        format!("{:?}", self)
    }
}

impl<T: Shown> Shown for Vec<T> {
    fn shown(&self) -> String {
        let items: Vec<String> = self.iter().map(Shown::quoted).collect();
        format!("[{}]", items.join(", "))
    }
}

impl<K: Shown, V: Shown> Shown for Dictionary<K, V> {
    fn shown(&self) -> String {
        let items: Vec<String> = self.entries.iter().map(|(key, value)| format!("{}: {}", key.quoted(), value.quoted())).collect();
        format!("{{{}}}", items.join(", "))
    }
}

fn collection_text(collection: &impl Shown) -> String {
    collection.shown()
}"#;

pub(crate) const SNAPSHOT: &str = r#"trait Snapshot {
    fn snapshot(&self) -> Self;
}

impl Snapshot for i64 {
    fn snapshot(&self) -> Self {
        *self
    }
}

impl Snapshot for f64 {
    fn snapshot(&self) -> Self {
        *self
    }
}

impl Snapshot for bool {
    fn snapshot(&self) -> Self {
        *self
    }
}

impl Snapshot for char {
    fn snapshot(&self) -> Self {
        *self
    }
}

impl Snapshot for String {
    fn snapshot(&self) -> Self {
        self.clone()
    }
}

impl<T: Snapshot> Snapshot for Rc<RefCell<Vec<T>>> {
    fn snapshot(&self) -> Self {
        Rc::new(RefCell::new(self.borrow().iter().map(Snapshot::snapshot).collect()))
    }
}

impl<K: Snapshot, V: Snapshot> Snapshot for Rc<RefCell<Dictionary<K, V>>> {
    fn snapshot(&self) -> Self {
        let entries = self.borrow().entries.iter().map(|(key, value)| (key.snapshot(), value.snapshot())).collect();
        Rc::new(RefCell::new(Dictionary { entries }))
    }
}

fn snapshot<T: Snapshot>(value: &T) -> T {
    value.snapshot()
}"#;

pub(crate) const FINITE: &str = r#"fn finite(value: f64) -> f64 {
    if !value.is_finite() {
        panic!("nonFiniteRealResult");
    }
    value
}"#;

pub(crate) const REPLACE_ALL: &str = r#"fn replace_all(text: &str, from: &str, to: &str) -> String {
    if from.is_empty() { text.to_string() } else { text.replace(from, to) }
}"#;

pub(crate) const SPLIT_TEXT: &str = r#"fn split_text(text: &str, separator: &str) -> Rc<RefCell<Vec<String>>> {
    if separator.is_empty() {
        panic!("emptySeparator");
    }
    Rc::new(RefCell::new(text.split(separator).map(str::to_string).collect()))
}"#;
