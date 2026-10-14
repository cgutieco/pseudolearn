struct Board {
    size: usize,
    rows: Vec<bool>,
    rising: Vec<bool>,
    falling: Vec<bool>,
}

impl Board {
    fn free(&self, row: usize, column: usize) -> bool {
        let falling = row
            .wrapping_add(self.size)
            .wrapping_sub(1)
            .wrapping_sub(column);
        self.rows.get(row).copied().unwrap_or(false)
            && self
                .rising
                .get(row.wrapping_add(column))
                .copied()
                .unwrap_or(false)
            && self.falling.get(falling).copied().unwrap_or(false)
    }

    fn mark(&mut self, row: usize, column: usize, value: bool) {
        let falling = row
            .wrapping_add(self.size)
            .wrapping_sub(1)
            .wrapping_sub(column);
        for (cells, position) in [
            (&mut self.rows, row),
            (&mut self.rising, row.wrapping_add(column)),
            (&mut self.falling, falling),
        ] {
            if let Some(cell) = cells.get_mut(position) {
                *cell = value;
            }
        }
    }

    fn place(&mut self, column: usize) -> u64 {
        if column == self.size {
            return 1;
        }
        let mut total = 0_u64;
        for row in 0..self.size {
            if self.free(row, column) {
                self.mark(row, column, false);
                total = total.wrapping_add(self.place(column.wrapping_add(1)));
                self.mark(row, column, true);
            }
        }
        total
    }
}

pub fn run(size: usize) -> String {
    let mut board = Board {
        size,
        rows: vec![true; 16],
        rising: vec![true; 16],
        falling: vec![true; 16],
    };
    board.place(0).to_string()
}
