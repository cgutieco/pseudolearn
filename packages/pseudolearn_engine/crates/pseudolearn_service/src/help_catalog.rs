use pseudolearn_lexicon::Profile;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum HelpLocale {
    Spanish,
    English,
}

impl HelpLocale {
    pub fn from_profile(profile: Profile) -> Self {
        match profile {
            Profile::Spanish => Self::Spanish,
            Profile::English => Self::English,
        }
    }

    pub fn from_code(code: &str) -> Option<Self> {
        match code {
            "es" => Some(Self::Spanish),
            "en" => Some(Self::English),
            _ => None,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum HelpCategory {
    Block,
    Instruction,
    Symbol,
    Function,
    Type,
    Value,
}

impl HelpCategory {
    pub fn code(self) -> &'static str {
        match self {
            Self::Block => "block",
            Self::Instruction => "instruction",
            Self::Symbol => "symbol",
            Self::Function => "function",
            Self::Type => "type",
            Self::Value => "value",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum FormSegment {
    Code {
        identity: &'static str,
        text: &'static str,
    },
    Slot(&'static str),
    Ellipsis,
}

#[derive(Debug)]
pub struct FormPiece {
    pub segment: FormSegment,
    pub joined: bool,
}

#[derive(Debug)]
pub struct FormLine {
    pub indent: u8,
    pub pieces: &'static [FormPiece],
}

#[derive(Debug, Eq, PartialEq)]
pub struct HelpPart {
    pub identity: &'static str,
    pub text: &'static str,
    pub spanish_lexeme: &'static str,
    pub english_lexeme: &'static str,
}

impl HelpPart {
    pub fn lexeme(&self, profile: Profile) -> &'static str {
        match profile {
            Profile::Spanish => self.spanish_lexeme,
            Profile::English => self.english_lexeme,
        }
    }
}

#[derive(Debug, Eq, PartialEq)]
pub struct HelpSlot {
    pub id: &'static str,
    pub label: &'static str,
    pub text: &'static str,
}

#[derive(Clone, Copy, Debug)]
pub struct ExampleProgram {
    pub spanish: &'static str,
    pub english: &'static str,
    pub output: Option<&'static str>,
}

impl ExampleProgram {
    pub fn source(&self, profile: Profile) -> &'static str {
        match profile {
            Profile::Spanish => self.spanish,
            Profile::English => self.english,
        }
    }
}

#[derive(Debug)]
pub struct HelpCommonError {
    pub text: &'static str,
    pub program: Option<ExampleProgram>,
}

#[derive(Debug)]
pub struct HelpExample {
    pub specification: &'static str,
    pub version: &'static str,
    pub case: &'static str,
    pub kind: &'static str,
    pub note: &'static str,
    pub program: ExampleProgram,
}

pub struct LocaleContent {
    pub title: &'static str,
    pub summary: &'static str,
    pub parts: &'static [HelpPart],
    pub slots: &'static [HelpSlot],
    pub result: Option<&'static str>,
    pub rules: &'static [&'static str],
    pub common_errors: &'static [HelpCommonError],
    pub examples: &'static [HelpExample],
}

pub struct HelpCard {
    pub id: &'static str,
    pub kind: &'static str,
    pub identity: &'static str,
    pub role: &'static str,
    pub category: HelpCategory,
    pub tokens: &'static [&'static str],
    pub spanish_form: &'static [FormLine],
    pub english_form: &'static [FormLine],
    pub spanish: LocaleContent,
    pub english: LocaleContent,
}

impl HelpCard {
    pub fn content(&self, locale: HelpLocale) -> &LocaleContent {
        match locale {
            HelpLocale::Spanish => &self.spanish,
            HelpLocale::English => &self.english,
        }
    }

    pub fn form(&self, profile: Profile) -> &'static [FormLine] {
        match profile {
            Profile::Spanish => self.spanish_form,
            Profile::English => self.english_form,
        }
    }
}

include!(concat!(env!("OUT_DIR"), "/generated_help_cards.rs"));

pub fn cards() -> &'static [HelpCard] {
    CARDS
}

pub fn token_description(identity: &str, locale: HelpLocale) -> Option<&'static str> {
    CARDS
        .iter()
        .filter(|card| card.tokens.contains(&identity))
        .find_map(|card| {
            card.content(locale)
                .parts
                .iter()
                .find(|part| part.identity == identity)
                .map(|part| part.text)
        })
}
