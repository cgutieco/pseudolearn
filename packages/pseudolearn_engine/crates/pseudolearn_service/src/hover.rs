use crate::help_catalog::token_description;
use crate::navigation::Position;
use crate::positions::offset_at;
use crate::query_context::QueryContext;
use crate::spelling::{builtin_spelling, keyword_spelling};
use crate::symbol_queries::{callable_parts, callable_signature};
use crate::type_names::{builtin_type_display, type_display};
use pseudolearn_lexicon::{KeywordKind, find_builtin, signature_for_builtin};
use pseudolearn_semantic::hir::FunctionKind;
use pseudolearn_semantic::{FieldId, ServiceSymbolTarget};
use pseudolearn_syntax::TokenKind;
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum HoverCategory {
    Variable,
    Parameter,
    Field,
    Function,
    Procedure,
    Method,
    Class,
    Template,
    TypeParameter,
    Builtin,
    Keyword,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct HoverOutcome {
    pub category: HoverCategory,
    pub type_name: String,
    pub is_intrinsic: bool,
    pub identifier: String,
    pub signature: Option<String>,
    pub description: Option<String>,
    pub template: Option<String>,
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct SignatureHelp {
    pub active_parameter: u32,
    pub signature: String,
    pub parameters: Vec<String>,
}

pub fn hover_at_position(context: &QueryContext<'_>, position: Position) -> Option<HoverOutcome> {
    super::help_resolution::resolve_help_in_context(context, position)?.hover
}

pub(crate) fn hover_for_token(context: &QueryContext<'_>, slot: usize) -> Option<HoverOutcome> {
    match context.tree.tokens.kind(slot)? {
        TokenKind::Identifier => {
            contextual_hover(context, slot).or_else(|| identifier_hover(context, slot))
        }
        TokenKind::Keyword(kind) => Some(keyword_hover(context, kind)),
        _ => None,
    }
}

fn keyword_hover(context: &QueryContext<'_>, kind: KeywordKind) -> HoverOutcome {
    HoverOutcome {
        category: HoverCategory::Keyword,
        type_name: String::new(),
        is_intrinsic: false,
        identifier: keyword_spelling(kind, context.profile),
        signature: None,
        description: token_description(kind.as_str(), context.locale).map(str::to_owned),
        template: None,
    }
}

fn contextual_hover(context: &QueryContext<'_>, slot: usize) -> Option<HoverOutcome> {
    let identity = crate::help_resolution::module_directive_context(context, slot)
        .map(|(_, _, identity)| identity)
        .or_else(|| {
            crate::contextual_tokens::collect(
                context.tree,
                context.source,
                context.analysis,
                context.profile,
            )
            .get(&slot)
            .copied()
        })?;
    let description = token_description(identity, context.locale)?;
    Some(HoverOutcome {
        category: HoverCategory::Builtin,
        type_name: String::new(),
        is_intrinsic: true,
        identifier: context.token_text(slot).to_owned(),
        signature: None,
        description: Some(description.to_owned()),
        template: None,
    })
}

fn identifier_hover(context: &QueryContext<'_>, slot: usize) -> Option<HoverOutcome> {
    let span = context.tree.tokens.span(slot)?;
    if let Some(found) = context.index.at_token_span(span) {
        if let ServiceSymbolTarget::Template(template) = found.target {
            return crate::template_hover::template_hover(context, span, template);
        }
        return symbol_hover(context, found.target);
    }
    let builtin = find_builtin(context.token_text(slot), context.profile)?;
    let description = signature_for_builtin(builtin);
    let name = builtin_spelling(builtin, context.profile);
    let parameters: Vec<String> = description
        .parameter_types
        .iter()
        .map(|word| builtin_type_display(word, context.profile))
        .collect();
    let result = builtin_type_display(description.return_type, context.profile);
    let connector = keyword_spelling(KeywordKind::TypeConnector, context.profile);
    Some(HoverOutcome {
        category: HoverCategory::Builtin,
        type_name: result.clone(),
        is_intrinsic: true,
        identifier: name.clone(),
        signature: Some(format!(
            "{name}({}) {connector} {result}",
            parameters.join(", ")
        )),
        description: None,
        template: None,
    })
}

pub(crate) fn symbol_hover(
    context: &QueryContext<'_>,
    target: ServiceSymbolTarget,
) -> Option<HoverOutcome> {
    match target {
        ServiceSymbolTarget::Local(id) => local_hover(context, usize::try_from(id.0).ok()?),
        ServiceSymbolTarget::Function(id) => function_hover(context, usize::try_from(id.0).ok()?),
        ServiceSymbolTarget::Class(id) => {
            let class = context
                .analysis
                .module
                .classes
                .get(usize::try_from(id.0).ok()?)?;
            Some(plain(HoverCategory::Class, &class.name, class.name.clone()))
        }
        ServiceSymbolTarget::Field(id) => field_hover(context, id),
        ServiceSymbolTarget::Record(_)
        | ServiceSymbolTarget::Enum(_)
        | ServiceSymbolTarget::Interface(_)
        | ServiceSymbolTarget::Constant(_)
        | ServiceSymbolTarget::Template(_)
        | ServiceSymbolTarget::Builtin(_) => None,
        ServiceSymbolTarget::TypeParameter(template, ordinal) => {
            crate::template_hover::type_parameter_hover(context, template, ordinal)
        }
    }
}

fn local_hover(context: &QueryContext<'_>, slot: usize) -> Option<HoverOutcome> {
    let analysis = context.analysis;
    let local = analysis.module.locals.get(slot)?;
    let category = if local.parameter {
        HoverCategory::Parameter
    } else {
        HoverCategory::Variable
    };
    Some(plain(
        category,
        &local.name,
        type_display(analysis, local.type_id, context.profile),
    ))
}

fn function_hover(context: &QueryContext<'_>, slot: usize) -> Option<HoverOutcome> {
    let analysis = context.analysis;
    let function = analysis.module.functions.get(slot)?;
    let category = match function.kind {
        FunctionKind::Function => HoverCategory::Function,
        FunctionKind::Method | FunctionKind::Constructor => HoverCategory::Method,
        _ => HoverCategory::Procedure,
    };
    let mut outcome = plain(
        category,
        &function.name,
        type_display(analysis, function.result, context.profile),
    );
    outcome.signature = Some(callable_signature(analysis, slot, context.profile));
    Some(outcome)
}

fn field_hover(context: &QueryContext<'_>, id: FieldId) -> Option<HoverOutcome> {
    let analysis = context.analysis;
    let field = analysis
        .module
        .classes
        .iter()
        .flat_map(|class| class.fields.iter())
        .find(|field| field.id == id)?;
    Some(plain(
        HoverCategory::Field,
        &field.name,
        type_display(analysis, field.type_id, context.profile),
    ))
}

pub(crate) fn plain(category: HoverCategory, name: &str, type_name: String) -> HoverOutcome {
    HoverOutcome {
        category,
        type_name,
        is_intrinsic: false,
        identifier: name.to_owned(),
        signature: None,
        description: None,
        template: None,
    }
}

pub fn signature_help_at_position(
    context: &QueryContext<'_>,
    position: Position,
) -> Option<SignatureHelp> {
    let offset = offset_at(context.source.as_str(), position);
    let (open_slot, active) = enclosing_call(context, offset)?;
    let callee = open_slot.checked_sub(1)?;
    if context.tree.tokens.kind(callee)? != TokenKind::Identifier {
        return None;
    }
    let name = context.token_text(callee);
    let member = callee
        .checked_sub(1)
        .is_some_and(|slot| context.tree.tokens.kind(slot) == Some(TokenKind::Dot));
    if let Some(parts) = user_callable(context, name, member) {
        return Some(SignatureHelp {
            active_parameter: active,
            signature: parts.render(context.profile),
            parameters: parts.parameters,
        });
    }
    builtin_help(context, name, active)
}

fn user_callable(
    context: &QueryContext<'_>,
    name: &str,
    member: bool,
) -> Option<crate::symbol_queries::CallableParts> {
    let analysis = context.analysis;
    let wanted = context.profile.fold_word(name);
    let slot = analysis.module.functions.iter().position(|function| {
        context.profile.fold_word(&function.name) == wanted && function.owner.is_some() == member
    })?;
    callable_parts(analysis, slot, context.profile)
}

fn builtin_help(context: &QueryContext<'_>, name: &str, active: u32) -> Option<SignatureHelp> {
    let builtin = find_builtin(name, context.profile)?;
    let description = signature_for_builtin(builtin);
    let parameters: Vec<String> = description
        .parameter_types
        .iter()
        .map(|word| builtin_type_display(word, context.profile))
        .collect();
    let result = builtin_type_display(description.return_type, context.profile);
    let connector = keyword_spelling(KeywordKind::TypeConnector, context.profile);
    let label = builtin_spelling(builtin, context.profile);
    Some(SignatureHelp {
        active_parameter: active,
        signature: format!("{label}({}) {connector} {result}", parameters.join(", ")),
        parameters,
    })
}

fn enclosing_call(context: &QueryContext<'_>, offset: usize) -> Option<(usize, u32)> {
    let mut depth = 0u32;
    let mut commas = 0u32;
    for slot in (0..context.tree.tokens.token_count()).rev() {
        let (Some(kind), Some(span)) = (
            context.tree.tokens.kind(slot),
            context.tree.tokens.span(slot),
        ) else {
            continue;
        };
        if usize::try_from(span.ending).unwrap_or(usize::MAX) > offset {
            continue;
        }
        match kind {
            TokenKind::Newline => return None,
            TokenKind::RightParenthesis => depth = depth.saturating_add(1),
            TokenKind::LeftParenthesis if depth == 0 => return Some((slot, commas)),
            TokenKind::LeftParenthesis => depth = depth.saturating_sub(1),
            TokenKind::Comma if depth == 0 => commas = commas.saturating_add(1),
            _ => {}
        }
    }
    None
}
