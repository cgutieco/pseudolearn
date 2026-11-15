use serde_json::Value;

pub struct Workload {
    pub name: String,
    pub family: String,
    pub size: i64,
    pub expected: String,
}

pub fn load(purpose: &str) -> Result<Vec<Workload>, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../../pseudolearn_spec/specifications/export.json");
    let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    parse(&text, purpose)
}

pub fn parse(text: &str, purpose: &str) -> Result<Vec<Workload>, String> {
    let corpus: Value = serde_json::from_str(text).map_err(|error| error.to_string())?;
    let specifications = corpus
        .get("specifications")
        .unwrap_or(&Value::Null)
        .as_array()
        .ok_or("Missing specifications")?;
    let suite = specifications
        .iter()
        .find(|specification| {
            specification
                .pointer("/metadata/id")
                .unwrap_or(&Value::Null)
                == "PERF.SUITE.CORE"
        })
        .ok_or("Missing AWFY suite")?;
    let blocks = suite
        .get("blocks")
        .unwrap_or(&Value::Null)
        .as_array()
        .ok_or("Missing blocks")?;
    let mut workloads = Vec::new();
    for block in blocks {
        let fields = &block.get("fields").unwrap_or(&Value::Null);
        if block.get("kind").unwrap_or(&Value::Null) == "caso"
            && fields
                .get("etiquetas")
                .unwrap_or(&Value::Null)
                .as_array()
                .is_some_and(|tags| tags.iter().any(|tag| tag == purpose))
        {
            workloads.push(workload(fields)?);
        }
    }
    if workloads.len() != 10 {
        return Err("Expected exactly ten AWFY workloads".to_owned());
    }
    Ok(workloads)
}

fn workload(fields: &Value) -> Result<Workload, String> {
    let tags = fields
        .get("etiquetas")
        .unwrap_or(&Value::Null)
        .as_array()
        .ok_or("Missing tags")?;
    let name = tags
        .last()
        .and_then(Value::as_str)
        .ok_or("Missing kernel name")?;
    let family = match name {
        "sieve" | "queens" => "arrays",
        "permute" => "recursive",
        "mandelbrot" | "nbody" => "numeric",
        _ => "objects",
    };
    let size = fields
        .pointer("/entradas/0")
        .unwrap_or(&Value::Null)
        .as_str()
        .ok_or("Missing size")?
        .parse::<i64>()
        .map_err(|error| error.to_string())?;
    let expected = fields
        .pointer("/espera/salida")
        .unwrap_or(&Value::Null)
        .as_str()
        .ok_or("Missing expected output")?;
    Ok(Workload {
        name: name.to_owned(),
        family: family.to_owned(),
        size,
        expected: expected.trim().to_owned(),
    })
}
