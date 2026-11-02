use crate::program_view::{SpanKey, ViewNode};
use crate::{AnalyzeRequest, ApiError};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_syntax::parse_source_with_terminator;
use std::collections::BTreeMap;

#[derive(Clone, Copy, Eq, PartialEq)]
pub(crate) enum ParseMode {
    Standalone,
    Project,
    PendingLinks,
}

type ParsedSource = (
    pseudolearn_source::SourceText,
    pseudolearn_syntax::SyntaxTree,
);

pub(crate) fn parse_view_source(
    request: &AnalyzeRequest,
    strict: bool,
    profile: Profile,
    mode: ParseMode,
) -> Result<ParsedSource, ApiError> {
    let source = crate::source_identity::source_text(request.program.clone(), request.source);
    let terminator = strict.then_some(DiagnosticCode::MissingStatementTerminator);
    let tree = match mode {
        ParseMode::Standalone => parse_source_with_terminator(&source, profile, terminator).0,
        ParseMode::Project => {
            pseudolearn_syntax::parse_module_source(&source, profile, terminator).0
        }
        ParseMode::PendingLinks => pending_links_tree(&source, profile, terminator),
    };
    if tree.has_errors {
        return Err(crate::execution_resource::usage("analysis has errors"));
    }
    Ok((source, tree))
}

fn pending_links_tree(
    source: &pseudolearn_source::SourceText,
    profile: Profile,
    terminator: Option<DiagnosticCode>,
) -> pseudolearn_syntax::SyntaxTree {
    let (tree, diagnostics) = parse_source_with_terminator(source, profile, terminator);
    let only_pending = diagnostics
        .iter()
        .all(|diagnostic| diagnostic.code == DiagnosticCode::ModuleSyntaxOutsideProject);
    if !tree.has_errors || !only_pending {
        return tree;
    }
    pseudolearn_syntax::parse_module_source(source, profile, terminator).0
}

pub(crate) fn index_by_span(nodes: &[ViewNode]) -> BTreeMap<SpanKey, Vec<usize>> {
    let mut by_span: BTreeMap<SpanKey, Vec<usize>> = BTreeMap::new();
    for (ordinal, node) in nodes.iter().enumerate() {
        by_span
            .entry((
                node.source
                    .map_or(pseudolearn_source::SourceId::STANDALONE, |source| {
                        pseudolearn_source::SourceId::new(source.source_id)
                    }),
                node.start,
                node.end,
            ))
            .or_default()
            .push(ordinal);
    }
    by_span
}
