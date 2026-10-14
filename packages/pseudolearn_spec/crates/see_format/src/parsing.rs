use see_model::{Block, Metadata, Specification};

const KINDS: [&str; 13] = [
    "regla",
    "caso",
    "definicion",
    "error",
    "propiedad",
    "invariante",
    "precondicion",
    "resultado",
    "lapida",
    "pregunta",
    "medicion",
    "instruccion",
    "cobertura",
];

pub fn parse(path: &str, text: &str) -> Result<Specification, String> {
    let normalized = text.replace("\r\n", "\n");
    let body = normalized
        .strip_prefix("---\n")
        .ok_or("SEE-FORMAT: missing YAML header")?;
    let (header, body) = body
        .split_once("\n---\n")
        .ok_or("SEE-FORMAT: unclosed YAML header")?;
    let metadata: Metadata =
        serde_saphyr::from_str(header).map_err(|error| format!("{path}: SEE-SCHEMA: {error}"))?;
    let blocks = parse_blocks(body)?;
    Ok(Specification {
        path: path.to_owned(),
        metadata,
        blocks,
    })
}

fn parse_blocks(body: &str) -> Result<Vec<Block>, String> {
    let mut lines = body.lines();
    let mut blocks = Vec::new();
    while let Some(line) = lines.next() {
        let Some(kind) = line.strip_prefix("```") else {
            continue;
        };
        if kind.is_empty() {
            return Err("SEE-FORMAT: unexpected closing fence".to_owned());
        }
        let contents = collect_fence(&mut lines)?;
        if KINDS.contains(&kind) {
            append_block(&mut blocks, kind, &contents)?;
        } else if !["yaml", "json", "text", "markdown"].contains(&kind) {
            return Err(format!("SEE-FORMAT: unknown block {kind}"));
        }
    }
    Ok(blocks)
}

fn collect_fence(lines: &mut std::str::Lines<'_>) -> Result<String, String> {
    let mut contents = String::new();
    for line in lines.by_ref() {
        if line == "```" {
            return Ok(contents);
        }
        contents.push_str(line);
        contents.push('\n');
    }
    Err("SEE-FORMAT: unclosed block".to_owned())
}

fn append_block(blocks: &mut Vec<Block>, kind: &str, contents: &str) -> Result<(), String> {
    let value: serde_json::Value =
        serde_saphyr::from_str(contents).map_err(|error| error.to_string())?;
    let entries = match value {
        serde_json::Value::Array(entries) => entries,
        value => vec![value],
    };
    for entry in entries {
        let fields = serde_json::from_value(entry).map_err(|error| error.to_string())?;
        blocks.push(Block {
            kind: kind.to_owned(),
            fields,
        });
    }
    Ok(())
}
