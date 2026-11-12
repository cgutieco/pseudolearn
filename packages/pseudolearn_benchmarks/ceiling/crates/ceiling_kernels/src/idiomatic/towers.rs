struct Towers {
    piles: [Vec<usize>; 3],
    moves: u64,
}

impl Towers {
    fn shift(&mut self, from: usize, destination: usize) {
        let disk = self
            .piles
            .get_mut(from)
            .and_then(Vec::pop)
            .unwrap_or_default();
        if let Some(pile) = self.piles.get_mut(destination) {
            pile.push(disk);
        }
        self.moves = self.moves.wrapping_add(1);
    }

    fn solve(&mut self, disks: usize, from: usize, destination: usize) {
        if disks == 1 {
            self.shift(from, destination);
            return;
        }
        let other = 3_usize.wrapping_sub(from).wrapping_sub(destination);
        self.solve(disks.wrapping_sub(1), from, other);
        self.shift(from, destination);
        self.solve(disks.wrapping_sub(1), other, destination);
    }
}

pub fn run(size: usize) -> String {
    let mut towers = Towers {
        piles: [(1..=size).rev().collect(), Vec::new(), Vec::new()],
        moves: 0,
    };
    towers.solve(size, 0, 1);
    towers.moves.to_string()
}
