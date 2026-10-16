use see_generators::program::{GenerationSeed, generate};
use see_model::contract::Vocabulary;
use serde_json::{Value, json};

pub fn generated(
    vocabulary: &Vocabulary,
    seed: u64,
    sample: u32,
) -> Result<(Value, Value, String), String> {
    let profile = if sample & 1 == 0 { "es" } else { "en" };
    let program = generate(GenerationSeed { seed, sample }, profile, vocabulary)?;
    let expected = crate::property_scenarios::generated_expectation(&program)?
        .get("salida")
        .and_then(Value::as_str)
        .ok_or("Missing generated oracle")?
        .to_owned();
    let ending = see_translation::lexemes::resolve("{{lexema:endAlgorithm}}", profile, vocabulary)?;
    let position = program
        .source
        .rfind(&ending)
        .ok_or("Missing algorithm closing")?;
    let dead = see_translation::lexemes::resolve(
        "{{lexema:ifKeyword}} {{lexema:booleanFalse}} {{lexema:then}}\n{{lexema:write}} \"unreachable\";\n{{lexema:endIf}}\n",
        profile,
        vocabulary,
    )?;
    let mut full_source = program.source.clone();
    full_source.insert_str(position, &dead);
    let request = |source| {
        json!({"kind":"execute","program":source,"profile":profile,
        "strictness":if sample & 2 == 0 {"strict"} else {"flexible"},
        "inputs":[program.input],"seed":seed,"observe":"events"})
    };
    Ok((request(full_source), request(program.source), expected))
}

pub fn format_boundaries(vocabulary: &Vocabulary) -> Result<Vec<(Value, u64)>, String> {
    let words = [
        0_u64,
        1,
        2,
        0x000f_ffff_ffff_ffff,
        0x0010_0000_0000_0000,
        0x0010_0000_0000_0001,
        0x3fef_ffff_ffff_ffff,
        0x3ff0_0000_0000_0000,
        0x3ff0_0000_0000_0001,
        0x4340_0000_0000_0000,
        0x4340_0000_0000_0001,
        0x7fef_ffff_ffff_ffff,
    ];
    let mut requests = Vec::new();
    for profile in ["es", "en"] {
        for word in words {
            for bits in [word, word | (1_u64 << 63)] {
                requests.push((format_request(profile, bits, vocabulary)?, bits));
            }
        }
    }
    Ok(requests)
}

fn format_request(profile: &str, bits: u64, vocabulary: &Vocabulary) -> Result<Value, String> {
    let mut literal = f64::from_bits(bits).to_string();
    if !literal.contains(['.', 'e', 'E']) {
        literal.push_str(".0");
    }
    let template = format!(
        "{{{{lexema:algorithm}}}} FormatBoundary\n{{{{lexema:write}}}} {literal};\n{{{{lexema:endAlgorithm}}}}\n"
    );
    let source = see_translation::lexemes::resolve(&template, profile, vocabulary)?;
    Ok(json!({"kind":"execute","program":source,"profile":profile,
        "strictness":"strict","inputs":[],"seed":42,"observe":"none"}))
}
