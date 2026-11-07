use crate::route_mix::fence;
use reference_model::{AssertionSource, CaseSource, RouteFence, SourceBlock};

pub const CONSTRUCTS: [&str; 9] = [
    "condicional",
    "seleccion-multiple",
    "bucle-condicional",
    "bucle-condicional-posterior",
    "bucle-contado",
    "arreglo",
    "subprograma",
    "clase",
    "interfaz",
];

pub fn assertion_problems(blocks: &[SourceBlock]) -> Vec<String> {
    let Some(RouteFence::Assertions(assertions)) = fence(blocks, "aserciones") else {
        return Vec::new();
    };
    assertions.iter().filter_map(assertion_problem).collect()
}

fn assertion_problem(assertion: &AssertionSource) -> Option<String> {
    let fields: Vec<&str> = assertion.fields.iter().map(String::as_str).collect();
    let valid = match (assertion.kind.as_str(), fields.as_slice()) {
        ("contiene" | "no-contiene", [construct]) => CONSTRUCTS.contains(construct),
        ("repite-como-mucho", [construct, maximum]) => {
            CONSTRUCTS.contains(construct) && maximum.parse::<u32>().is_ok()
        }
        ("declara-subprograma", [name, arity]) => !name.is_empty() && arity.parse::<u32>().is_ok(),
        ("declara-miembro", [class, member, visibility]) => {
            !class.is_empty() && !member.is_empty() && matches!(*visibility, "publico" | "privado")
        }
        _ => false,
    };
    let problem = if assertion.requirement.is_empty() {
        Some("an assertion needs the requirement shown to the student".to_owned())
    } else {
        None
    };
    problem.or_else(|| {
        (!valid).then(|| {
            format!(
                "the assertion `{}` {:?} is not in the closed catalog",
                assertion.kind, assertion.fields
            )
        })
    })
}

pub fn solution_problems(blocks: &[SourceBlock]) -> Vec<String> {
    let Some(RouteFence::SolutionCases {
        minimum,
        maximum,
        cases,
    }) = fence(blocks, "casos-solucion")
    else {
        return vec!["a test design exercise needs `casos-solucion`".to_owned()];
    };
    let mut problems = Vec::new();
    if *minimum < 1 || minimum > maximum {
        problems.push(format!(
            "the case limits {minimum} to {maximum} are not valid"
        ));
    }
    if cases.len() < *minimum || cases.len() > *maximum {
        problems.push(format!(
            "the solution has {} cases outside {minimum} to {maximum}",
            cases.len()
        ));
    }
    problems
}

pub fn breaker_problems(blocks: &[SourceBlock]) -> Vec<String> {
    let (Some(RouteFence::Cases(cases)), Some(RouteFence::Breakers(breakers))) =
        (fence(blocks, "casos"), fence(blocks, "rompe"))
    else {
        return vec!["a break exercise needs `casos` and `rompe`".to_owned()];
    };
    let reads = reads(cases);
    breakers
        .iter()
        .filter(|breaker| breaker.inputs.len() != reads)
        .map(|breaker| {
            format!(
                "the breaking input {:?} does not give the {reads} values the program reads",
                breaker.inputs
            )
        })
        .collect()
}

fn reads(cases: &[CaseSource]) -> usize {
    cases
        .iter()
        .map(|case| case.inputs.len())
        .max()
        .unwrap_or_default()
}

pub fn lap_problems(blocks: &[SourceBlock]) -> Vec<String> {
    let Some(RouteFence::Laps(table)) = fence(blocks, "vueltas") else {
        return vec!["a trace exercise needs `vueltas`".to_owned()];
    };
    let editable = table
        .rows
        .iter()
        .flat_map(|row| row.cells.iter())
        .any(|cell| cell.starts_with('?'));
    let mut problems = Vec::new();
    if !editable {
        problems.push("the trace table has no cell for the student to fill".to_owned());
    }
    if table
        .rows
        .iter()
        .any(|row| row.cells.len() != table.columns.len())
    {
        problems.push("every trace row needs one cell per column".to_owned());
    }
    if table.rows.iter().any(|row| row.label == "antes") && table.start.is_none() {
        problems.push("the `antes` row needs `inicio=<line>`".to_owned());
    }
    problems
}

pub fn category_count_problem(blocks: &[SourceBlock]) -> Option<String> {
    match fence(blocks, "categorias") {
        Some(RouteFence::Categories(categories)) if categories.len() < 2 => {
            Some("a classify exercise needs at least two categories".to_owned())
        }
        _ => None,
    }
}
