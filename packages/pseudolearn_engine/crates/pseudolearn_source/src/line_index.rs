#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LineIndex {
    line_starts: Vec<u32>,
}

impl LineIndex {
    pub fn build(text: &str) -> Self {
        let mut line_starts = vec![0];
        let mut byte_offset = 0u32;
        let mut characters = text.chars().peekable();
        while let Some(character) = characters.next() {
            let character_length = u32::try_from(character.len_utf8()).unwrap_or(1);
            let next_offset = byte_offset.saturating_add(character_length);
            if character == '\r' {
                if characters.peek() == Some(&'\n') {
                    characters.next();
                    let carriage_return_advance = next_offset.saturating_add(1);
                    line_starts.push(carriage_return_advance);
                    byte_offset = carriage_return_advance;
                    continue;
                }
                line_starts.push(next_offset);
            } else if character == '\n' {
                line_starts.push(next_offset);
            }
            byte_offset = next_offset;
        }
        Self { line_starts }
    }

    pub fn line_count(&self) -> usize {
        self.line_starts.len()
    }

    pub fn line_start(&self, line_index: usize) -> Option<u32> {
        self.line_starts.get(line_index).copied()
    }

    pub fn line_and_column(&self, text: &str, byte_offset: u32) -> (u32, u32) {
        let line_number = self.locate_line(byte_offset);
        let start_index = usize::try_from(line_number.saturating_sub(1)).unwrap_or(0);
        let line_start_offset = self.line_starts.get(start_index).copied().unwrap_or(0);
        let column_number = self.compute_column(text, line_start_offset, byte_offset);
        (line_number, column_number)
    }

    fn locate_line(&self, byte_offset: u32) -> u32 {
        let partition = match self.line_starts.binary_search(&byte_offset) {
            Ok(exact_index) => exact_index.saturating_add(1),
            Err(insertion_index) => insertion_index,
        };
        u32::try_from(partition).unwrap_or(1)
    }

    fn compute_column(&self, text: &str, line_start_offset: u32, target_offset: u32) -> u32 {
        let start_index = usize::try_from(line_start_offset).unwrap_or(0);
        let target_index = usize::try_from(target_offset).unwrap_or(start_index);
        let slice = text.get(start_index..target_index).unwrap_or("");
        let count = u32::try_from(slice.chars().count()).unwrap_or(0);
        count.saturating_add(1)
    }
}
