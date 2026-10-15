#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct IrSpan {
    pub start_line: u32,
    pub start_column: u32,
    pub end_line: u32,
    pub end_column: u32,
}

impl IrSpan {
    pub const fn new(start_line: u32, start_column: u32, end_line: u32, end_column: u32) -> Self {
        Self {
            start_line,
            start_column,
            end_line,
            end_column,
        }
    }

    pub fn format_span(&self) -> String {
        format!(
            "@{}:{}-{}:{}",
            self.start_line, self.start_column, self.end_line, self.end_column
        )
    }

    pub fn parse(text: &str) -> Option<Self> {
        let stripped = text.strip_prefix('@')?;
        let (start_part, end_part) = stripped.split_once('-')?;
        let (start_line_str, start_col_str) = start_part.split_once(':')?;
        let (end_line_str, end_col_str) = end_part.split_once(':')?;
        let start_line = start_line_str.parse::<u32>().ok()?;
        let start_column = start_col_str.parse::<u32>().ok()?;
        let end_line = end_line_str.parse::<u32>().ok()?;
        let end_column = end_col_str.parse::<u32>().ok()?;
        Some(Self {
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
