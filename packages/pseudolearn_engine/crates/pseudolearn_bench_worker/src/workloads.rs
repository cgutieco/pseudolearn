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
    let mut program = format!(
        "{} Benchmark\n{} accumulator {} {};\naccumulator <- 0;\n",
        word("algorithm")?,
        word("declare")?,
        word("typeConnector")?,
        word("integerType")?
    );
    for _ in 0..lines.saturating_sub(5) {
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
