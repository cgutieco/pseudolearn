use crate::Resolution;
use reference_corpus::LexemeFamily;
use reference_model::{Profile, RawToken, Token, TokenCategory};

pub fn canonical_spelling(lexeme: &str, profile: Profile) -> String {
    match profile {
        Profile::Spanish => lexeme.to_owned(),
        Profile::English => capitalize_words(lexeme),
    }
}

fn capitalize_words(lexeme: &str) -> String {
    let mut spelled = String::with_capacity(lexeme.len());
    let mut at_word_start = true;
    for character in lexeme.chars() {
        if at_word_start {
            spelled.extend(character.to_uppercase());
        } else {
            spelled.push(character);
        }
        at_word_start = character == ' ';
    }
    spelled
}

pub fn fragment_tokens(resolution: &Resolution<'_>, code: &str, written_in: Profile) -> Vec<Token> {
    let raw = resolution.engine.tokenize(code, written_in);
    let characters: Vec<char> = code.chars().collect();
    let slice = |start: usize, end: usize| -> String {
        characters
            .get(start..end)
            .map(|part| part.iter().collect())
            .unwrap_or_default()
    };
    let mut tokens = Vec::new();
    let mut cursor = 0;
    let mut previous = String::new();
    for token in &raw {
        if token.start > cursor {
            tokens.push(plain(slice(cursor, token.start)));
        }
        let text = slice(token.start, token.end);
        let following = characters.get(token.end..).unwrap_or_default();
        let place = Place {
            previous: &previous,
            following,
            text: &text,
            written_in,
        };
        tokens.push(spell(resolution, token, &place));
        previous = text;
        cursor = token.end;
    }
    if cursor < characters.len() {
        tokens.push(plain(slice(cursor, characters.len())));
    }
    tokens
}

pub fn program_tokens(resolution: &Resolution<'_>, code: &str) -> Vec<Token> {
    fragment_tokens(resolution, code, resolution.profile)
}

fn plain(text: String) -> Token {
    Token {
        text,
        category: None,
    }
}

struct Place<'place> {
    previous: &'place str,
    following: &'place [char],
    text: &'place str,
    written_in: Profile,
}

impl Place<'_> {
    fn member_or_call(&self) -> bool {
        self.previous == "."
            || self
                .following
                .iter()
                .find(|character| !character.is_whitespace())
                == Some(&'(')
    }
}

fn spell(resolution: &Resolution<'_>, token: &RawToken, place: &Place<'_>) -> Token {
    if let Some(identity) = &token.keyword {
        return keyword_token(resolution, identity, place);
    }
    if token.kind != "identifier" {
        return Token {
            text: place.text.to_owned(),
            category: literal_category(&token.kind),
        };
    }
    identifier_token(resolution, place)
}

fn keyword_token(resolution: &Resolution<'_>, identity: &str, place: &Place<'_>) -> Token {
    let target = resolution.profile;
    let spelled = (place.written_in != target)
        .then(|| resolution.corpus.lexicon.lexeme(identity, target))
        .flatten()
        .map(|lexeme| {
            if place.previous == "." {
                lexeme.to_owned()
            } else {
                canonical_spelling(lexeme, target)
            }
        });
    Token {
        text: spelled.unwrap_or_else(|| place.text.to_owned()),
        category: resolution
            .categories
            .category(identity)
            .or(Some(TokenCategory::KeywordStructured)),
    }
}

fn identifier_token(resolution: &Resolution<'_>, place: &Place<'_>) -> Token {
    let target = resolution.profile;
    let Some(entry) = resolution
        .corpus
        .lexicon
        .identity_of(place.written_in, place.text)
    else {
        return Token {
            text: place.text.to_owned(),
            category: Some(TokenCategory::Identifier),
        };
    };
    let lexeme = entry.lexeme(target);
    let member = matches!(
        entry.family,
        LexemeFamily::Function | LexemeFamily::Operation
    );
    let text = if place.written_in == target {
        place.text.to_owned()
    } else if member || place.member_or_call() {
        lexeme.to_owned()
    } else {
        canonical_spelling(lexeme, target)
    };
    let category = if member {
        Some(TokenCategory::Identifier)
    } else {
        resolution
            .categories
            .category(&entry.identity)
            .or(Some(TokenCategory::Identifier))
    };
    Token { text, category }
}

fn literal_category(kind: &str) -> Option<TokenCategory> {
    let category = match kind {
        "integer_literal" | "real_literal" => TokenCategory::LiteralNumber,
        "string_literal" | "character_literal" => TokenCategory::LiteralString,
        "boolean_literal" => TokenCategory::LiteralBoolean,
        "comment" => TokenCategory::Comment,
        "operator" => TokenCategory::Operator,
        "punctuation" => TokenCategory::Punctuation,
        _ => return None,
    };
    Some(category)
}
