use crate::identity::SourceIdentity;
use crate::line_index::LineIndex;
use crate::span::{SourceId, Span};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceFailure {
    pub description: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceText {
    source_id: SourceId,
    identity: Option<SourceIdentity>,
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
            source_id: SourceId::STANDALONE,
            identity: None,
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
        if span.source_id != self.source_id {
            return None;
        }
        let start = usize::try_from(span.start).ok()?;
        let ending = usize::try_from(span.ending).ok()?;
        self.content.get(start..ending)
    }

    pub fn line_and_column(&self, byte_offset: u32) -> (u32, u32) {
        self.line_index.line_and_column(&self.content, byte_offset)
    }
}

pub fn source_text_with_source_id(source_id: SourceId, content: String) -> SourceText {
    let mut source = SourceText::new(content);
    source.source_id = source_id;
    source
}

pub fn source_text_with_identity(identity: SourceIdentity, content: String) -> SourceText {
    let mut source = source_text_with_source_id(identity.source_id, content);
    source.identity = Some(identity);
    source
}

pub fn source_id(source: &SourceText) -> SourceId {
    source.source_id
}

pub fn source_identity(source: &SourceText) -> Option<SourceIdentity> {
    source.identity
}

pub fn is_valid_span(source: &SourceText, span: Span) -> bool {
    if span.source_id != source.source_id || span.start > span.ending {
        return false;
    }
    let Ok(start) = usize::try_from(span.start) else {
        return false;
    };
    let Ok(ending) = usize::try_from(span.ending) else {
        return false;
    };
    source.content.is_char_boundary(start) && source.content.is_char_boundary(ending)
}

pub fn scalar_offset(source: &SourceText, byte_offset: u32) -> Option<u32> {
    let byte_index = usize::try_from(byte_offset).ok()?;
    let prefix = source.content.get(..byte_index)?;
    u32::try_from(prefix.chars().count()).ok()
}

pub fn byte_offset_from_scalar(source: &SourceText, scalar_offset: u32) -> Option<u32> {
    let scalar_index = usize::try_from(scalar_offset).ok()?;
    let byte_offset = source
        .content
        .char_indices()
        .nth(scalar_index)
        .map(|(byte_index, _)| byte_index)
        .or_else(|| {
            (scalar_index == source.content.chars().count()).then_some(source.content.len())
        })?;
    u32::try_from(byte_offset).ok()
}

pub fn utf16_offset(source: &SourceText, byte_offset: u32) -> Option<u32> {
    let byte_index = usize::try_from(byte_offset).ok()?;
    let prefix = source.content.get(..byte_index)?;
    u32::try_from(prefix.encode_utf16().count()).ok()
}

pub fn byte_offset_from_utf16(source: &SourceText, utf16_offset: u32) -> Option<u32> {
    let target = usize::try_from(utf16_offset).ok()?;
    let mut units = 0_usize;
    for (byte_index, character) in source.content.char_indices() {
        if units == target {
            return u32::try_from(byte_index).ok();
        }
        units = units.checked_add(character.len_utf16())?;
        if units > target {
            return None;
        }
    }
    (units == target)
        .then(|| u32::try_from(source.content.len()).ok())
        .flatten()
}

pub fn line_and_column_utf16(source: &SourceText, byte_offset: u32) -> Option<(u32, u32)> {
    let (line, _) = source.line_and_column(byte_offset);
    let line_index = usize::try_from(line.checked_sub(1)?).ok()?;
    let line_start = source.line_index.line_start(line_index)?;
    let absolute_offset = utf16_offset(source, byte_offset)?;
    let line_offset = utf16_offset(source, line_start)?;
    let column = absolute_offset.checked_sub(line_offset)?.checked_add(1)?;
    Some((line, column))
}

pub fn byte_offset_from_line_column(
    source: &SourceText,
    line: u32,
    column: u32,
    utf16: bool,
) -> Option<u32> {
    if line == 0 || column == 0 {
        return None;
    }
    let line_index = usize::try_from(line.saturating_sub(1)).ok()?;
    let (start_index, end_index) = line_byte_range(source, line_index)?;
    let target_column = usize::try_from(column.saturating_sub(1)).ok()?;
    let line_text = source.content.get(start_index..end_index)?;
    let mut units = 0_usize;
    for (relative_index, character) in line_text.char_indices() {
        if units == target_column {
            return u32::try_from(start_index.checked_add(relative_index)?).ok();
        }
        units = units.checked_add(if utf16 { character.len_utf16() } else { 1 })?;
        if units > target_column {
            return None;
        }
    }
    (units == target_column)
        .then(|| u32::try_from(end_index).ok())
        .flatten()
}

fn line_byte_range(source: &SourceText, line_index: usize) -> Option<(usize, usize)> {
    let line_start = source.line_index.line_start(line_index)?;
    let start_index = usize::try_from(line_start).ok()?;
    let mut end_index = source
        .line_index
        .line_start(line_index.checked_add(1)?)
        .and_then(|offset| usize::try_from(offset).ok())
        .unwrap_or(source.content.len());
    while end_index > start_index
        && source
            .content
            .get(..end_index)
            .and_then(|prefix| prefix.chars().next_back())
            .is_some_and(|character| character == '\n' || character == '\r')
    {
        end_index = end_index.saturating_sub(1);
    }
    Some((start_index, end_index))
}
