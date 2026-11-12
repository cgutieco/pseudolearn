use unicode_normalization::UnicodeNormalization;

pub struct IdentifierNormalizer;

impl IdentifierNormalizer {
    pub fn normalize(text: &str) -> String {
        if text.is_ascii() {
            return text.to_owned();
        }
        text.nfc().collect::<String>()
    }

    pub fn is_valid_identifier(text: &str) -> bool {
        if text.is_ascii() {
            let bytes = text.as_bytes();
            let Some(first) = bytes.first() else {
                return false;
            };
            return (first.is_ascii_alphabetic() || *first == b'_')
                && bytes
                    .iter()
                    .skip(1)
                    .all(|byte| byte.is_ascii_alphanumeric() || *byte == b'_');
        }
        let normalized = Self::normalize(text);
        let mut characters = normalized.chars();
        let Some(first) = characters.next() else {
            return false;
        };
        (Self::is_allowed_letter(first) || first == '_')
            && characters.all(Self::is_allowed_continuation)
    }

    pub fn is_continuation(character: char) -> bool {
        unicode_ident::is_xid_continue(character)
    }

    pub fn equals(first: &str, second: &str) -> bool {
        if first == second {
            return true;
        }
        Self::normalize(first) == Self::normalize(second)
    }

    fn is_allowed_letter(character: char) -> bool {
        character.is_ascii_alphabetic()
            || matches!(
                character,
                'ñ' | 'Ñ'
                    | 'á'
                    | 'Á'
                    | 'é'
                    | 'É'
                    | 'í'
                    | 'Í'
                    | 'ó'
                    | 'Ó'
                    | 'ú'
                    | 'Ú'
                    | 'ü'
                    | 'Ü'
            )
    }

    fn is_allowed_continuation(character: char) -> bool {
        Self::is_allowed_letter(character) || character.is_ascii_digit() || character == '_'
    }
}
