use crate::completion_scope::SourceScope;
use crate::expected_slot::ExpectedSlot;
use crate::symbol_queries::{class_chain, enclosing_function, owner_class_of, visible_locals};
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_semantic::identities::TypeId;
use pseudolearn_semantic::types::Type;

pub fn expected_type(scope: &SourceScope<'_>) -> Option<Type> {
    let analysis = scope.analysis?;
    let type_id = match &scope.context.expected {
        ExpectedSlot::Unconstrained => return None,
        ExpectedSlot::Condition => return Some(Type::Boolean),
        ExpectedSlot::Assignment { target } => target_type(scope, analysis, target)?,
        ExpectedSlot::Argument { callee, index } => {
            parameter_type(scope, analysis, callee, *index)?
        }
    };
    known(analysis.module.types.get(type_id))
}

fn known(kind: Type) -> Option<Type> {
    (!matches!(kind, Type::Unknown | Type::Error | Type::Unit | Type::Never)).then_some(kind)
}

fn target_type(scope: &SourceScope<'_>, analysis: &ServiceAnalysis, name: &str) -> Option<TypeId> {
    let wanted = scope.profile.fold_word(name);
    let local = visible_locals(analysis, scope.offset, scope.context.prefix_start)
        .into_iter()
        .filter_map(|index| analysis.module.locals.get(index))
        .find(|local| scope.profile.fold_word(&local.name) == wanted);
    if let Some(local) = local {
        return Some(local.type_id);
    }
    let class_index = enclosing_function(analysis, scope.offset)
        .and_then(|function| owner_class_of(analysis, function))?;
    class_chain(analysis, class_index)
        .into_iter()
        .filter_map(|index| analysis.module.classes.get(index))
        .flat_map(|class| class.fields.iter())
        .find(|field| scope.profile.fold_word(&field.name) == wanted)
        .map(|field| field.type_id)
}

fn parameter_type(
    scope: &SourceScope<'_>,
    analysis: &ServiceAnalysis,
    callee: &str,
    index: usize,
) -> Option<TypeId> {
    let wanted = scope.profile.fold_word(callee);
    let function = analysis
        .module
        .functions
        .iter()
        .find(|function| scope.profile.fold_word(&function.name) == wanted)?;
    let parameter = function.parameters.get(index)?;
    let local = usize::try_from(parameter.0)
        .ok()
        .and_then(|slot| analysis.module.locals.get(slot))?;
    Some(local.type_id)
}

pub fn compatibility(expected: Option<&Type>, candidate: Option<&Type>) -> u8 {
    let (Some(expected), Some(candidate)) = (expected, candidate) else {
        return 2;
    };
    if matches!(candidate, Type::Unknown | Type::Error) {
        return 2;
    }
    if expected == candidate {
        return 0;
    }
    if *expected == Type::Real && *candidate == Type::Integer {
        return 1;
    }
    3
}
