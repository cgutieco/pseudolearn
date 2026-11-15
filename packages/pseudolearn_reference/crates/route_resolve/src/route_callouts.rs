use crate::RouteContext;
use crate::lesson_blocks::lesson_blocks;
use crate::zones::{list_entries, plain, zone};
use reference_model::{
    Block, BriefZones, CalloutKind, FigureSource, Inline, LessonBlock, ParadigmZones,
    PracticeEntry, RoleEntry, RouteBlock, RuleId, SectionLink, SourceBlock,
};
use reference_resolve::{Collector, figure_block, resolve_runs};
use std::collections::BTreeMap;

pub fn callout(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    (kind, attributes): (CalloutKind, &BTreeMap<String, String>),
    blocks: &[SourceBlock],
) -> Vec<LessonBlock> {
    let route = match kind {
        CalloutKind::Phrase => RouteBlock::Phrase {
            runs: first_runs(context, blocks),
        },
        CalloutKind::Summary => return vec![summary(context, blocks)],
        CalloutKind::Problem => RouteBlock::Problem {
            blocks: lesson_blocks(context, collector, blocks),
        },
        CalloutKind::Brief => RouteBlock::Brief(brief(context, collector, blocks)),
        CalloutKind::Paradigm => RouteBlock::Paradigm(paradigm(context, collector, blocks)),
        CalloutKind::Roles => RouteBlock::Roles {
            roles: roles(context, collector, blocks),
        },
        CalloutKind::Recall => return recall(context, collector, attributes),
        CalloutKind::SpecLinks => RouteBlock::SpecLinks {
            links: spec_links(context, collector, blocks),
        },
        CalloutKind::Deepen => RouteBlock::Deepen {
            title: attributes.get("titulo").cloned().unwrap_or_default(),
            blocks: lesson_blocks(context, collector, blocks),
        },
        CalloutKind::Practice => RouteBlock::Practice {
            exercises: practice(context, collector, blocks),
        },
        CalloutKind::Next => next(context, blocks),
        other => generic(context, collector, other, blocks),
    };
    vec![LessonBlock::Route(route)]
}

fn generic(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    kind: CalloutKind,
    blocks: &[SourceBlock],
) -> RouteBlock {
    if matches!(kind, CalloutKind::Answer) || kind.route_only() {
        collector.report(
            RuleId::RouteFormat,
            format!("`{}` is not allowed here", kind.directive()),
        );
    }
    RouteBlock::Callout {
        kind,
        collapsible: kind.collapsible(),
        blocks: lesson_blocks(context, collector, blocks),
    }
}

fn first_runs(context: &RouteContext<'_>, blocks: &[SourceBlock]) -> Vec<reference_model::Run> {
    list_entries(blocks)
        .first()
        .map(|entry| resolve_runs(context.resolution, entry))
        .unwrap_or_default()
}

fn summary(context: &RouteContext<'_>, blocks: &[SourceBlock]) -> LessonBlock {
    LessonBlock::Shared(Block::Summary {
        points: list_entries(blocks)
            .into_iter()
            .map(|entry| resolve_runs(context.resolution, &reference_format::summary_tags(entry).1))
            .collect(),
    })
}

fn zones(
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
    known: &[&str],
) -> Vec<(String, Vec<Inline>)> {
    let mut found = Vec::new();
    for entry in list_entries(blocks) {
        match zone(entry).filter(|(label, _)| known.contains(&label.as_str())) {
            Some(zone) => found.push(zone),
            None => collector.report(
                RuleId::RouteFormat,
                format!("unknown zone in `{}`", plain(entry)),
            ),
        }
    }
    found
}

fn brief(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> BriefZones {
    let mut brief = BriefZones::default();
    let known = ["entra", "sale", "relacion", "ejemplo"];
    for (label, text) in zones(collector, blocks, &known) {
        let runs = resolve_runs(context.resolution, &text);
        match label.as_str() {
            "entra" => brief.inputs = runs,
            "sale" => brief.outputs = runs,
            "relacion" => brief.relation = runs,
            _ => brief.examples.push(runs),
        }
    }
    brief
}

fn paradigm(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> ParadigmZones {
    let mut paradigm = ParadigmZones::default();
    let known = ["pregunta", "metafora", "historia", "costo"];
    for (label, text) in zones(collector, blocks, &known) {
        let runs = resolve_runs(context.resolution, &text);
        match label.as_str() {
            "pregunta" => paradigm.question = runs,
            "metafora" => paradigm.metaphor = runs,
            "historia" => paradigm.history = runs,
            _ => paradigm.cost = runs,
        }
    }
    paradigm
}

fn roles(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> Vec<RoleEntry> {
    let mut roles = Vec::new();
    for entry in list_entries(blocks) {
        let text = plain(entry);
        let mut parts = text.splitn(3, " | ").map(str::trim);
        let (Some(name), Some(figure), Some(description)) =
            (parts.next(), parts.next(), parts.next())
        else {
            collector.report(RuleId::RouteFormat, "a role needs `name | figure | text`");
            continue;
        };
        let description = vec![Inline::Text(description.to_owned())];
        let source = FigureSource {
            id: figure.to_owned(),
            caption: description.clone(),
            ..FigureSource::default()
        };
        if let Some(figure) = figure_block(context.resolution, collector, &source) {
            roles.push(RoleEntry {
                name: name.to_owned(),
                description: resolve_runs(context.resolution, &description),
                figure,
            });
        }
    }
    roles
}

fn recall(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    attributes: &BTreeMap<String, String>,
) -> Vec<LessonBlock> {
    let term = attributes.get("termino").cloned().unwrap_or_default();
    let Some(card) = context.catalog.terms.get(&term) else {
        collector.report(
            RuleId::RouteRecallSource,
            format!("no owner summary for the recalled term `{term}`"),
        );
        return Vec::new();
    };
    vec![LessonBlock::Route(RouteBlock::Recall {
        term,
        label: card.label.clone(),
        runs: resolve_runs(context.resolution, &card.summary),
        lesson: card.owner.clone(),
    })]
}

fn spec_links(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> Vec<SectionLink> {
    let mut links = Vec::new();
    for entry in list_entries(blocks) {
        let section = plain(entry).trim().to_owned();
        match context.resolution.index.get(&section) {
            Some(target) => links.push(SectionLink {
                section,
                number: target.number.clone(),
                title: target.title.clone(),
            }),
            None => collector.report(
                RuleId::RouteSpecLink,
                format!("link to unknown section `{section}`"),
            ),
        }
    }
    links
}

fn practice(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> Vec<PracticeEntry> {
    let mut exercises = Vec::new();
    for entry in list_entries(blocks) {
        let identity = plain(entry).trim().to_owned();
        match context.catalog.exercises.get(&identity) {
            Some(exercise) => exercises.push(PracticeEntry {
                id: identity,
                title: resolve_runs(context.resolution, &exercise.title),
                kind: exercise.kind,
                level: exercise.level,
                required: exercise.required,
            }),
            None => collector.report(
                RuleId::RouteExerciseMix,
                format!("practice lists the unknown exercise `{identity}`"),
            ),
        }
    }
    exercises
}

fn next(context: &RouteContext<'_>, blocks: &[SourceBlock]) -> RouteBlock {
    let lesson = context.catalog.neighbours(context.current).1.cloned();
    RouteBlock::Next {
        lesson,
        runs: first_runs(context, blocks),
    }
}
