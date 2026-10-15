use unicode_normalization::UnicodeNormalization;

pub struct IdentifierNormalizer;

impl IdentifierNormalizer {
    pub fn normalize(text: &str) -> String {
        if text.is_ascii() {
            return text.to_owned();
        }
        text.nfc().collect::<String>()
    }

    pub fn equals(first: &str, second: &str) -> bool {
        if first == second {
            return true;
        }
        Self::normalize(first) == Self::normalize(second)
    }
}
