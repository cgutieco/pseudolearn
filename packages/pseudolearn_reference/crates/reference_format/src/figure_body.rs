use crate::inline_parser::parse_inline;
use reference_model::{FigurePanelSource, FigureSource, FigureStepSource};

pub fn parse(identity: &str, body: &str) -> Result<FigureSource, String> {
    let mut figure = FigureSource {
        id: identity.to_owned(),
        ..FigureSource::default()
    };
    for line in body.lines().map(str::trim).filter(|line| !line.is_empty()) {
        read_line(&mut figure, line)?;
    }
    if figure.caption.is_empty() {
        return Err(format!("the figure `{identity}` needs a `pie:` caption"));
    }
    Ok(figure)
}

fn read_line(figure: &mut FigureSource, line: &str) -> Result<(), String> {
    if let Some(caption) = line.strip_prefix("pie:") {
        figure.caption = parse_inline(caption.trim())?;
        return Ok(());
    }
    if let Some(step) = line.strip_prefix("paso:") {
        figure.steps.push(FigureStepSource {
            text: parse_inline(step.trim())?,
        });
        return Ok(());
    }
    if let Some(panel) = line.strip_prefix("panel ") {
        figure.panels.push(parse_panel(panel)?);
        return Ok(());
    }
    Err(format!("unknown figure line `{line}`"))
}

fn parse_panel(panel: &str) -> Result<FigurePanelSource, String> {
    let (heading, text) = panel
        .split_once(':')
        .ok_or_else(|| "a panel line needs `panel <zone> <step>: text`".to_owned())?;
    let (zone, step) = heading
        .trim()
        .rsplit_once(' ')
        .ok_or_else(|| "a panel line needs a zone and a step".to_owned())?;
    let from_step = step
        .parse::<usize>()
        .map_err(|_| format!("invalid panel step `{step}`"))?;
    Ok(FigurePanelSource {
        zone: zone.trim().to_owned(),
        from_step,
        text: parse_inline(text.trim())?,
    })
}
