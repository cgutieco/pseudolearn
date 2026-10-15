#![forbid(unsafe_code)]

use std::path::Path;

use pseudolearn_library::{
    LibraryError, arctangent, cosine, exponential, natural_logarithm, real_power, sine,
};

type Unary = fn(f64) -> Result<f64, LibraryError>;

const UNARY: [(&str, Unary); 5] = [
    ("exp", exponential),
    ("ln", natural_logarithm),
    ("sin", sine),
    ("cos", cosine),
    ("atan", arctangent),
];

pub fn probe_directory(directory: &Path) -> Result<usize, String> {
    let mut evaluated = 0_usize;
    for name in ["exp", "ln", "sin", "cos", "atan", "pow"] {
        let source = directory.join(format!("{name}.arguments"));
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
