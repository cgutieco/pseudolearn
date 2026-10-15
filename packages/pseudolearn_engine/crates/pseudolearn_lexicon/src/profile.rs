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
