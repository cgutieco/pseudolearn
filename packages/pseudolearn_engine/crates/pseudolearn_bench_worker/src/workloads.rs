use pseudolearn_api::AnalyzeRequest;
use serde_json::Value;

pub struct Workload {
    pub requests: Vec<AnalyzeRequest>,
    pub name: String,
    pub lines: u32,
    pub bytes: usize,
    pub incomplete: bool,
    pub corpus: bool,
}

const SPANISH_UNICODE_IDENTIFIERS: [&str; 18] = [
    "ñ",
    "Ñ",
    "áx",
    "Áx",
    "éx",
    "Éx",
    "íx",
    "Íx",
    "óx",
    "Óx",
    "úx",
    "Úx",
    "üx",
    "Üx",
    "año",
    "pingüino",
    "ax",
    "Ax",
];

pub fn load() -> Result<Vec<Workload>, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    let mut workloads = Vec::new();
    for profile in ["es", "en"] {
        for strictness in ["strict", "flexible"] {
            for configuration in [
                (1000, false),
                (1000, true),
                (10000, false),
                (10000, true),
                (50000, false),
                (50000, true),
            ] {
                workloads.push(generated(&corpus, profile, strictness, configuration)?);
            }
            workloads.push(corpus_workload(&corpus, profile, strictness)?);
            workloads.push(unicode_identifier_workload(&corpus, profile, strictness)?);
        }
    }
    Ok(workloads)
}

pub fn generated(
    corpus: &Value,
    profile: &str,
    strictness: &str,
    configuration: (u32, bool),
) -> Result<Workload, String> {
    let (lines, incomplete) = configuration;
    let word = |identity| keyword(corpus, profile, identity);
    let mut program = benchmark_program_header(corpus, profile)?;
    for _ in 0..lines.saturating_sub(4) {
        program.push_str("accumulator <- accumulator + 1;\n");
    }
    if incomplete {
        program.push_str(&format!("{} \"unfinished\n", word("write")?));
    } else {
        program.push_str(&format!("{} accumulator;\n", word("write")?));
    }
    program.push_str(&format!("{}\n", word("endAlgorithm")?));
    let bytes = program.len();
    let request = AnalyzeRequest {
        program,
        profile: profile.to_owned(),
        strictness: strictness.to_owned(),
        source: None,
    };
    Ok(Workload {
        requests: vec![request],
        name: format!("generated-{profile}-{strictness}-{lines}-{incomplete}"),
        lines,
        bytes,
        incomplete,
        corpus: false,
    })
}

fn benchmark_program_header(corpus: &Value, profile: &str) -> Result<String, String> {
    let word = |identity| keyword(corpus, profile, identity);
    Ok(format!(
        "{} Benchmark\n{} {} accumulator {} {} <- 0;\n",
        word("algorithm")?,
        word("declare")?,
        word("mutableKeyword")?,
        word("typeConnector")?,
        word("integerType")?
    ))
}

fn keyword<'corpus>(
    corpus: &'corpus Value,
    profile: &str,
    identity: &str,
) -> Result<&'corpus str, String> {
    corpus
        .pointer("/resources/vocabulary")
        .and_then(|vocabulary| vocabulary.get(identity))
        .and_then(|entry| entry.get("lexemas"))
        .and_then(|lexemes| lexemes.get(profile))
        .and_then(Value::as_str)
        .ok_or_else(|| format!("Missing vocabulary {identity}/{profile}"))
}

fn corpus_workload(corpus: &Value, profile: &str, strictness: &str) -> Result<Workload, String> {
    let specifications = corpus
        .get("specifications")
        .and_then(Value::as_array)
        .ok_or("Missing specifications")?;
    let mut requests = Vec::new();
    for specification in specifications {
        let blocks = specification
            .get("blocks")
            .and_then(Value::as_array)
            .ok_or("Missing blocks")?;
        for block in blocks {
            append_case(&mut requests, block, profile, strictness);
        }
    }
    if requests.is_empty() {
        return Err("Empty corpus workload".to_owned());
    }
    let lines = requests
        .iter()
        .map(|request| u32::try_from(request.program.lines().count()).unwrap_or(u32::MAX))
        .fold(0_u32, u32::saturating_add);
    let bytes = requests.iter().map(|request| request.program.len()).sum();
    Ok(Workload {
        requests,
        name: format!("corpus-{profile}-{strictness}"),
        lines,
        bytes,
        incomplete: false,
        corpus: true,
    })
}

fn unicode_identifier_workload(
    corpus: &Value,
    profile: &str,
    strictness: &str,
) -> Result<Workload, String> {
    let program = unicode_identifier_program(corpus, profile)?;
    let lines = u32::try_from(program.lines().count()).map_err(|error| error.to_string())?;
    let bytes = program.len();
    Ok(Workload {
        requests: vec![AnalyzeRequest {
            program,
            profile: profile.to_owned(),
            strictness: strictness.to_owned(),
            source: None,
        }],
        name: format!("unicode-identifiers-{profile}-{strictness}"),
        lines,
        bytes,
        incomplete: false,
        corpus: false,
    })
}

fn unicode_identifier_program(corpus: &Value, profile: &str) -> Result<String, String> {
    let names = SPANISH_UNICODE_IDENTIFIERS;
    let mut program = format!("{} Unicode\n", keyword(corpus, profile, "algorithm")?);
    let declaration = keyword(corpus, profile, "declare")?;
    let mutable = keyword(corpus, profile, "mutableKeyword")?;
    let type_connector = keyword(corpus, profile, "typeConnector")?;
    let integer_type = keyword(corpus, profile, "integerType")?;
    for name in names {
        program.push_str(&format!(
            "{declaration} {mutable} {name} {type_connector} {integer_type} <- 0;\n"
        ));
    }
    for (index, name) in names.iter().enumerate() {
        let assignment_name = match *name {
            "año" => "an\u{0303}o",
            "pingüino" => "pingu\u{0308}ino",
            _ => *name,
        };
        program.push_str(&format!(
            "{assignment_name} <- {};\n",
            index.saturating_add(1)
        ));
    }
    program.push_str(&format!(
        "{} {};\n{}\n",
        keyword(corpus, profile, "write")?,
        names.join(", "),
        keyword(corpus, profile, "endAlgorithm")?
    ));
    Ok(program)
}

fn append_case(requests: &mut Vec<AnalyzeRequest>, block: &Value, profile: &str, strictness: &str) {
    if block.get("kind").and_then(Value::as_str) != Some("caso") {
        return;
    }
    let Some(fields) = block.get("fields") else {
        return;
    };
    if !matches!(
        fields.get("operacion").and_then(Value::as_str),
        Some("analyze" | "execute" | "trace")
    ) {
        return;
    }
    let program = fields
        .get("programas")
        .and_then(|programs| programs.get(profile))
        .and_then(Value::as_str)
        .or_else(|| {
            (fields
                .get("perfil_base")
                .and_then(Value::as_str)
                .unwrap_or("es")
                == profile)
                .then(|| fields.get("programa").and_then(Value::as_str))
                .flatten()
        });
    if let Some(program) = program {
        requests.push(AnalyzeRequest {
            program: program.to_owned(),
            profile: profile.to_owned(),
            strictness: strictness.to_owned(),
            source: None,
        });
    }
}
