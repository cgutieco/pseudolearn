use crate::spelling::keyword_spelling;
use crate::type_names::type_display;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_semantic::hir::{FunctionKind, Passing};
use pseudolearn_semantic::types::Type;

pub fn enclosing_function(analysis: &ServiceAnalysis, offset: usize) -> Option<usize> {
    let position = u32::try_from(offset).unwrap_or(u32::MAX);
    analysis
        .module
        .functions
        .iter()
        .enumerate()
        .filter(|(_, function)| function.span.start <= position && position <= function.span.ending)
        .min_by_key(|(_, function)| function.span.ending.saturating_sub(function.span.start))
        .map(|(index, _)| index)
}

pub fn visible_locals(analysis: &ServiceAnalysis, offset: usize, limit: usize) -> Vec<usize> {
    let Some(function_index) = enclosing_function(analysis, offset) else {
        return Vec::new();
    };
    let boundary = u32::try_from(limit).unwrap_or(u32::MAX);
    analysis
        .module
        .locals
        .iter()
        .enumerate()
        .filter(|(_, local)| {
            usize::try_from(local.scope.0).is_ok_and(|scope| scope == function_index)
                && local.span.start < boundary
        })
        .map(|(index, _)| index)
        .collect()
}

pub fn owner_class_of(analysis: &ServiceAnalysis, function_index: usize) -> Option<usize> {
    let function = analysis.module.functions.get(function_index)?;
    usize::try_from(function.owner?.0).ok()
}

pub fn class_for_local(analysis: &ServiceAnalysis, local_index: usize) -> Option<usize> {
    let local = analysis.module.locals.get(local_index)?;
    match analysis.module.types.get(local.type_id) {
        Type::Object(class_id) => usize::try_from(class_id.0).ok(),
        _ => None,
    }
}

pub fn class_chain(analysis: &ServiceAnalysis, class_index: usize) -> Vec<usize> {
    let mut chain = Vec::new();
    let mut current = Some(class_index);
    while let Some(index) = current {
        if chain.contains(&index) || chain.len() > 32 {
            break;
        }
        chain.push(index);
        current = analysis
            .module
            .classes
            .get(index)
            .and_then(|class| class.superclass)
            .and_then(|parent| usize::try_from(parent.0).ok());
    }
    chain
}

pub struct CallableParts {
    pub name: String,
    pub parameters: Vec<String>,
    pub result: Option<String>,
}

impl CallableParts {
    pub fn render(&self, profile: Profile) -> String {
        let mut signature = format!("{}({})", self.name, self.parameters.join(", "));
        if let Some(result) = &self.result {
            let connector = keyword_spelling(KeywordKind::TypeConnector, profile);
            signature.push_str(&format!(" {connector} {result}"));
        }
        signature
    }
}

pub fn callable_signature(
    analysis: &ServiceAnalysis,
    function_index: usize,
    profile: Profile,
) -> String {
    callable_parts(analysis, function_index, profile)
        .map(|parts| parts.render(profile))
        .unwrap_or_default()
}

pub fn callable_parts(
    analysis: &ServiceAnalysis,
    function_index: usize,
    profile: Profile,
) -> Option<CallableParts> {
    let function = analysis.module.functions.get(function_index)?;
    let mut parameters = Vec::new();
    for parameter in &function.parameters {
        let Some(local) = usize::try_from(parameter.0)
            .ok()
            .and_then(|index| analysis.module.locals.get(index))
        else {
            continue;
        };
        let mode = match local.passing {
            Passing::Reference => keyword_spelling(KeywordKind::ByReference, profile),
            Passing::Value => keyword_spelling(KeywordKind::ByValue, profile),
        };
        parameters.push(format!("{} {mode}", local.name));
    }
    let result = (function.kind == FunctionKind::Function)
        .then(|| type_display(analysis, function.result, profile))
        .filter(|text| !text.is_empty());
    Some(CallableParts {
        name: function.name.clone(),
        parameters,
        result,
    })
}

pub fn parameter_names(analysis: &ServiceAnalysis, function_index: usize) -> Vec<String> {
    let Some(function) = analysis.module.functions.get(function_index) else {
        return Vec::new();
    };
    function
        .parameters
        .iter()
        .filter_map(|parameter| {
            usize::try_from(parameter.0)
                .ok()
                .and_then(|index| analysis.module.locals.get(index))
                .map(|local| local.name.clone())
        })
        .collect()
}
