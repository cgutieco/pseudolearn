use crate::Resolution;
use crate::resolution::Collector;
use crate::spelling::canonical_spelling;
use reference_figures::{ColorRole, RailLabels, render_rails};
use reference_model::{Block, RailRequest, RuleId, TokenCategory};

pub fn rails_block(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    request: &RailRequest,
) -> Option<Block> {
    let Some(rule) = resolution.corpus.productions.get(&request.production) else {
        collector.report(
            RuleId::Format,
            format!("unknown production `{}`", request.production),
        );
        return None;
    };
    report_missing_labels(resolution, collector, rule);
    let terminal = |identity: &str| terminal_label(resolution, identity);
    let nonterminal = |name: &str| label(resolution, name);
    let title = format!(
        "{} {}",
        resolution.pack.phrase("rails.title"),
        label(resolution, &request.production)
    );
    let labels = RailLabels {
        terminal: &terminal,
        nonterminal: &nonterminal,
        description: resolution.pack.phrase("rails.description"),
        title: title.clone(),
    };
    render_rails(request, rule, &labels)
        .map(|svg| Block::Rails { svg, alt: title })
        .map_err(|detail| collector.report(RuleId::FigureNarrow, detail))
        .ok()
}

fn terminal_label(resolution: &Resolution<'_>, identity: &str) -> (String, ColorRole) {
    let lexeme = resolution
        .corpus
        .lexicon
        .lexeme(identity, resolution.profile)
        .map_or_else(
            || identity.to_owned(),
            |lexeme| canonical_spelling(lexeme, resolution.profile),
        );
    (lexeme, role(resolution.categories.category(identity)))
}

fn label(resolution: &Resolution<'_>, name: &str) -> String {
    resolution
        .pack
        .productions
        .get(name)
        .cloned()
        .unwrap_or_else(|| name.to_owned())
}

fn report_missing_labels(resolution: &Resolution<'_>, collector: &mut Collector<'_>, rule: &str) {
    let names = rule
        .split(|character: char| !character.is_alphanumeric() && character != '@')
        .filter(|word| !word.is_empty() && !word.starts_with('@'));
    for name in names {
        if !resolution.pack.productions.contains_key(name) {
            collector.report(RuleId::Format, format!("production `{name}` has no label"));
        }
    }
}

fn role(category: Option<TokenCategory>) -> ColorRole {
    match category {
        Some(TokenCategory::KeywordStructured) => ColorRole::StructuredAccent,
        Some(TokenCategory::KeywordProcedural) => ColorRole::ProceduralAccent,
        Some(TokenCategory::KeywordOop) => ColorRole::ObjectAccent,
        Some(TokenCategory::Type) => ColorRole::Type,
        Some(TokenCategory::LiteralBoolean) => ColorRole::Logical,
        _ => ColorRole::Ink,
    }
}
