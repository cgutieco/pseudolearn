use crate::line_index::LineIndex;
use crate::span::Span;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceFailure {
    pub description: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceText {
    content: String,
    bom_prefix_length: u32,
    line_index: LineIndex,
}

impl SourceText {
    pub fn from_bytes(bytes: &[u8]) -> Result<Self, SourceFailure> {
        let text = std::str::from_utf8(bytes).map_err(|error| SourceFailure {
            description: error.to_string(),
        })?;
        Ok(Self::new(text.to_owned()))
    }

    pub fn new(content: String) -> Self {
        let bom_prefix_length = if content.starts_with('\u{FEFF}') {
            3
        } else {
            0
        };
        let line_index = LineIndex::build(&content);
        Self {
            content,
            bom_prefix_length,
            line_index,
        }
    }

    pub fn as_str(&self) -> &str {
        &self.content
    }

    pub fn bytes_length(&self) -> u32 {
        u32::try_from(self.content.len()).unwrap_or(u32::MAX)
    }

    pub fn bom_prefix_length(&self) -> u32 {
        self.bom_prefix_length
    }

    pub fn slice(&self, span: Span) -> Option<&str> {
        let start = usize::try_from(span.start).ok()?;
        let ending = usize::try_from(span.ending).ok()?;
        self.content.get(start..ending)
    }

    pub fn line_and_column(&self, byte_offset: u32) -> (u32, u32) {
        self.line_index.line_and_column(&self.content, byte_offset)
    }
}
