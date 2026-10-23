use crate::service::help_campaign::oracle::Oracle;
use crate::service::help_campaign::scanner::{Occurrence, scan};

#[derive(Clone)]
pub enum Expectation {
    Keyword(Occurrence),
    UserSymbol(Occurrence),
    Absent,
}

pub struct Query {
    pub line: u32,
    pub column: u32,
    pub expectation: Expectation,
}

pub struct Variant {
    pub name: &'static str,
    pub program: String,
    pub partial: bool,
}

fn is_discardable(line: &str) -> bool {
    line.trim().is_empty() || line.trim_start().starts_with("//")
}

pub fn variants(program: &str) -> Vec<Variant> {
    let mut kept: Vec<&str> = program.lines().collect();
    while kept.last().is_some_and(|line| is_discardable(line)) {
        kept.pop();
    }
    kept.pop();
    let mut truncated = kept.join("\n");
    truncated.push('\n');
    vec![
        Variant {
            name: "full",
            program: program.to_owned(),
            partial: false,
        },
        Variant {
            name: "truncated",
            program: truncated,
            partial: true,
        },
    ]
}

fn expectation_for(oracle: &Oracle, occurrence: &Occurrence, shadows: bool) -> Expectation {
    if shadows && oracle.is_function(&occurrence.identity) {
        Expectation::UserSymbol(occurrence.clone())
    } else {
        Expectation::Keyword(occurrence.clone())
    }
}

pub fn queries(oracle: &Oracle, profile: &str, program: &str, shadows: bool) -> Vec<Query> {
    let scanned = scan(oracle, profile, program);
    let mut found = Vec::new();
    for occurrence in scanned.occurrences {
        let width = u32::try_from(occurrence.word.chars().count()).unwrap_or(0);
        let expectation = expectation_for(oracle, &occurrence, shadows);
        found.push(Query {
            line: occurrence.line,
            column: occurrence.column,
            expectation: expectation.clone(),
        });
        if width >= 3 {
            found.push(Query {
                line: occurrence.line,
                column: occurrence.column.saturating_add(1),
                expectation,
            });
        }
    }
    found.extend(scanned.inert_positions.into_iter().map(|blank| Query {
        line: blank.line,
        column: blank.column,
        expectation: Expectation::Absent,
    }));
    found
}
