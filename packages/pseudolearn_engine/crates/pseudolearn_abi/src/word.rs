#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct Word(pub u64);

impl Word {
    pub const fn from_u64(bits: u64) -> Self {
        Self(bits)
    }

    pub const fn as_u64(&self) -> u64 {
        self.0
    }

    pub fn from_f64_bits(floating: f64) -> Self {
        Self(floating.to_bits())
    }

    pub fn as_f64_bits(&self) -> f64 {
        f64::from_bits(self.0)
    }

    pub const fn from_i64(integer: i64) -> Self {
        Self(u64::from_ne_bytes(integer.to_ne_bytes()))
    }

    pub const fn as_i64(&self) -> i64 {
        i64::from_ne_bytes(self.0.to_ne_bytes())
    }
}
