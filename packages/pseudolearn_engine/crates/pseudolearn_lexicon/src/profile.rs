#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum Profile {
    #[default]
    Spanish,
    English,
}

impl Profile {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Spanish => "es",
            Self::English => "en",
        }
    }

    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "es" | "spanish" | "espanol" => Some(Self::Spanish),
            "en" | "english" | "ingles" => Some(Self::English),
            _ => None,
        }
    }

    pub fn fold_word(&self, text: &str) -> String {
        match self {
            Self::Spanish => fold_text(&pseudolearn_source::IdentifierNormalizer::normalize(text)),
            Self::English => text.to_lowercase(),
        }
    }
}

pub fn detect_opening_profile(source: &str) -> Option<Profile> {
    let clean = source.trim_start_matches('\u{FEFF}');
    let mut remainder = clean;
    loop {
        remainder = remainder.trim_start();
        if remainder.starts_with("//") {
            if let Some(next_line_index) = remainder.find('\n') {
                remainder = remainder.get(next_line_index..).unwrap_or("");
                continue;
            }
            return None;
        }
        if remainder.starts_with("/*") {
            if let Some(close_index) = remainder.find("*/") {
                remainder = remainder.get(close_index.saturating_add(2)..).unwrap_or("");
                continue;
            }
            return None;
        }
        break;
    }
    let first_word: String = remainder
        .chars()
        .take_while(|character| character.is_alphabetic() || *character == '_')
        .collect();
    crate::detect_opener(&first_word)
}

pub fn fold_text(text: &str) -> String {
    text.chars()
        .flat_map(char::to_lowercase)
        .map(|character| match character {
            'á' | 'à' | 'ä' | 'â' => 'a',
            'é' | 'è' | 'ë' | 'ê' => 'e',
            'í' | 'ì' | 'ï' | 'î' => 'i',
            'ó' | 'ò' | 'ö' | 'ô' => 'o',
            'ú' | 'ù' | 'ü' | 'û' => 'u',
            'ñ' => 'n',
            other => other,
        })
        .collect()
}
