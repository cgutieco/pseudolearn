use serde_json::Value;
use std::collections::BTreeMap;

pub type Failure = Box<dyn std::error::Error>;

pub struct Lexemes {
    pub spanish: String,
    pub english: String,
}

pub struct CaseProgram {
    pub spanish: String,
    pub english: String,
    pub output: Option<String>,
}

pub struct Sources {
    lexemes: BTreeMap<String, Lexemes>,
    cases: BTreeMap<String, CaseProgram>,
}

impl Sources {
    pub fn from_export(export: &Value) -> Result<Self, Failure> {
        let resources = export.get("resources").ok_or("Missing export resources")?;
        Ok(Self {
            lexemes: lexemes(resources)?,
            cases: cases(export)?,
        })
    }

    pub fn lexemes(&self, identity: &str) -> Result<&Lexemes, Failure> {
        self.lexemes
            .get(identity)
            .ok_or_else(|| format!("Help form token {identity} has no lexeme").into())
    }

    pub fn program(&self, reference: &Value) -> Result<&CaseProgram, Failure> {
        let key = case_key(reference)?;
        self.cases
            .get(&key)
            .ok_or_else(|| format!("Help example {key} has no program for every profile").into())
    }
}

fn lexemes(resources: &Value) -> Result<BTreeMap<String, Lexemes>, Failure> {
    let mut table = BTreeMap::new();
    for key in ["vocabulary", "contextualVocabulary", "functions"] {
        let entries = resources
            .get(key)
            .and_then(Value::as_object)
            .ok_or_else(|| format!("Missing resource {key}"))?;
        for (identity, entry) in entries {
            let forms = entry.get("lexemas").ok_or("Missing lexemes")?;
            table
                .entry(identity.clone())
                .or_insert(pair(forms.get("es"), forms.get("en"))?);
        }
    }
    let operations = resources
        .pointer("/capabilityLibrary/operations")
        .and_then(Value::as_array)
        .ok_or("Missing capability operations")?;
    for operation in operations {
        let identity = operation
            .get("identity")
            .and_then(Value::as_str)
            .ok_or("Missing operation identity")?;
        table
            .entry(identity.to_owned())
            .or_insert(pair(operation.get("es"), operation.get("en"))?);
    }
    Ok(table)
}

fn pair(spanish: Option<&Value>, english: Option<&Value>) -> Result<Lexemes, Failure> {
    Ok(Lexemes {
        spanish: spanish
            .and_then(Value::as_str)
            .ok_or("Missing es lexeme")?
            .to_owned(),
        english: english
            .and_then(Value::as_str)
            .ok_or("Missing en lexeme")?
            .to_owned(),
    })
}

fn cases(export: &Value) -> Result<BTreeMap<String, CaseProgram>, Failure> {
    let specifications = export
        .get("specifications")
        .and_then(Value::as_array)
        .ok_or("Missing exported specifications")?;
    let mut table = BTreeMap::new();
    for specification in specifications {
        let identity = specification
            .pointer("/metadata/id")
            .and_then(Value::as_str);
        let version = specification
            .pointer("/metadata/version")
            .and_then(Value::as_str);
        let (Some(identity), Some(version)) = (identity, version) else {
            continue;
        };
        for block in specification
            .get("blocks")
            .and_then(Value::as_array)
            .into_iter()
            .flatten()
            .filter(|block| block.get("kind").and_then(Value::as_str) == Some("caso"))
        {
            let Some(fields) = block.get("fields") else {
                continue;
            };
            if let (Some(case), Some(program)) = (
                fields.get("id").and_then(Value::as_str),
                case_program(fields),
            ) {
                table.insert(format!("{identity}@{version}#{case}"), program);
            }
        }
    }
    Ok(table)
}

fn case_program(fields: &Value) -> Option<CaseProgram> {
    let programs = fields.get("programas")?;
    let expected = fields.get("espera");
    let executes = fields.get("operacion").and_then(Value::as_str) == Some("execute");
    let failed = expected.is_some_and(|value| value.get("fallo").is_some());
    let output = expected
        .and_then(|value| value.get("salida"))
        .and_then(Value::as_str)
        .filter(|_| executes && !failed)
        .map(str::to_owned);
    Some(CaseProgram {
        spanish: programs.get("es")?.as_str()?.to_owned(),
        english: programs.get("en")?.as_str()?.to_owned(),
        output,
    })
}

fn case_key(reference: &Value) -> Result<String, Failure> {
    let text = |key: &str| {
        reference
            .get(key)
            .and_then(Value::as_str)
            .ok_or_else(|| format!("Missing example field {key}"))
    };
    Ok(format!(
        "{}@{}#{}",
        text("specification")?,
        text("version")?,
        text("case")?
    ))
}
