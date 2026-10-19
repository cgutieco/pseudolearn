use crate::completion_pool::{CandidatePool, plain_entry};
use crate::completion_scope::SourceScope;
use crate::completion_types::CompletionKind;
use crate::spelling::builtin_spelling;
use crate::symbol_queries::{
    callable_signature, class_chain, enclosing_function, owner_class_of, visible_locals,
};
use crate::type_names::type_display;
use pseudolearn_lexicon::BuiltinKind;
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
        pool.add(
            1,
            plain_entry(
                local.name.clone(),
                CompletionKind::Variable,
                Some(type_name),
            ),
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
            pool.add(
                1,
                plain_entry(field.name.clone(), CompletionKind::Field, Some(type_name)),
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
        pool.add(
            2,
            plain_entry(
                function.name.clone(),
                CompletionKind::Function,
                Some(callable_signature(analysis, index, scope.profile)),
            ),
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
            plain_entry(
                class.name.clone(),
                CompletionKind::Class,
                Some(scope.label("Clase", "Class")),
            ),
        );
    }
}

pub fn builtin_functions(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for kind in BuiltinKind::all() {
        pool.add(
            3,
            plain_entry(
                builtin_spelling(*kind, scope.profile),
                CompletionKind::Function,
                Some(scope.label("Funcion estandar", "Standard function")),
            ),
        );
    }
}
