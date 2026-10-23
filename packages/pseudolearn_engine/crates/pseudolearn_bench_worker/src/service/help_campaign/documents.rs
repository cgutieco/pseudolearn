use crate::service::corpus::reference_programs;
use crate::service::help_campaign::expectation::{Expectation, Query, queries};
use crate::service::help_campaign::oracle::Oracle;

pub const SEED: u64 = 42;
pub const LARGE_LINES: usize = 10_000;
pub const SMALL_TARGET_LINES: usize = 40;

pub struct Document {
    pub name: String,
    pub profile: &'static str,
    pub program: String,
    pub queries: Vec<Query>,
}

pub struct Generator(u64);

impl Generator {
    pub fn new(seed: u64) -> Self {
        Self(seed.max(1))
    }

    pub fn next(&mut self) -> u64 {
        let mut state = self.0;
        state ^= state << 13;
        state ^= state >> 7;
        state ^= state << 17;
        self.0 = state;
        state
    }

    pub fn below(&mut self, bound: usize) -> usize {
        let bound = u64::try_from(bound.max(1)).unwrap_or(1);
        usize::try_from(self.next().checked_rem(bound).unwrap_or(0)).unwrap_or(0)
    }
}

pub fn pick(mut candidates: Vec<Query>, count: usize) -> Vec<Query> {
    let mut generator = Generator::new(SEED);
    let mut chosen = Vec::new();
    while chosen.len() < count && !candidates.is_empty() {
        let index = generator.below(candidates.len());
        chosen.push(candidates.swap_remove(index));
    }
    chosen
}

pub fn small(oracle: &Oracle, count: usize) -> Result<Document, String> {
    let programs = reference_programs()?;
    let program = programs
        .into_iter()
        .filter(|entry| !entry.name.ends_with("_en.pseudo"))
        .min_by_key(|entry| entry.text.lines().count().abs_diff(SMALL_TARGET_LINES))
        .ok_or("No reference programs")?;
    let candidates: Vec<Query> = queries(oracle, "es", &program.text, false)
        .into_iter()
        .filter(|query| matches!(query.expectation, Expectation::Keyword(_)))
        .collect();
    Ok(Document {
        name: program.name,
        profile: "es",
        program: program.text,
        queries: pick(candidates, count),
    })
}

pub fn large(oracle: &Oracle, count: usize) -> Result<Document, String> {
    let program = large_program();
    let candidates: Vec<Query> = queries(oracle, "es", &program, false)
        .into_iter()
        .filter(|query| matches!(query.expectation, Expectation::Keyword(_)))
        .collect();
    Ok(Document {
        name: format!("generated-{LARGE_LINES}"),
        profile: "es",
        program,
        queries: pick(candidates, count),
    })
}

const BLOCKS: [&str; 3] = [
    "  Mientras total < 10 Hacer\n    total <- total + 1;\n  FinMientras\n",
    "  Para indice <- 1 Hasta 3 Con Paso 1 Hacer\n    Escribir indice;\n  FinPara\n",
    "  Si total = 3 Entonces\n    Escribir total;\n  FinSi\n",
];
const FILLER: &str = "  Escribir Longitud(\"x\");\n";

fn large_program() -> String {
    let mut program = String::from("Algoritmo Carga\n  Definir total, indice Como Entero;\n");
    let mut lines = 2usize;
    let body_limit = LARGE_LINES.saturating_sub(1);
    let mut round = 0usize;
    while lines.saturating_add(3) <= body_limit {
        let block = BLOCKS
            .get(round.checked_rem(BLOCKS.len()).unwrap_or(0))
            .copied()
            .unwrap_or(FILLER);
        program.push_str(block);
        lines = lines.saturating_add(3);
        round = round.saturating_add(1);
    }
    while lines < body_limit {
        program.push_str(FILLER);
        lines = lines.saturating_add(1);
    }
    program.push_str("FinAlgoritmo\n");
    program
}
