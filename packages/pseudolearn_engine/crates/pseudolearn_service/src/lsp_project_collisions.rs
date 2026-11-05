use crate::lsp_project_selection::to_index;
use pseudolearn_semantic::{
    ClassId, FieldId, FunctionId, LocalId, ServiceAnalysis, ServiceSymbolTarget,
};
use pseudolearn_source::IdentifierNormalizer;

pub(crate) fn target_collides(
    analysis: &ServiceAnalysis,
    target: ServiceSymbolTarget,
    new_name: &str,
) -> bool {
    match target {
        ServiceSymbolTarget::Local(local) => local_collision(analysis, local, new_name),
        ServiceSymbolTarget::Function(function) => function_collision(analysis, function, new_name),
        ServiceSymbolTarget::Class(class) => class_collision(analysis, class, new_name),
        ServiceSymbolTarget::Field(field) => field_collision(analysis, field, new_name),
        ServiceSymbolTarget::Record(_)
        | ServiceSymbolTarget::Enum(_)
        | ServiceSymbolTarget::Interface(_)
        | ServiceSymbolTarget::Constant(_)
        | ServiceSymbolTarget::Template(_)
        | ServiceSymbolTarget::TypeParameter(_, _) => {
            crate::declared_names::name_collides(analysis, target, new_name)
        }
        ServiceSymbolTarget::Builtin(_) => true,
    }
}

fn local_collision(analysis: &ServiceAnalysis, local: LocalId, new_name: &str) -> bool {
    let position = to_index(local.0);
    let Some(current) = analysis.module.locals.get(position) else {
        return true;
    };
    analysis
        .module
        .locals
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && candidate.scope == current.scope
                && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
}

fn function_collision(analysis: &ServiceAnalysis, function: FunctionId, new_name: &str) -> bool {
    let position = to_index(function.0);
    let Some(current) = analysis.module.functions.get(position) else {
        return true;
    };
    let unit = analysis.module.units.function_unit(function);
    analysis
        .module
        .functions
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && IdentifierNormalizer::equals(&candidate.name, new_name)
                && candidate.owner == current.owner
                && analysis
                    .module
                    .units
                    .function_unit(FunctionId(u32::try_from(index).unwrap_or(u32::MAX)))
                    == unit
        })
}

fn class_collision(analysis: &ServiceAnalysis, class: ClassId, new_name: &str) -> bool {
    let position = to_index(class.0);
    let unit = analysis.module.units.class_unit(class);
    analysis
        .module
        .classes
        .iter()
        .enumerate()
        .any(|(index, candidate)| {
            index != position
                && IdentifierNormalizer::equals(&candidate.name, new_name)
                && analysis
                    .module
                    .units
                    .class_unit(ClassId(u32::try_from(index).unwrap_or(u32::MAX)))
                    == unit
        })
}

fn field_collision(analysis: &ServiceAnalysis, field: FieldId, new_name: &str) -> bool {
    analysis.module.classes.iter().any(|class| {
        class.fields.iter().any(|candidate| {
            candidate.id != field && IdentifierNormalizer::equals(&candidate.name, new_name)
        })
    })
}
