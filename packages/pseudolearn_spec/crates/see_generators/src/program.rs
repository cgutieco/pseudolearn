use crate::random::Random;
use see_model::contract::Vocabulary;

#[derive(Clone, Copy, Debug)]
pub struct GenerationSeed {
    pub seed: u64,
    pub sample: u32,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct GeneratedProgram {
    pub source: String,
    pub initial: i64,
    pub elements: u32,
    pub input: String,
}

pub fn generate(
    configuration: GenerationSeed,
    profile: &str,
    vocabulary: &Vocabulary,
) -> Result<GeneratedProgram, String> {
    if !matches!(profile, "es" | "en") {
        return Err("Unknown generation profile".to_owned());
    }
    let mut random = Random::new(configuration.seed, configuration.sample);
    let elements = u32::try_from(random.next(17)).map_err(|error| error.to_string())?;
    let initial = i64::try_from(random.next(21))
        .map_err(|error| error.to_string())?
        .checked_sub(10)
        .ok_or("Generation range failure")?;
    let input = random.next(101).to_string();
    let dimension = elements.max(1);
    let upper = i64::from(elements)
        .checked_sub(1)
        .ok_or("Generation range failure")?;
    let template = format!("{}{}", declarations(), body(initial, dimension, upper));
    let source = see_translation::lexemes::resolve(&template, profile, vocabulary)?;
    Ok(GeneratedProgram {
        source,
        initial,
        elements,
        input,
    })
}

fn declarations() -> &'static str {
    "{{lexema:classKeyword}} SampleCell\n{{lexema:publicVisibility}} {{lexema:declare}} link {{lexema:typeConnector}} SampleCell;\n{{lexema:publicVisibility}} {{lexema:declare}} number {{lexema:typeConnector}} {{lexema:integerType}};\n{{lexema:endClass}}\n{{lexema:subroutine}} Increment(counter {{lexema:typeConnector}} {{lexema:integerType}} {{lexema:byReference}})\ncounter {{lexema:assignment}} counter {{lexema:plus}} 1;\n{{lexema:endSubroutine}}\n"
}

fn body(initial: i64, dimension: u32, upper: i64) -> String {
    format!(
        "{{{{lexema:algorithm}}}} Generated\n{{{{lexema:declare}}}} {{{{lexema:mutableKeyword}}}} index {{{{lexema:typeConnector}}}} {{{{lexema:integerType}}}} {{{{lexema:assignment}}}} 0;\n{{{{lexema:declare}}}} {{{{lexema:mutableKeyword}}}} total {{{{lexema:typeConnector}}}} {{{{lexema:integerType}}}} {{{{lexema:assignment}}}} 0;\n{{{{lexema:declare}}}} {{{{lexema:mutableKeyword}}}} label {{{{lexema:typeConnector}}}} {{{{lexema:stringType}}}} {{{{lexema:assignment}}}} \"\";\n{{{{lexema:declare}}}} {{{{lexema:mutableKeyword}}}} left {{{{lexema:typeConnector}}}} SampleCell {{{{lexema:assignment}}}} {{{{lexema:newInstance}}}} SampleCell();\n{{{{lexema:declare}}}} {{{{lexema:mutableKeyword}}}} right {{{{lexema:typeConnector}}}} SampleCell {{{{lexema:assignment}}}} {{{{lexema:newInstance}}}} SampleCell();\n{{{{lexema:declare}}}} {{{{lexema:mutableKeyword}}}} replica {{{{lexema:typeConnector}}}} SampleCell {{{{lexema:assignment}}}} {{{{lexema:newInstance}}}} SampleCell();\n{{{{lexema:dimension}}}} values[{dimension}] {{{{lexema:typeConnector}}}} {{{{lexema:integerType}}}};\ntotal {{{{lexema:assignment}}}} 0;\n{{{{lexema:forKeyword}}}} index {{{{lexema:assignment}}}} 0 {{{{lexema:to}}}} {upper} {{{{lexema:step}}}} 1 {{{{lexema:doKeyword}}}}\nvalues[index] {{{{lexema:assignment}}}} {initial} {{{{lexema:plus}}}} index;\ntotal {{{{lexema:assignment}}}} total {{{{lexema:plus}}}} values[index];\n{{{{lexema:endFor}}}}\nIncrement(total);\nleft {{{{lexema:assignment}}}} {{{{lexema:newInstance}}}} SampleCell();\nright {{{{lexema:assignment}}}} {{{{lexema:newInstance}}}} SampleCell();\nleft.link {{{{lexema:assignment}}}} right;\nright.link {{{{lexema:assignment}}}} left;\nleft.number {{{{lexema:assignment}}}} total;\nright.number {{{{lexema:assignment}}}} {initial};\nreplica {{{{lexema:assignment}}}} {{{{lexema:function:shallowCopy}}}}(left);\nlabel {{{{lexema:assignment}}}} \"sample\";\nlabel {{{{lexema:assignment}}}} label {{{{lexema:plus}}}} \"!\";\n{{{{lexema:read}}}} total;\n{{{{lexema:write}}}} label, \":\", replica.number, \":\", total;\n{{{{lexema:endAlgorithm}}}}\n"
    )
}
