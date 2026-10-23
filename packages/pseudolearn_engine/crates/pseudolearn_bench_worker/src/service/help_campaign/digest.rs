const OFFSET_BASIS: u64 = 0xcbf2_9ce4_8422_2325;
const PRIME: u64 = 0x0000_0100_0000_01b3;

pub struct Digest(u64);

impl Digest {
    pub fn new() -> Self {
        Self(OFFSET_BASIS)
    }

    pub fn feed(&mut self, bytes: &[u8]) {
        for byte in bytes {
            self.0 ^= u64::from(*byte);
            self.0 = self.0.wrapping_mul(PRIME);
        }
    }

    pub fn hex(&self) -> String {
        format!("{:016x}", self.0)
    }
}

pub fn digest_text(text: &str) -> String {
    let mut digest = Digest::new();
    digest.feed(text.as_bytes());
    digest.hex()
}
