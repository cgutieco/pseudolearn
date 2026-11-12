use super::AwfyRandom;

struct Ball {
    horizontal: i64,
    vertical: i64,
    horizontal_speed: i64,
    vertical_speed: i64,
}

fn coordinate(random: &mut AwfyRandom, modulus: u32, offset: i64) -> i64 {
    i64::from(random.draw().checked_rem(modulus).unwrap_or_default()).wrapping_sub(offset)
}

fn clamp(position: &mut i64, speed: &mut i64) -> bool {
    if *position > 500 {
        *position = 500;
        *speed = speed.wrapping_abs().wrapping_neg();
        return true;
    }
    if *position < 0 {
        *position = 0;
        *speed = speed.wrapping_abs();
        return true;
    }
    false
}

impl Ball {
    fn new(random: &mut AwfyRandom) -> Self {
        Self {
            horizontal: coordinate(random, 500, 0),
            vertical: coordinate(random, 500, 0),
            horizontal_speed: coordinate(random, 300, 150),
            vertical_speed: coordinate(random, 300, 150),
        }
    }

    fn bounce(&mut self) -> bool {
        self.horizontal = self.horizontal.wrapping_add(self.horizontal_speed);
        self.vertical = self.vertical.wrapping_add(self.vertical_speed);
        let horizontal = clamp(&mut self.horizontal, &mut self.horizontal_speed);
        let vertical = clamp(&mut self.vertical, &mut self.vertical_speed);
        horizontal | vertical
    }
}

pub fn run(size: usize) -> String {
    let mut random = AwfyRandom::default();
    let mut balls: Vec<Ball> = (0..100).map(|_| Ball::new(&mut random)).collect();
    let mut bounces = 0_u64;
    for _ in 0..size {
        for ball in &mut balls {
            bounces = bounces.wrapping_add(u64::from(ball.bounce()));
        }
    }
    bounces.to_string()
}
