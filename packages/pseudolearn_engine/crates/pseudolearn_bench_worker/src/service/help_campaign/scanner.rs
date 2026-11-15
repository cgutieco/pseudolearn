use crate::service::help_campaign::oracle::Oracle;
use std::collections::BTreeSet;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Occurrence {
    pub line: u32,
    pub column: u32,
    pub word: String,
    pub identity: String,
}

struct Word {
    column: u32,
    text: String,
}

pub struct Blank {
    pub line: u32,
    pub column: u32,
}

#[derive(Clone, Copy)]
enum Region {
    Code,
    BlockComment,
}

pub struct Scan {
    pub occurrences: Vec<Occurrence>,
    pub inert_positions: Vec<Blank>,
}

pub fn scan(oracle: &Oracle, profile: &str, program: &str) -> Scan {
    let mut occurrences = Vec::new();
    let mut inert_positions = Vec::new();
    let mut region = Region::Code;
    for (index, text) in program.lines().enumerate() {
        let line = u32::try_from(index).unwrap_or(u32::MAX).saturating_add(1);
        let (words, next_region, inert) = split_line(text, region);
        region = next_region;
        if let Some(column) = inert {
            inert_positions.push(Blank { line, column });
        }
        occurrences.extend(
            exclude_compounds(oracle, profile, words)
                .into_iter()
                .filter_map(|word| {
                    oracle
                        .identity_of(profile, &word.text)
                        .map(|identity| Occurrence {
                            line,
                            column: word.column,
                            identity: identity.to_owned(),
                            word: word.text,
                        })
                }),
        );
    }
    Scan {
        occurrences,
        inert_positions,
    }
}

fn split_line(text: &str, start: Region) -> (Vec<Word>, Region, Option<u32>) {
    let mut scanner = LineScanner {
        characters: text.chars().collect(),
        cursor: 0,
        region: start,
        in_string: false,
        words: Vec::new(),
        inert: None,
    };
    while scanner.cursor < scanner.characters.len() {
        if !scanner.step() {
            break;
        }
        scanner.cursor = scanner.cursor.saturating_add(1);
    }
    (scanner.words, scanner.region, scanner.inert)
}

struct LineScanner {
    characters: Vec<char>,
    cursor: usize,
    region: Region,
    in_string: bool,
    words: Vec<Word>,
    inert: Option<u32>,
}

impl LineScanner {
    fn column(&self) -> u32 {
        u32::try_from(self.cursor)
            .unwrap_or(u32::MAX)
            .saturating_add(1)
    }

    fn glyph(&self) -> char {
        self.characters.get(self.cursor).copied().unwrap_or(' ')
    }

    fn next_glyph(&self) -> Option<char> {
        self.characters.get(self.cursor.saturating_add(1)).copied()
    }

    fn mark_inert(&mut self, column: u32) {
        self.inert.get_or_insert(column);
    }

    fn step(&mut self) -> bool {
        if matches!(self.region, Region::BlockComment) {
            self.step_block_comment();
        } else if self.in_string {
            self.step_string();
        } else {
            return self.step_code();
        }
        true
    }

    fn step_block_comment(&mut self) {
        self.mark_inert(self.column());
        if self.glyph() == '*' && self.next_glyph() == Some('/') {
            self.region = Region::Code;
            self.cursor = self.cursor.saturating_add(1);
        }
    }

    fn step_string(&mut self) {
        self.mark_inert(self.column());
        self.in_string = self.glyph() != '"';
    }

    fn step_code(&mut self) -> bool {
        match (self.glyph(), self.next_glyph()) {
            ('"', _) => self.in_string = true,
            ('/', Some('/')) => {
                self.mark_inert(self.column().saturating_add(2));
                return false;
            }
            ('/', Some('*')) => self.open_block_comment(),
            (glyph, _) if is_word_character(glyph) => self.take_word(),
            _ => {}
        }
        true
    }

    fn open_block_comment(&mut self) {
        self.region = Region::BlockComment;
        self.cursor = self.cursor.saturating_add(1);
    }

    fn take_word(&mut self) {
        let column = self.column();
        let (text, end) = take_word(&self.characters, self.cursor);
        self.words.push(Word { column, text });
        self.cursor = end.saturating_sub(1);
    }
}

fn is_word_character(glyph: char) -> bool {
    glyph.is_alphanumeric() || glyph == '_'
}

fn take_word(characters: &[char], start: usize) -> (String, usize) {
    let mut end = start;
    while characters
        .get(end)
        .is_some_and(|glyph| is_word_character(*glyph))
    {
        end = end.saturating_add(1);
    }
    let word = characters
        .get(start..end)
        .unwrap_or_default()
        .iter()
        .collect();
    (word, end)
}

fn matches_at(words: &[Word], start: usize, compound: &[String]) -> bool {
    compound.iter().enumerate().all(|(offset, part)| {
        words
            .get(start.saturating_add(offset))
            .is_some_and(|word| &word.text == part)
    })
}

fn hidden_indexes(compounds: &[&Vec<String>], words: &[Word]) -> BTreeSet<usize> {
    (0..words.len())
        .flat_map(|start| {
            compounds
                .iter()
                .filter(move |compound| matches_at(words, start, compound))
                .map(move |compound| start..start.saturating_add(compound.len()))
        })
        .flatten()
        .collect()
}

fn exclude_compounds(oracle: &Oracle, profile: &str, words: Vec<Word>) -> Vec<Word> {
    let hidden = hidden_indexes(&oracle.compound_lengths(profile), &words);
    words
        .into_iter()
        .enumerate()
        .filter_map(|(index, word)| (!hidden.contains(&index)).then_some(word))
        .collect()
}
