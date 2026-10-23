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

#[derive(Debug)]
pub struct HelpPart {
    pub identity: &'static str,
    pub text: &'static str,
}

#[derive(Debug)]
pub struct HelpExample {
    pub specification: &'static str,
    pub version: &'static str,
    pub case: &'static str,
    pub profile: &'static str,
    pub strictness: &'static str,
    pub kind: &'static str,
    pub label: &'static str,
}

pub struct LocaleContent {
    pub title: &'static str,
    pub summary: &'static str,
    pub purpose: &'static str,
    pub constraints: &'static [&'static str],
    pub common_errors: &'static [&'static str],
    pub parts: &'static [HelpPart],
    pub examples: &'static [HelpExample],
}

pub struct HelpCard {
    pub id: &'static str,
    pub kind: &'static str,
    pub identity: &'static str,
    pub role: &'static str,
    pub tokens: &'static [&'static str],
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
