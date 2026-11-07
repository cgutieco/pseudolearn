use crate::RouteContext;
use reference_model::{
    Block, CalloutKind, LessonBlock, RouteBlock, RouteFence, RuleId, SourceBlock,
};
use reference_resolve::{Collector, resolve_blocks, resolve_runs};

pub fn lesson_blocks(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
) -> Vec<LessonBlock> {
    let mut published = Vec::new();
    let mut pending = blocks.iter().peekable();
    while let Some(block) = pending.next() {
        if is_callout(block, CalloutKind::Attempt) {
            let answer = pending.next_if(|next| is_callout(next, CalloutKind::Answer));
            published.push(attempt(context, collector, block, answer));
            continue;
        }
        published.extend(lesson_block(context, collector, block));
    }
    published
}

pub fn is_callout(block: &SourceBlock, wanted: CalloutKind) -> bool {
    matches!(block, SourceBlock::Callout { kind, .. } if *kind == wanted)
}

pub fn inner_blocks(block: &SourceBlock) -> &[SourceBlock] {
    match block {
        SourceBlock::Callout { blocks, .. } => blocks,
        _ => &[],
    }
}

fn attempt(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    prompt: &SourceBlock,
    answer: Option<&SourceBlock>,
) -> LessonBlock {
    if answer.is_none() {
        collector.report(
            RuleId::RouteFormat,
            "`intento` must be followed by `respuesta`",
        );
    }
    LessonBlock::Route(RouteBlock::Attempt {
        prompt: lesson_blocks(context, collector, inner_blocks(prompt)),
        answer: answer
            .map(|answer| lesson_blocks(context, collector, inner_blocks(answer)))
            .unwrap_or_default(),
    })
}

fn lesson_block(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    block: &SourceBlock,
) -> Vec<LessonBlock> {
    match block {
        SourceBlock::Heading {
            id,
            phase: Some(phase),
            text,
        } => {
            let phases = crate::zones::phases(phase);
            vec![
                LessonBlock::Route(RouteBlock::Cycle {
                    phases: phases.clone(),
                }),
                LessonBlock::Route(RouteBlock::PhaseHeading {
                    id: id.clone(),
                    phases,
                    runs: resolve_runs(context.resolution, text),
                }),
            ]
        }
        SourceBlock::Callout {
            kind,
            attributes,
            blocks,
        } => crate::route_callouts::callout(context, collector, (*kind, attributes), blocks),
        SourceBlock::Route(fence) => fence_block(context, collector, fence).into_iter().collect(),
        shared => resolve_blocks(
            context.resolution,
            collector,
            std::slice::from_ref(shared),
            false,
        )
        .into_iter()
        .map(LessonBlock::Shared)
        .collect(),
    }
}

fn fence_block(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    fence: &RouteFence,
) -> Option<LessonBlock> {
    let RouteFence::SpecFigure { section, figure } = fence else {
        collector.report(
            RuleId::RouteFormat,
            format!("`{}` only belongs in an exercise", fence.name()),
        );
        return None;
    };
    let Some(published) = context.specification.get(section) else {
        collector.report(
            RuleId::RouteSpecLink,
            format!("figure from unknown section `{section}`"),
        );
        return None;
    };
    let Some(found) = find_figure(&published.blocks, figure) else {
        collector.report(
            RuleId::RouteSpecLink,
            format!("section `{section}` has no figure `{figure}`"),
        );
        return None;
    };
    Some(LessonBlock::Route(RouteBlock::SpecFigure {
        section: section.clone(),
        number: published.number.clone(),
        figure: found,
    }))
}

pub fn find_figure(blocks: &[Block], wanted: &str) -> Option<Block> {
    blocks.iter().find_map(|block| match block {
        Block::Figure { id, .. } if id == wanted => Some(block.clone()),
        Block::Callout { blocks, .. } => find_figure(blocks, wanted),
        _ => None,
    })
}
