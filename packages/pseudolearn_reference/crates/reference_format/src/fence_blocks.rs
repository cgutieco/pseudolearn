use crate::fence::FenceOpening;
use reference_model::{ProgramSource, RailRequest, SourceBlock};

pub enum FenceOutcome {
    Block(SourceBlock),
    Output(String),
    Diagnostics(Vec<String>),
    Inputs(Vec<String>),
    Host(String),
}

pub fn interpret(opening: &FenceOpening, body: String) -> Result<FenceOutcome, String> {
    let outcome = match opening.name.as_str() {
        "forma" => FenceOutcome::Block(SourceBlock::Form(body)),
        "programa" => FenceOutcome::Block(SourceBlock::Program(program(opening, body)?)),
        "salida" => FenceOutcome::Output(body),
        "diagnosticos" => FenceOutcome::Diagnostics(non_empty_lines(&body)),
        "entrada" => FenceOutcome::Inputs(body.lines().map(str::to_owned).collect()),
        "anfitrion" => FenceOutcome::Host(body),
        "figura" => FenceOutcome::Block(SourceBlock::Figure(crate::figure_body::parse(
            required(opening, "id")?,
            &body,
        )?)),
        _ => FenceOutcome::Block(reference_block(opening)?),
    };
    Ok(outcome)
}

fn reference_block(opening: &FenceOpening) -> Result<SourceBlock, String> {
    let block = match opening.name.as_str() {
        "ri" => SourceBlock::Intermediate {
            program: required(opening, "programa")?.to_owned(),
        },
        "traza" => SourceBlock::Trace {
            program: required(opening, "programa")?.to_owned(),
        },
        "railes" => SourceBlock::Rails(rails(opening)?),
        "generado" => SourceBlock::Generated {
            catalog: required(opening, "catalogo")?.to_owned(),
        },
        other => return Err(format!("unknown fenced block `{other}`")),
    };
    Ok(block)
}

fn program(opening: &FenceOpening, code: String) -> Result<ProgramSource, String> {
    let mut source = ProgramSource {
        id: required(opening, "id")?.to_owned(),
        title: opening.attribute("titulo").unwrap_or_default().to_owned(),
        execute: opening.flag("ejecutar"),
        code,
        ..ProgramSource::default()
    };
    source.promise.termination = opening.attribute("termina").map(str::to_owned);
    Ok(source)
}

fn rails(opening: &FenceOpening) -> Result<RailRequest, String> {
    let contextual = opening
        .attribute("contextuales")
        .map(|list| {
            list.split(',')
                .map(|entry| (entry != "-").then(|| entry.to_owned()))
                .collect()
        })
        .unwrap_or_default();
    Ok(RailRequest {
        production: required(opening, "produccion")?.to_owned(),
        contextual,
    })
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
