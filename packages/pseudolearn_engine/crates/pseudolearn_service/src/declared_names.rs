use pseudolearn_semantic::hir::FunctionKind;
use pseudolearn_semantic::{ServiceAnalysis, ServiceSymbolTarget};
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
        _ => None,
    }
}

pub(crate) fn name_collides(
    analysis: &ServiceAnalysis,
    target: ServiceSymbolTarget,
    new_name: &str,
) -> bool {
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
    let module = &analysis.module;
    let declared = module
        .name_declarations
        .iter()
        .filter(|(span, target)| span.source_id == source && *target != except)
        .filter_map(|(_, target)| declared_name(analysis, *target));
    let classes = module
        .classes
        .iter()
        .filter(|class| class.span.source_id == source)
        .map(|class| class.name.clone());
    let functions = module
        .functions
        .iter()
        .filter(|function| function.span.source_id == source)
        .filter(|function| function.owner.is_none() && function.kind != FunctionKind::Main)
        .map(|function| function.name.clone());
    let locals = module
        .locals
        .iter()
        .filter(|local| local.span.source_id == source)
        .map(|local| local.name.clone());
    declared
        .chain(classes)
        .chain(functions)
        .chain(locals)
        .collect()
}
