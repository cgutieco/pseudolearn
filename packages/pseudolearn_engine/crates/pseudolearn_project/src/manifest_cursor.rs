use crate::manifest_error::{Location, ManifestError, ManifestErrorCode};

pub(crate) struct Cursor {
    characters: Vec<char>,
    index: usize,
    line: usize,
    column: usize,
}

impl Cursor {
    pub(crate) fn new(text: &str) -> Self {
        let body = text.strip_prefix('\u{feff}').unwrap_or(text);
        Self {
            characters: body.chars().collect(),
            index: 0,
            line: 1,
            column: 1,
        }
    }

    pub(crate) fn location(&self) -> Location {
        Location {
            line: self.line,
            column: self.column,
        }
    }

    pub(crate) fn peek(&self) -> Option<char> {
        self.characters.get(self.index).copied()
    }

    pub(crate) fn peek_next(&self) -> Option<char> {
        self.characters.get(self.index.saturating_add(1)).copied()
    }

    pub(crate) fn bump(&mut self) -> Option<char> {
        let character = self.peek()?;
        self.index = self.index.saturating_add(1);
        if character == '\n' {
            self.line = self.line.saturating_add(1);
            self.column = 1;
        } else {
            self.column = self.column.saturating_add(1);
        }
        Some(character)
    }

    pub(crate) fn expect(&mut self, wanted: char) -> Result<(), ManifestError> {
        if self.peek() == Some(wanted) {
            self.bump();
            Ok(())
        } else {
            Err(self.syntax())
        }
    }

    pub(crate) fn syntax(&self) -> ManifestError {
        ManifestError::new(ManifestErrorCode::ManifestSyntax, "", self.location())
    }

    pub(crate) fn skip_spaces(&mut self) {
        while matches!(self.peek(), Some(' ' | '\t')) {
            self.bump();
        }
    }

    pub(crate) fn skip_comment(&mut self) {
        if self.peek() == Some('#') {
            while !matches!(self.peek(), None | Some('\n')) {
                self.bump();
            }
        }
    }

    pub(crate) fn skip_trivia(&mut self) -> Result<(), ManifestError> {
        loop {
            self.skip_spaces();
            self.skip_comment();
            match self.peek() {
                Some('\n') => {
                    self.bump();
                }
                Some('\r') if self.peek_next() == Some('\n') => {
                    self.bump();
                }
                _ => return Ok(()),
            }
        }
    }

    pub(crate) fn end_of_line(&mut self) -> Result<(), ManifestError> {
        self.skip_spaces();
        self.skip_comment();
        match self.peek() {
            None | Some('\n') => Ok(()),
            Some('\r') if self.peek_next() == Some('\n') => Ok(()),
            _ => Err(self.syntax()),
        }
    }
}
