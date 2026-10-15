#![forbid(unsafe_code)]

use see_oracles::mathematics::{Function, power, rounded};

use crate::math_arguments::MathFunction;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MathOutcome {
    Finite(u64),
    NonFinite,
}

pub fn expected(function: MathFunction, arguments: &[f64]) -> Result<MathOutcome, String> {
    let result = match (function, arguments) {
        (MathFunction::Power, [base, exponent]) => power(*base, *exponent),
        (_, [argument]) => rounded(oracle_function(function, *argument)?, *argument),
        _ => return Err("Argument count does not match the function".to_owned()),
    };
    match result {
        Ok(value) if value.is_finite() => Ok(MathOutcome::Finite(value.to_bits())),
        Ok(_) => Ok(MathOutcome::NonFinite),
        Err(error) if error == "ORACLE-DOMAIN" => Ok(MathOutcome::NonFinite),
        Err(error) => Err(error),
    }
}

fn oracle_function(function: MathFunction, argument: f64) -> Result<Function, String> {
    let selected = match function {
        MathFunction::Exponential => Function::Exponential,
        MathFunction::Logarithm => Function::Logarithm,
        MathFunction::Sine => Function::Sine,
        MathFunction::Cosine => Function::Cosine,
        MathFunction::Arctangent => Function::Arctangent,
        MathFunction::Power => return Err(format!("Power requires two arguments, got {argument}")),
    };
    Ok(selected)
}

pub fn format_outcome(outcome: MathOutcome) -> String {
    match outcome {
        MathOutcome::Finite(bits) => format!("{bits:016x}"),
        MathOutcome::NonFinite => "nonFiniteRealResult".to_owned(),
    }
}

pub fn parse_outcome(text: &str) -> Result<MathOutcome, String> {
    if text == "nonFiniteRealResult" {
        return Ok(MathOutcome::NonFinite);
    }
    u64::from_str_radix(text, 16)
        .map(MathOutcome::Finite)
        .map_err(|_| format!("Invalid engine result: {text}"))
}

pub fn format_arguments(arguments: &[f64]) -> String {
    arguments
        .iter()
        .map(|value| format!("{:016x}", value.to_bits()))
        .collect::<Vec<_>>()
        .join(" ")
}

pub fn parse_arguments(line: &str) -> Result<Vec<f64>, String> {
    line.split_whitespace()
        .map(|word| {
            u64::from_str_radix(word, 16)
                .map(f64::from_bits)
                .map_err(|_| format!("Invalid argument: {word}"))
        })
        .collect()
}
