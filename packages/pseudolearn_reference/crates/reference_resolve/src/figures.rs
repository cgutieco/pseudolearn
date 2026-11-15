use crate::Resolution;
use crate::resolution::Collector;
use crate::runs::runs;
use crate::spelling::{canonical_spelling, fragment_tokens};
use reference_figures::{FigureContext, RenderedFigure, render_figure, step_count};
use reference_model::{
    Block, FigureLayer, FigureSource, FigureStep, PanelEntry, Profile, RuleId, Violation,
};
use std::collections::BTreeMap;

pub fn figure_block(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    source: &FigureSource,
) -> Option<Block> {
    let Some(svg) = resolution.figures.get(&source.id) else {
        collector.report(
            RuleId::FigureContract,
            format!("figure `{}` has no SVG file", source.id),
        );
        return None;
    };
    let empty = BTreeMap::new();
    let strings = resolution.pack.figures.get(&source.id).unwrap_or(&empty);
    let rendered = render(resolution, source, svg, strings)
        .map_err(|violations| collector.violations.extend(violations))
        .ok()?;
    let count = step_count(svg).max(source.steps.len());
    Some(Block::Figure {
        id: source.id.clone(),
        number: collector.next_figure(),
        alt: strings.get("titulo").cloned().unwrap_or_default(),
        description: strings.get("descripcion").cloned().unwrap_or_default(),
        caption: runs(resolution, &source.caption),
        svg: rendered.svg,
        layers: rendered.layers.into_iter().map(layer).collect(),
        steps: steps(resolution, source, count),
        panels: panels(resolution, source),
    })
}

fn render(
    resolution: &Resolution<'_>,
    source: &FigureSource,
    svg: &str,
    strings: &BTreeMap<String, String>,
) -> Result<RenderedFigure, Vec<Violation>> {
    let lexeme = |identity: &str| {
        let lexeme = resolution
            .corpus
            .lexicon
            .lexeme(identity, resolution.profile)?;
        Some(canonical_spelling(lexeme, resolution.profile))
    };
    let code = |fragment: &str| -> String {
        fragment_tokens(resolution, fragment, Profile::Spanish)
            .into_iter()
            .map(|token| token.text)
            .collect()
    };
    let context = FigureContext {
        id: &source.id,
        strings,
        lexeme: &lexeme,
        code: &code,
    };
    render_figure(svg, &context)
}

fn layer(rendered: reference_figures::RenderedLayer) -> FigureLayer {
    FigureLayer {
        from_step: rendered.from_step,
        until_step: rendered.until_step,
        svg: rendered.svg,
    }
}

fn steps(resolution: &Resolution<'_>, source: &FigureSource, count: usize) -> Vec<FigureStep> {
    (0..count)
        .map(|index| FigureStep {
            runs: source
                .steps
                .get(index)
                .map(|step| runs(resolution, &step.text))
                .unwrap_or_default(),
        })
        .collect()
}

fn panels(resolution: &Resolution<'_>, source: &FigureSource) -> Vec<PanelEntry> {
    source
        .panels
        .iter()
        .map(|panel| PanelEntry {
            zone: panel.zone.clone(),
            from_step: panel.from_step,
            runs: runs(resolution, &panel.text),
        })
        .collect()
}
