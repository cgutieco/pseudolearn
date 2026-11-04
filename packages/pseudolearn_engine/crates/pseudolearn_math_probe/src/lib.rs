#![forbid(unsafe_code)]

use std::path::Path;

use pseudolearn_library::{
    LibraryError, arc_cosine, arc_sine, arc_tangent2, arctangent, cosine, exponential, logarithm2,
    logarithm10, natural_logarithm, real_power, sine, tangent,
};

type Unary = fn(f64) -> Result<f64, LibraryError>;

const UNARY: [(&str, Unary); 10] = [
    ("exp", exponential),
    ("ln", natural_logarithm),
    ("sin", sine),
    ("cos", cosine),
    ("atan", arctangent),
    ("tan", tangent),
    ("asin", arc_sine),
    ("acos", arc_cosine),
    ("log2", logarithm2),
    ("log10", logarithm10),
];

pub fn probe_directory(directory: &Path) -> Result<usize, String> {
    if !directory.is_dir() {
        return Err("Argument directory does not exist".to_owned());
    }
    let mut evaluated = 0_usize;
    for name in [
        "exp", "ln", "sin", "cos", "atan", "pow", "tan", "asin", "acos", "atan2", "log2", "log10",
    ] {
        let source = directory.join(format!("{name}.arguments"));
        if !source.exists() {
            continue;
        }
        let text = std::fs::read_to_string(&source)
            .map_err(|error| format!("{}: {error}", source.display()))?;
        let mut output = String::with_capacity(text.len());
        for line in text.lines() {
            output.push_str(&evaluate_line(name, line)?);
            output.push('\n');
            evaluated = evaluated.saturating_add(1);
        }
        let target = directory.join(format!("{name}.results"));
        std::fs::write(&target, output)
            .map_err(|error| format!("{}: {error}", target.display()))?;
    }
    if evaluated == 0 {
        return Err("No argument files found".to_owned());
    }
    Ok(evaluated)
}

pub fn evaluate_line(name: &str, line: &str) -> Result<String, String> {
    let arguments = line
        .split_whitespace()
        .map(|word| {
            u64::from_str_radix(word, 16)
                .map(f64::from_bits)
                .map_err(|_| format!("invalid argument {word}"))
        })
        .collect::<Result<Vec<_>, _>>()?;
    let result = match (name, arguments.as_slice()) {
        ("atan2", [vertical, horizontal]) => arc_tangent2(*vertical, *horizontal),
        ("pow", [base, exponent]) => real_power(*base, *exponent),
        (_, [argument]) => unary(name)?(*argument),
        _ => return Err(format!("{name}: wrong argument count")),
    };
    match result {
        Ok(value) => Ok(format!("{:016x}", value.to_bits())),
        Err(
            LibraryError::NonFiniteResult
            | LibraryError::NonFiniteInput
            | LibraryError::NegativeSquareRoot,
        ) => Ok("nonFiniteRealResult".to_owned()),
        Err(error) => Err(format!("{name}({line}) failed: {error:?}")),
    }
}

fn unary(name: &str) -> Result<Unary, String> {
    UNARY
        .iter()
        .find(|(candidate, _)| *candidate == name)
        .map(|(_, function)| *function)
        .ok_or(format!("unknown function {name}"))
}
