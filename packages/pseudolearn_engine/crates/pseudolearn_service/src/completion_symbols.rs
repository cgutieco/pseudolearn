use crate::completion_pool::{CandidatePool, Rank, identified, keyed_entry, plain_entry};
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
        let mut entry = keyed_entry(
            builtin_spelling(*kind, scope.profile),
            CompletionKind::Function,
            ("standard_function", Vec::new()),
            Some(scope.label("Funcion estandar", "Standard function")),
        );
        entry.action = CompletionAction::Call {
            parameters: builtin_parameter_names(*kind, scope.profile),
        };
        pool.add(3, identified(entry, kind.as_str()));
    }
}

pub fn declared_type_names(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    let module = &analysis.module;
    let declared = module
        .records
        .iter()
        .map(|record| (record.name.as_str(), "record"))
        .chain(
            module
                .enums
                .iter()
                .map(|declaration| (declaration.name.as_str(), "enum")),
        )
        .chain(
            module
                .interfaces
                .iter()
                .map(|declaration| (declaration.name.as_str(), "interface")),
        );
    for (name, role) in declared {
        if name.starts_with('$') || name.contains('<') {
            continue;
        }
        pool.add(
            1,
            keyed_entry(
                name.to_owned(),
                CompletionKind::Class,
                ("declared_type", vec![role.to_owned()]),
                Some(declared_type_label(scope, role)),
            ),
        );
    }
}

fn declared_type_label(scope: &SourceScope<'_>, role: &str) -> String {
    match role {
        "record" => scope.label("Registro", "Record"),
        "enum" => scope.label("Enumerado", "Enum"),
        _ => scope.label("Interfaz", "Interface"),
    }
}

pub fn constant_names(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let Some(analysis) = scope.analysis else {
        return;
    };
    for name in &analysis.module.constant_names {
        pool.add(
            1,
            keyed_entry(
                name.clone(),
                CompletionKind::Variable,
                ("constant", Vec::new()),
                Some(scope.label("Constante", "Constant")),
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

fn builtin_parameter_names(kind: BuiltinKind, profile: Profile) -> Vec<String> {
    let signature = pseudolearn_lexicon::signature_for_builtin(kind);
    let types = signature.parameter_types;
    types
        .iter()
        .enumerate()
        .map(|(position, parameter)| {
            let name = parameter_role_name(parameter, profile);
            let repeated = types.iter().filter(|other| *other == parameter).count() > 1;
            if repeated {
                format!("{name}{}", position.saturating_add(1))
            } else {
                name.to_owned()
            }
        })
        .collect()
}

fn parameter_role_name(parameter: &str, profile: Profile) -> &'static str {
    let (spanish, english) = match parameter {
        "numeric" => ("numero", "number"),
        "string" => ("texto", "text"),
        "integer" => ("entero", "integer"),
        "real" => ("real", "real"),
        "character" => ("caracter", "character"),
        "stringVector" => ("partes", "parts"),
        "anyClass" => ("objeto", "object"),
        _ => ("valor", "value"),
    };
    match profile {
        Profile::Spanish => spanish,
        Profile::English => english,
    }
}
