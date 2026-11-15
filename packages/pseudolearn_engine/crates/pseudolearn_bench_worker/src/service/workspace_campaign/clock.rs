use std::time::{Duration, Instant};

pub trait Clock {
    fn now_nanos(&mut self) -> u64;
}

pub struct SystemClock {
    origin: Instant,
}

impl SystemClock {
    pub fn new() -> Self {
        Self {
            origin: Instant::now(),
        }
    }
}

impl Clock for SystemClock {
    fn now_nanos(&mut self) -> u64 {
        u64::try_from(self.origin.elapsed().as_nanos()).unwrap_or(u64::MAX)
    }
}

pub fn nanos_to_millis(nanos: u64) -> f64 {
    Duration::from_nanos(nanos).as_secs_f64() * 1000.0
}
