use crate::completion_pool::{CandidatePool, Rank, keyed_entry, plain_entry};
use crate::completion_scope::SourceScope;
use crate::completion_types::{CompletionAction, CompletionEntry, CompletionKind};
use crate::spelling::builtin_spelling;
use crate::symbol_queries::{
    callable_signature, class_chain, enclosing_function, owner_class_of, parameter_names,
    visible_locals,
};
use crate::type_names::type_display;
use pseudolearn_lexicon::{BuiltinKind, Profile};
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_semantic::hir::FunctionKind;

pub fn local_variables(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    for index in visible_locals(analysis, scope.offset, scope.context.prefix_start) {
        let Some(local) = analysis.module.locals.get(index) else {
            continue;
        };
        let type_name = type_display(analysis, local.type_id, scope.profile);
        let rank = Rank {
            compat: scope.compatibility_of(Some(&analysis.module.types.get(local.type_id))),
            distance: u32::try_from(scope.offset)
                .unwrap_or(u32::MAX)
                .saturating_sub(local.span.start),
        };
        pool.add_ranked(
            1,
            typed_entry(local.name.clone(), CompletionKind::Variable, type_name),
            rank,
        );
    }
}

pub fn enclosing_fields(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    let Some(class_index) = enclosing_function(analysis, scope.offset)
        .and_then(|function| owner_class_of(analysis, function))
    else {
        return;
    };
    for index in class_chain(analysis, class_index) {
        let Some(class) = analysis.module.classes.get(index) else {
            continue;
        };
        for field in &class.fields {
            let type_name = type_display(analysis, field.type_id, scope.profile);
            let rank = Rank {
                compat: scope.compatibility_of(Some(&analysis.module.types.get(field.type_id))),
                distance: 0,
            };
            pool.add_ranked(
                1,
                typed_entry(field.name.clone(), CompletionKind::Field, type_name),
                rank,
            );
        }
    }
}

pub fn user_callables(scope: &SourceScope<'_>, pool: &mut CandidatePool, values_only: bool) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    for (index, function) in analysis.module.functions.iter().enumerate() {
        let wanted = match function.kind {
            FunctionKind::Function => true,
            FunctionKind::Procedure => !values_only,
            _ => false,
        };
        if !wanted {
            continue;
        }
        let result = analysis.module.types.get(function.result);
        let rank = Rank {
            compat: scope.compatibility_of(Some(&result)),
            distance: 0,
        };
        pool.add_ranked(
            2,
            call_entry(analysis, index, CompletionKind::Function, scope.profile),
            rank,
        );
    }
}

pub fn class_names(scope: &SourceScope<'_>, pool: &mut CandidatePool, tier: u8) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    for class in &analysis.module.classes {
        pool.add(
            tier,
            keyed_entry(
                class.name.clone(),
                CompletionKind::Class,
                ("class", Vec::new()),
                Some(scope.label("Clase", "Class")),
            ),
        );
    }
}

pub fn builtin_functions(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for kind in BuiltinKind::all() {
        pool.add(
            3,
            keyed_entry(
                builtin_spelling(*kind, scope.profile),
                CompletionKind::Function,
                ("standard_function", Vec::new()),
                Some(scope.label("Funcion estandar", "Standard function")),
            ),
        );
    }
}

pub fn call_entry(
    analysis: &ServiceAnalysis,
    function_index: usize,
    kind: CompletionKind,
    profile: Profile,
) -> CompletionEntry {
    let name = analysis
        .module
        .functions
        .get(function_index)
        .map(|function| function.name.clone())
        .unwrap_or_default();
    let mut entry = plain_entry(
        name,
        kind,
        Some(callable_signature(analysis, function_index, profile)),
    );
    entry.detail_key = Some("signature".to_owned());
    entry.detail_arguments = vec![callable_signature(analysis, function_index, profile)];
    entry.action = CompletionAction::Call {
        parameters: parameter_names(analysis, function_index),
    };
    entry
}

fn typed_entry(label: String, kind: CompletionKind, type_name: String) -> CompletionEntry {
    keyed_entry(
        label,
        kind,
        ("type_name", vec![type_name.clone()]),
        Some(type_name),
    )
}
