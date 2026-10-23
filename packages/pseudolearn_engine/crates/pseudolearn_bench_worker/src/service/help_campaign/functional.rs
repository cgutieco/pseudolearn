use crate::service::corpus::reference_programs;
use crate::service::help_campaign::digest::Digest;
use crate::service::help_campaign::expectation::{Expectation, Query, Variant, queries, variants};
use crate::service::help_campaign::judging::{Context, judge_api, judge_lsp, same_range};
use crate::service::help_campaign::oracle::Oracle;
use crate::service::help_campaign::transports::{Answer, ApiTransport, LspTransport};
use serde_json::{Value, json};

const COMBINATIONS: [(&str, &str); 4] = [
    ("strict", "es"),
    ("strict", "en"),
    ("flexible", "es"),
    ("flexible", "en"),
];

#[derive(Default)]
pub struct Tally {
    pub expected: u64,
    pub completed: u64,
    pub with_help: u64,
    pub valid_absence: u64,
    pub partial: u64,
    pub wrong: u64,
    pub parity_mismatches: u64,
}

impl Tally {
    fn count(&mut self, verdict: &Result<(), String>, query: &Query, partial: bool) {
        self.expected = self.expected.saturating_add(1);
        self.completed = self.completed.saturating_add(1);
        if verdict.is_err() {
            self.wrong = self.wrong.saturating_add(1);
        } else if matches!(query.expectation, Expectation::Absent) {
            self.valid_absence = self.valid_absence.saturating_add(1);
        } else {
            self.with_help = self.with_help.saturating_add(1);
            self.partial = self.partial.saturating_add(u64::from(partial));
        }
    }

    pub fn to_json(&self) -> Value {
        json!({
            "expected": self.expected,
            "completed": self.completed,
            "with_help": self.with_help,
            "valid_absence": self.valid_absence,
            "partial": self.partial,
            "wrong": self.wrong,
            "parity_mismatches": self.parity_mismatches,
        })
    }
}

pub struct Report {
    pub api: Tally,
    pub lsp: Tally,
    pub failures: Vec<String>,
    pub programs: usize,
    pub digest: String,
}

impl Report {
    fn note(&mut self, label: &str, query: &Query, outcome: (&str, &Result<(), String>)) {
        if let (transport, Err(reason)) = outcome {
            self.failures.push(format!(
                "{label} {}:{} {transport}: {reason}",
                query.line, query.column
            ));
        }
    }
}

struct Combination<'combination> {
    label: String,
    profile: &'combination str,
    strictness: &'combination str,
    language: &'combination str,
}

pub fn run(oracle: &Oracle) -> Result<Report, String> {
    let mut report = Report {
        api: Tally::default(),
        lsp: Tally::default(),
        failures: Vec::new(),
        programs: 0,
        digest: String::new(),
    };
    let mut digest = Digest::new();
    for program in reference_programs()? {
        report.programs = report.programs.saturating_add(1);
        for variant in variants(&program.text) {
            run_variant(oracle, &mut report, &mut digest, (&program.name, &variant))?;
        }
    }
    report.digest = digest.hex();
    Ok(report)
}

fn run_variant(
    oracle: &Oracle,
    report: &mut Report,
    digest: &mut Digest,
    input: (&str, &Variant),
) -> Result<(), String> {
    let (name, variant) = input;
    let profile = if name.ends_with("_en.pseudo") {
        "en"
    } else {
        "es"
    };
    let set = queries(
        oracle,
        profile,
        &variant.program,
        name.contains("nombre_no_reservado"),
    );
    for query in &set {
        digest
            .feed(format!("{name}:{}:{}:{}\n", variant.name, query.line, query.column).as_bytes());
    }
    for (strictness, language) in COMBINATIONS {
        let combination = Combination {
            label: format!("{name} {} {strictness} {language}", variant.name),
            profile,
            strictness,
            language,
        };
        run_combination(oracle, report, &combination, (variant, &set))?;
    }
    Ok(())
}

fn run_combination(
    oracle: &Oracle,
    report: &mut Report,
    combination: &Combination<'_>,
    input: (&Variant, &[Query]),
) -> Result<(), String> {
    let (variant, set) = input;
    let mut api = ApiTransport::open(
        &variant.program,
        combination.profile,
        combination.strictness,
        combination.language,
    )?;
    let mut lsp = LspTransport::open(
        &variant.program,
        combination.language,
        combination.strictness,
    );
    let context = Context {
        language: combination.language,
        partial: variant.partial,
    };
    for query in set {
        let answer = api.query(query.line, query.column)?;
        let verdict = judge_api(oracle, &answer, query, &context);
        report.api.count(&verdict, query, variant.partial);
        report.note(&combination.label, query, ("api", &verdict));
        check_hover(
            oracle,
            report,
            (combination, &context),
            (&mut lsp, query, &answer),
        );
    }
    Ok(())
}

fn check_hover(
    oracle: &Oracle,
    report: &mut Report,
    scope: (&Combination<'_>, &Context<'_>),
    hover: (&mut LspTransport, &Query, &Answer),
) {
    let (combination, context) = scope;
    let (lsp, query, answer) = hover;
    let (text, range) = lsp.hover(query.line, query.column);
    let verdict = judge_lsp(oracle, text.as_ref(), query, combination.language);
    report.lsp.count(&verdict, query, context.partial);
    report.note(&combination.label, query, ("lsp", &verdict));
    let differs = range
        .as_ref()
        .is_some_and(|shown| answer.range.is_some() && !same_range(lsp, answer, shown));
    if differs {
        report.lsp.parity_mismatches = report.lsp.parity_mismatches.saturating_add(1);
        let mismatch: Result<(), String> = Err("range differs from the API".to_owned());
        report.note(&combination.label, query, ("lsp", &mismatch));
    }
}
