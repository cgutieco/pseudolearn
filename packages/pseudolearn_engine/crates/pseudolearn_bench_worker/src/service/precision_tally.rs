use crate::service::corpus::{ReferenceProgram, reference_programs};
use crate::service::statistics::percent;
use pseudolearn_api::service::{
    CompletionProbe, DocumentSession, Profile, completion_probes, truncated_query,
};
use serde_json::{Value, json};
use std::time::Instant;

const RANKING_WINDOW: usize = 5;
const PREFIXES: [usize; 2] = [0, 2];

#[derive(Default)]
pub struct Tally {
    pub queries: usize,
    pub first: usize,
    pub within_window: usize,
    pub saved_chars: usize,
    pub total_chars: usize,
}

impl Tally {
    fn record(&mut self, rank: Option<usize>, probe: &CompletionProbe, typed: usize) {
        self.queries = self.queries.saturating_add(1);
        self.total_chars = self.total_chars.saturating_add(probe.token_chars);
        let Some(position) = rank else {
            return;
        };
        if position == 0 {
            self.first = self.first.saturating_add(1);
        }
        if position < RANKING_WINDOW {
            self.within_window = self.within_window.saturating_add(1);
            let saved = probe.token_chars.saturating_sub(typed).saturating_sub(1);
            self.saved_chars = self.saved_chars.saturating_add(saved);
        }
    }

    fn merge(&mut self, other: &Tally) {
        self.queries = self.queries.saturating_add(other.queries);
        self.first = self.first.saturating_add(other.first);
        self.within_window = self.within_window.saturating_add(other.within_window);
        self.saved_chars = self.saved_chars.saturating_add(other.saved_chars);
        self.total_chars = self.total_chars.saturating_add(other.total_chars);
    }

    pub fn precision_at_five(&self) -> f64 {
        percent(self.within_window, self.queries)
    }

    pub fn to_json(&self) -> Value {
        json!({
            "queries": self.queries,
            "precision_at_1_percent": percent(self.first, self.queries),
            "precision_at_5_percent": self.precision_at_five(),
            "keystrokes_saved_percent": percent(self.saved_chars, self.total_chars),
        })
    }
}

#[derive(Default)]
pub struct Evaluation {
    tallies: [[Tally; 2]; 2],
    pub latencies: Vec<f64>,
    pub programs: usize,
}

impl Evaluation {
    pub fn tally(&self, profile: Profile, prefix_slot: usize) -> Option<&Tally> {
        self.tallies
            .get(usize::from(profile == Profile::English))
            .and_then(|row| row.get(prefix_slot))
    }

    pub fn merged(&self, prefix_slot: usize) -> Tally {
        let mut total = Tally::default();
        for row in &self.tallies {
            if let Some(tally) = row.get(prefix_slot) {
                total.merge(tally);
            }
        }
        total
    }
}

fn query_rank(
    program: &ReferenceProgram,
    probe: &CompletionProbe,
    typed: usize,
) -> (Option<usize>, f64) {
    let (truncated, position) = truncated_query(&program.text, probe, typed);
    let session = DocumentSession::new(truncated, program.profile, false);
    let started = Instant::now();
    let entries = session.queries().complete(position);
    let elapsed = started.elapsed().as_secs_f64() * 1000.0;
    let wanted = program.profile.fold_word(&probe.expected);
    let rank = entries
        .iter()
        .position(|entry| program.profile.fold_word(&entry.label) == wanted);
    (rank, elapsed)
}

fn evaluate_program(program: &ReferenceProgram, evaluation: &mut Evaluation) {
    evaluation.programs = evaluation.programs.saturating_add(1);
    let profile_slot = usize::from(program.profile == Profile::English);
    for probe in completion_probes(&program.text, program.profile) {
        for (prefix_slot, typed) in PREFIXES.into_iter().enumerate() {
            let (rank, elapsed) = query_rank(program, &probe, typed);
            evaluation.latencies.push(elapsed);
            let slot = evaluation
                .tallies
                .get_mut(profile_slot)
                .and_then(|row| row.get_mut(prefix_slot));
            if let Some(tally) = slot {
                tally.record(rank, &probe, typed);
            }
        }
    }
}

pub fn evaluate() -> Result<Evaluation, String> {
    let mut evaluation = Evaluation::default();
    for program in reference_programs()? {
        evaluate_program(&program, &mut evaluation);
    }
    Ok(evaluation)
}
