pub mod bounce;
pub mod list;
pub mod mandelbrot;
pub mod nbody;
pub mod permute;
pub mod queens;
pub mod richards;
mod richards_roles;
mod richards_tasks;
pub mod sieve;
pub mod storage;
pub mod towers;

pub struct AwfyRandom {
    seed: u32,
}

impl Default for AwfyRandom {
    fn default() -> Self {
        Self { seed: 74755 }
    }
}

impl AwfyRandom {
    pub fn draw(&mut self) -> u32 {
        self.seed = self.seed.wrapping_mul(1309).wrapping_add(13849) & 65535;
        self.seed
    }
}
