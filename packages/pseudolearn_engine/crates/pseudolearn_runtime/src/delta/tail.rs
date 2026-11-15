pub trait Sequence: Clone {
    fn length(&self) -> usize;
    fn shorten(&mut self, length: usize);
    fn extends(&self, shorter: &Self) -> bool;
    fn append_from(&mut self, source: &Self, start: usize);
}

impl Sequence for String {
    fn length(&self) -> usize {
        self.len()
    }

    fn shorten(&mut self, length: usize) {
        if self.is_char_boundary(length) {
            self.truncate(length);
        }
    }

    fn extends(&self, shorter: &Self) -> bool {
        self.as_bytes().starts_with(shorter.as_bytes())
    }

    fn append_from(&mut self, source: &Self, start: usize) {
        if let Some(tail) = source.get(start..) {
            self.push_str(tail);
        }
    }
}

impl<Element: Clone + PartialEq> Sequence for Vec<Element> {
    fn length(&self) -> usize {
        self.len()
    }

    fn shorten(&mut self, length: usize) {
        self.truncate(length);
    }

    fn extends(&self, shorter: &Self) -> bool {
        self.starts_with(shorter)
    }

    fn append_from(&mut self, source: &Self, start: usize) {
        if let Some(tail) = source.get(start..) {
            self.extend_from_slice(tail);
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct TailDelta<Content> {
    pub old_length: usize,
    pub replaced: Option<Content>,
}

impl<Content: Sequence> TailDelta<Content> {
    pub fn copied_slots(&self) -> usize {
        self.replaced.as_ref().map_or(0, Sequence::length)
    }

    pub fn advance(tip: &mut Content, live: &Content) -> Self {
        let old_length = tip.length();
        if live.extends(tip) {
            tip.append_from(live, old_length);
            return Self {
                old_length,
                replaced: None,
            };
        }
        let replaced = Some(std::mem::replace(tip, live.clone()));
        Self {
            old_length,
            replaced,
        }
    }

    pub fn revert(&self, current: &mut Content) {
        match &self.replaced {
            Some(full) => current.clone_from(full),
            None => current.shorten(self.old_length),
        }
    }

    pub fn compose(first_applied: &Self, older: &Self) -> Self {
        if older.replaced.is_some() {
            return older.clone();
        }
        let replaced = first_applied.replaced.as_ref().map(|full| {
            let mut shortened = full.clone();
            shortened.shorten(older.old_length);
            shortened
        });
        Self {
            old_length: older.old_length,
            replaced,
        }
    }
}
