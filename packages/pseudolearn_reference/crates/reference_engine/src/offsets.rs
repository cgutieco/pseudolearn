pub struct LineStarts {
    starts: Vec<usize>,
}

impl LineStarts {
    pub fn new(code: &str) -> Self {
        let mut starts = vec![0];
        for (index, character) in code.chars().enumerate() {
            if character == '\n' {
                starts.push(index.saturating_add(1));
            }
        }
        Self { starts }
    }

    pub fn offset(&self, line: u32, column: u32) -> usize {
        let line_index = usize::try_from(line.saturating_sub(1)).unwrap_or_default();
        let column_index = usize::try_from(column.saturating_sub(1)).unwrap_or_default();
        self.starts
            .get(line_index)
            .copied()
            .unwrap_or_default()
            .saturating_add(column_index)
    }
}
