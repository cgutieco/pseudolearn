#[derive(Clone, Copy, Debug, PartialEq)]
pub struct SchedulerOptions {
    pub minimum_distance: u64,
    pub kappa_factor: u64,
    pub maximum_distance: u64,
}

impl Default for SchedulerOptions {
    fn default() -> Self {
        Self {
            minimum_distance: 131_072,
            kappa_factor: 16,
            maximum_distance: 262_144,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct CostScheduler {
    pub options: SchedulerOptions,
    pub last_checkpoint_statements: u64,
    pub next_checkpoint_statements: u64,
}

impl CostScheduler {
    pub fn new(options: SchedulerOptions) -> Self {
        let next_checkpoint_statements = options.minimum_distance;
        Self {
            options,
            last_checkpoint_statements: 0,
            next_checkpoint_statements,
        }
    }

    pub fn should_checkpoint(&self, current_statements: u64) -> bool {
        current_statements >= self.next_checkpoint_statements
    }

    pub fn record_checkpoint(&mut self, current_statements: u64, state_words: usize) {
        self.last_checkpoint_statements = current_statements;
        let words_u64 = u64::try_from(state_words).unwrap_or(u64::MAX);
        let proportional_cost = self.options.kappa_factor.saturating_mul(words_u64);
        let scheduled_distance = self
            .options
            .minimum_distance
            .max(proportional_cost.min(self.options.maximum_distance));
        self.next_checkpoint_statements = current_statements.saturating_add(scheduled_distance);
    }
}
