use crate::completion_pool::{CandidatePool, plain_entry};
use crate::completion_scope::SourceScope;
use crate::completion_types::CompletionKind;
use crate::cursor_context::Receiver;
use crate::symbol_queries::{
    callable_signature, class_chain, class_for_local, enclosing_function, owner_class_of,
    visible_locals,
};
use crate::type_names::type_display;
use pseudolearn_semantic::ServiceAnalysis;

fn receiver_class(
    scope: &SourceScope<'_>,
    analysis: &ServiceAnalysis,
    receiver: &Receiver,
) -> Option<usize> {
    match receiver {
        Receiver::CurrentObject => enclosing_function(analysis, scope.offset)
            .and_then(|function| owner_class_of(analysis, function)),
        Receiver::Named(name) => {
            let wanted = scope.profile.fold_word(name);
            visible_locals(analysis, scope.offset, scope.context.prefix_start)
                .into_iter()
                .filter(|index| {
                    analysis
                        .module
                        .locals
                        .get(*index)
                        .is_some_and(|local| scope.profile.fold_word(&local.name) == wanted)
                })
                .find_map(|index| class_for_local(analysis, index))
        }
        Receiver::Unknown => None,
    }
}

pub fn member_candidates(scope: &SourceScope<'_>, receiver: &Receiver, pool: &mut CandidatePool) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    let Some(class_index) = receiver_class(scope, analysis, receiver) else {
        return;
    };
    for index in class_chain(analysis, class_index) {
        let Some(class) = analysis.module.classes.get(index) else {
            continue;
        };
        for field in &class.fields {
            let type_name = type_display(analysis, field.type_id, scope.profile);
            pool.add(
                1,
                plain_entry(field.name.clone(), CompletionKind::Field, Some(type_name)),
            );
        }
        for method in &class.methods {
            let slot = usize::try_from(method.0).unwrap_or(usize::MAX);
            let Some(function) = analysis.module.functions.get(slot) else {
                continue;
            };
            pool.add(
                1,
                plain_entry(
                    function.name.clone(),
                    CompletionKind::Method,
                    Some(callable_signature(analysis, slot, scope.profile)),
                ),
            );
        }
    }
}
