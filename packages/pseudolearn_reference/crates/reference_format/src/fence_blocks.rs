use crate::fence::FenceOpening;
use reference_model::{ProgramSource, SourceBlock};

pub enum FenceOutcome {
    Block(Box<SourceBlock>),
    Output(String),
    Diagnostics(Vec<String>),
    Inputs(Vec<String>),
    Host(String),
}

pub fn interpret(opening: &FenceOpening, body: String) -> Result<FenceOutcome, String> {
    let outcome = match opening.name.as_str() {
        "forma" => FenceOutcome::Block(Box::new(SourceBlock::Form(body))),
        "anatomia" => FenceOutcome::Block(Box::new(SourceBlock::Anatomy(
            crate::anatomy_body::parse(&body)?,
        ))),
        "programa" => FenceOutcome::Block(Box::new(SourceBlock::Program(program(opening, body)?))),
        "salida" => FenceOutcome::Output(body),
        "diagnosticos" => FenceOutcome::Diagnostics(non_empty_lines(&body)),
        "entrada" => FenceOutcome::Inputs(body.lines().map(str::to_owned).collect()),
        "anfitrion" => FenceOutcome::Host(body),
        "figura" => FenceOutcome::Block(Box::new(SourceBlock::Figure(crate::figure_body::parse(
            required(opening, "id")?,
            &body,
        )?))),
        _ => FenceOutcome::Block(Box::new(reference_block(opening, body)?)),
    };
    Ok(outcome)
}

fn reference_block(opening: &FenceOpening, body: String) -> Result<SourceBlock, String> {
    if let Some(fence) = crate::route_fences::route_body(opening, &body)? {
        return Ok(SourceBlock::Route(fence));
    }
    let block = match opening.name.as_str() {
        "ri" => SourceBlock::Intermediate {
            program: required(opening, "programa")?.to_owned(),
        },
        "traza" => SourceBlock::Trace {
            program: required(opening, "programa")?.to_owned(),
        },
        "generado" => SourceBlock::Generated {
            catalog: required(opening, "catalogo")?.to_owned(),
        },
        other => {
            return crate::route_fences::route_fence(opening, other)
                .map(SourceBlock::Route)
                .ok_or_else(|| format!("unknown fenced block `{other}`"));
        }
    };
    Ok(block)
}

fn program(opening: &FenceOpening, code: String) -> Result<ProgramSource, String> {
    let role = opening.attribute("rol").map(str::to_owned);
    let identity = match (opening.attribute("id"), role.as_deref()) {
        (Some(identity), _) if !identity.is_empty() => identity.to_owned(),
        (_, Some(role)) => role.to_owned(),
        _ => required(opening, "id")?.to_owned(),
    };
    let statement_limit = match opening.attribute("sentencias") {
        Some(limit) => Some(
            limit
                .parse::<u64>()
                .map_err(|_| format!("invalid statement limit `{limit}`"))?,
        ),
        None => None,
    };
    let mut source = ProgramSource {
        id: identity,
        title: opening.attribute("titulo").unwrap_or_default().to_owned(),
        execute: opening.flag("ejecutar") || role.is_some(),
        code,
        role,
        statement_limit,
        ..ProgramSource::default()
    };
    source.promise.termination = opening.attribute("termina").map(str::to_owned);
    Ok(source)
}

fn required<'opening>(opening: &'opening FenceOpening, key: &str) -> Result<&'opening str, String> {
    opening
        .attribute(key)
        .filter(|value| !value.is_empty())
        .ok_or_else(|| format!("the `{}` block needs `{key}`", opening.name))
}

fn non_empty_lines(body: &str) -> Vec<String> {
    body.lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(str::to_owned)
        .collect()
}
