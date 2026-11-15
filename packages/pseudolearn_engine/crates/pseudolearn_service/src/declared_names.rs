use pseudolearn_semantic::hir::FunctionKind;
use pseudolearn_semantic::{ClassId, FunctionId, ServiceAnalysis, ServiceSymbolTarget};
use pseudolearn_source::{IdentifierNormalizer, SourceId};
use std::collections::BTreeSet;

pub(crate) fn declared_name(
    analysis: &ServiceAnalysis,
    target: ServiceSymbolTarget,
) -> Option<String> {
    let module = &analysis.module;
    match target {
        ServiceSymbolTarget::Record(id) => module
            .records
            .get(usize::try_from(id.0).ok()?)
            .map(|record| record.name.clone()),
        ServiceSymbolTarget::Enum(id) => module
            .enums
            .get(usize::try_from(id.0).ok()?)
            .map(|enumeration| enumeration.name.clone()),
        ServiceSymbolTarget::Interface(id) => module
            .interfaces
            .get(usize::try_from(id.0).ok()?)
            .map(|interface| interface.name.clone()),
        ServiceSymbolTarget::Constant(id) => module
            .constant_names
            .get(usize::try_from(id.0).ok()?)
            .cloned(),
        ServiceSymbolTarget::Template(id) => module
            .templates
            .get(usize::try_from(id.0).ok()?)
            .map(|template| template.name.clone()),
        ServiceSymbolTarget::TypeParameter(id, ordinal) => module
            .templates
            .get(usize::try_from(id.0).ok()?)?
            .parameters
            .get(usize::try_from(ordinal).ok()?)
            .map(|parameter| parameter.name.clone()),
        _ => None,
    }
}

pub(crate) fn name_collides(
    analysis: &ServiceAnalysis,
    target: ServiceSymbolTarget,
    new_name: &str,
) -> bool {
    if let ServiceSymbolTarget::TypeParameter(template, ordinal) = target
        && sibling_parameter_collides(analysis, (template, ordinal), new_name)
    {
        return true;
    }
    let sources: BTreeSet<SourceId> = analysis
        .references_for_target(target)
        .iter()
        .map(|reference| reference.span.source_id)
        .collect();
    sources.iter().any(|source| {
        top_level_names(analysis, *source, target)
            .iter()
            .any(|name| spelled_like(name, new_name))
    })
}

fn spelled_like(name: &str, wanted: &str) -> bool {
    let tail = name.rsplit('.').next().unwrap_or(name);
    IdentifierNormalizer::equals(tail, wanted)
}

fn top_level_names(
    analysis: &ServiceAnalysis,
    source: SourceId,
    except: ServiceSymbolTarget,
) -> Vec<String> {
    let locals = analysis
        .module
        .locals
        .iter()
        .filter(|local| local.span.source_id == source)
        .map(|local| local.name.clone());
    declaration_names(analysis, source, except)
        .into_iter()
        .chain(locals)
        .collect()
}

pub(crate) fn declaration_collides(
    analysis: &ServiceAnalysis,
    source: SourceId,
    except: ServiceSymbolTarget,
    new_name: &str,
) -> bool {
    declaration_names(analysis, source, except)
        .iter()
        .any(|name| spelled_like(name, new_name))
}

fn declaration_names(
    analysis: &ServiceAnalysis,
    source: SourceId,
    except: ServiceSymbolTarget,
) -> Vec<String> {
    let module = &analysis.module;
    let declared = module
        .name_declarations
        .iter()
        .filter(|(span, target)| span.source_id == source && *target != except)
        .filter(|(_, target)| !matches!(target, ServiceSymbolTarget::TypeParameter(_, _)))
        .filter_map(|(_, target)| declared_name(analysis, *target));
    let classes = module
        .classes
        .iter()
        .enumerate()
        .filter(|(index, class)| {
            class.span.source_id == source
                && ServiceSymbolTarget::Class(ClassId(u32::try_from(*index).unwrap_or(u32::MAX)))
                    != except
        })
        .map(|(_, class)| class.name.clone());
    let functions = module
        .functions
        .iter()
        .enumerate()
        .filter(|(index, function)| {
            function.span.source_id == source
                && function.owner.is_none()
                && function.kind != FunctionKind::Main
                && ServiceSymbolTarget::Function(FunctionId(
                    u32::try_from(*index).unwrap_or(u32::MAX),
                )) != except
        })
        .map(|(_, function)| function.name.clone());
    declared.chain(classes).chain(functions).collect()
}

fn sibling_parameter_collides(
    analysis: &ServiceAnalysis,
    (template, ordinal): (pseudolearn_semantic::template_model::TemplateId, u32),
    new_name: &str,
) -> bool {
    let wanted = usize::try_from(ordinal).unwrap_or(usize::MAX);
    usize::try_from(template.0)
        .ok()
        .and_then(|slot| analysis.module.templates.get(slot))
        .is_some_and(|model| {
            model
                .parameters
                .iter()
                .enumerate()
                .any(|(index, parameter)| {
                    index != wanted && IdentifierNormalizer::equals(&parameter.name, new_name)
                })
        })
}
