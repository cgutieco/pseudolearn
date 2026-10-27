use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::collection_model::CollectionAction;
use pseudolearn_semantic::{HirExpression, ServiceAnalysis};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use std::collections::BTreeMap;

type Tokens = BTreeMap<usize, &'static str>;

pub(crate) fn collect(
    tree: &SyntaxTree,
    source: &SourceText,
    analysis: &ServiceAnalysis,
    profile: Profile,
) -> Tokens {
    let candidates: Tokens = (0..tree.tokens.token_count())
        .filter_map(|token| {
            if tree.tokens.kind(token) != Some(TokenKind::Identifier) {
                return None;
            }
            let word = tree.tokens.text(source.as_str(), token)?;
            let identity = pseudolearn_syntax::contextual_identity(
                &profile.fold_word(word),
                profile.as_str(),
            )?;
            Some((token, identity))
        })
        .collect();
    let mut output = structural(tree, &candidates);
    collection_calls(tree, analysis, &candidates, &mut output);
    output
}

fn structural(tree: &SyntaxTree, candidates: &Tokens) -> Tokens {
    let mut output = Tokens::new();
    for (node, syntax) in tree.nodes.iter().enumerate() {
        for (token, identity) in candidates {
            if owns(syntax.kind, identity) && structural_token(tree, node, *token, identity) {
                output.insert(*token, *identity);
            }
        }
    }
    output
}

fn collection_calls(
    tree: &SyntaxTree,
    analysis: &ServiceAnalysis,
    candidates: &Tokens,
    output: &mut Tokens,
) {
    for (kind, span) in analysis
        .module
        .expressions
        .kinds
        .iter()
        .zip(&analysis.module.expressions.spans)
    {
        let HirExpression::Collection(expression) = kind else {
            continue;
        };
        for (token, identity) in candidates {
            let Some(position) = tree.tokens.span(*token) else {
                continue;
            };
            if position.start < span.start || position.ending > span.ending {
                continue;
            }
            let constructor =
                expression.action == CollectionAction::New && position.start == span.start;
            if (constructor && matches!(*identity, "vectorType" | "dictionaryType"))
                || (action_identity(expression.action) == Some(identity)
                    && method_token(tree, *span, *token))
            {
                output.insert(*token, *identity);
            }
        }
    }
}

fn method_token(tree: &SyntaxTree, span: pseudolearn_source::Span, token: usize) -> bool {
    tree.nodes
        .iter()
        .enumerate()
        .filter(|(node, syntax)| {
            syntax.kind == NodeKind::Postfix && tree.span_for_node(*node) == Some(span)
        })
        .any(|(node, _)| {
            tree.child_indices(node)
                .get(1)
                .and_then(|child| tree.node(*child))
                .is_some_and(|syntax| {
                    syntax.kind == NodeKind::Identifier
                        && usize::try_from(syntax.first_token).ok() == Some(token)
                })
        })
}

fn owns(kind: NodeKind, identity: &str) -> bool {
    matches!(
        (kind, identity),
        (NodeKind::InterfaceUnit, "interfaceKeyword" | "endInterface")
            | (NodeKind::Realization, "implementsKeyword")
            | (NodeKind::ForEachLoop, "eachKeyword" | "inKeyword")
            | (NodeKind::DeferStatement, "deferKeyword" | "endDefer")
            | (NodeKind::BreakStatement, "breakKeyword")
            | (
                NodeKind::Type,
                "vectorType"
                    | "dictionaryType"
                    | "bytesType"
                    | "ioErrorType"
                    | "consoleCapabilityType"
                    | "argumentsCapabilityType"
                    | "directoryCapabilityType"
                    | "fileCapabilityType"
                    | "clockCapabilityType"
                    | "timerCapabilityType"
            )
            | (
                NodeKind::Postfix,
                "requestConsole"
                    | "requestArguments"
                    | "requestDirectory"
                    | "requestClock"
                    | "requestTimer"
            )
    )
}

fn action_identity(action: CollectionAction) -> Option<&'static str> {
    Some(match action {
        CollectionAction::New => return None,
        CollectionAction::Length => "collectionLength",
        CollectionAction::Append => "vectorAppend",
        CollectionAction::Insert => "vectorInsert",
        CollectionAction::Remove => "collectionRemove",
        CollectionAction::Find => "dictionaryFind",
    })
}

fn structural_token(tree: &SyntaxTree, node: usize, token: usize, identity: &str) -> bool {
    let Some(syntax) = tree.node(node) else {
        return false;
    };
    let first = usize::try_from(syntax.first_token).unwrap_or(usize::MAX);
    let last = tree
        .ending_tokens
        .get(node)
        .and_then(|value| usize::try_from(*value).ok())
        .unwrap_or(usize::MAX);
    if token < first || token > last {
        return false;
    }
    match identity {
        "endInterface" | "endDefer" => token == last,
        "eachKeyword" => {
            (first..token)
                .filter_map(|slot| tree.tokens.kind(slot))
                .filter(|kind| !kind.is_trivia())
                .count()
                == 1
        }
        "inKeyword" => follows_bindings(tree, node, token),
        _ => token == first,
    }
}

fn follows_bindings(tree: &SyntaxTree, node: usize, token: usize) -> bool {
    let Some(bindings) = tree.child_indices(node).iter().find(|child| {
        tree.node(**child)
            .is_some_and(|syntax| syntax.kind == NodeKind::IterationBindings)
    }) else {
        return false;
    };
    let Some(last) = tree
        .ending_tokens
        .get(*bindings)
        .and_then(|value| usize::try_from(*value).ok())
    else {
        return false;
    };
    last.checked_add(1).and_then(|start| {
        (start..=token).find(|slot| {
            tree.tokens
                .kind(*slot)
                .is_some_and(|kind| !kind.is_trivia())
        })
    }) == Some(token)
}

pub(crate) fn construction(
    analysis: &ServiceAnalysis,
    span: pseudolearn_source::Span,
    identity: &str,
) -> String {
    for (kind, location) in analysis
        .module
        .expressions
        .kinds
        .iter()
        .zip(&analysis.module.expressions.spans)
    {
        let HirExpression::Collection(expression) = kind else {
            continue;
        };
        if location.start <= span.start
            && location.ending >= span.ending
            && let Some(model) = analysis.module.collections.get(&expression.class)
        {
            return if model.key.is_some() {
                "dictionaryType"
            } else {
                "vectorType"
            }
            .to_owned();
        }
    }
    identity.to_owned()
}
