#![forbid(unsafe_code)]

use pseudolearn_source::SourceId;

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct IrSpan {
    pub source_id: SourceId,
    pub start_line: u32,
    pub start_column: u32,
    pub end_line: u32,
    pub end_column: u32,
}

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct IrPosition {
    pub line: u32,
    pub column: u32,
}

impl IrPosition {
    pub const fn new(line: u32, column: u32) -> Self {
        Self { line, column }
    }
}

impl IrSpan {
    pub const fn new(start_line: u32, start_column: u32, end_line: u32, end_column: u32) -> Self {
        Self {
            source_id: SourceId::STANDALONE,
            start_line,
            start_column,
            end_line,
            end_column,
        }
    }

    pub const fn in_source(source_id: SourceId, start: IrPosition, end: IrPosition) -> Self {
        Self {
            source_id,
            start_line: start.line,
            start_column: start.column,
            end_line: end.line,
            end_column: end.column,
        }
    }

    pub fn is_valid(self) -> bool {
        self.start_line > 0
            && self.start_column > 0
            && self.end_line > 0
            && self.end_column > 0
            && (self.start_line, self.start_column) <= (self.end_line, self.end_column)
    }

    pub fn format_span(&self) -> String {
        let coordinates = format!(
            "{}:{}-{}:{}",
            self.start_line, self.start_column, self.end_line, self.end_column
        );
        if self.source_id == SourceId::STANDALONE {
            format!("@{coordinates}")
        } else {
            format!("@f{}:{coordinates}", self.source_id.value())
        }
    }

    pub fn parse(text: &str) -> Option<Self> {
        let stripped = text.strip_prefix('@')?;
        let (source_id, coordinates) = match stripped.strip_prefix('f') {
            Some(qualified) => {
                let (identifier, coordinates) = qualified.split_once(':')?;
                (
                    SourceId::new(identifier.parse::<u32>().ok().filter(|value| *value > 0)?),
                    coordinates,
                )
            }
            None => (SourceId::STANDALONE, stripped),
        };
        let (start_part, end_part) = coordinates.split_once('-')?;
        let (start_line_str, start_col_str) = start_part.split_once(':')?;
        let (end_line_str, end_col_str) = end_part.split_once(':')?;
        let start_line = start_line_str.parse::<u32>().ok()?;
        let start_column = start_col_str.parse::<u32>().ok()?;
        let end_line = end_line_str.parse::<u32>().ok()?;
        let end_column = end_col_str.parse::<u32>().ok()?;
        Some(Self {
            source_id,
            start_line,
            start_column,
            end_line,
            end_column,
        })
    }
}

impl std::fmt::Display for IrSpan {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(formatter, "{}", self.format_span())
    }
}
