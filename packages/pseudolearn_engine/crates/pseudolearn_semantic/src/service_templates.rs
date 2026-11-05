use crate::hir::HirModule;
use crate::identities::{ClassId, FieldId, FunctionId, LocalId};
use crate::service_model::{ServiceReference, ServiceSymbolTarget};
use crate::template_model::TemplateId;
use pseudolearn_source::Span;
use std::collections::BTreeSet;

pub(crate) type InstanceUse = (Span, ServiceSymbolTarget);

pub(crate) fn canonicalize(
    module: &HirModule,
    occurrences: &mut Vec<ServiceReference>,
) -> Vec<InstanceUse> {
    let mut instance_uses = Vec::new();
    for occurrence in occurrences.iter_mut() {
        let original = occurrence.target;
        let canonical = canonical_target(module, original);
        if canonical == original {
            continue;
        }
        if matches!(canonical, ServiceSymbolTarget::Template(_)) && !occurrence.is_declaration {
            instance_uses.push((occurrence.span, original));
        }
        occurrence.target = canonical;
    }
    let mut seen = BTreeSet::new();
    occurrences.retain(|occurrence| {
        seen.insert((
            occurrence.span,
            occurrence.target,
            occurrence.is_declaration,
        ))
    });
    instance_uses
}

pub(crate) fn canonical_target(
    module: &HirModule,
    target: ServiceSymbolTarget,
) -> ServiceSymbolTarget {
    let canonical = match target {
        ServiceSymbolTarget::Function(function) => canonical_function(module, function),
        ServiceSymbolTarget::Class(class) => class_template(module, class),
        ServiceSymbolTarget::Record(record) => slot(record.0)
            .and_then(|index| module.records.get(index))
            .and_then(|model| template_at(module, model.span)),
        ServiceSymbolTarget::Interface(interface) => slot(interface.0)
            .and_then(|index| module.interfaces.get(index))
            .and_then(|model| template_at(module, model.span)),
        ServiceSymbolTarget::Field(field) => canonical_field(module, field),
        ServiceSymbolTarget::Local(local) => canonical_local(module, local),
        _ => None,
    };
    canonical.unwrap_or(target)
}

fn slot(identifier: u32) -> Option<usize> {
    usize::try_from(identifier).ok()
}

fn template_at(module: &HirModule, span: Span) -> Option<ServiceSymbolTarget> {
    module
        .templates
        .iter()
        .position(|template| template.span == span)
        .and_then(|index| u32::try_from(index).ok())
        .map(|index| ServiceSymbolTarget::Template(TemplateId(index)))
}

fn class_template(module: &HirModule, class: ClassId) -> Option<ServiceSymbolTarget> {
    let model = module.classes.get(slot(class.0)?)?;
    template_at(module, model.span)
}

fn is_instance_class(module: &HirModule, class: ClassId) -> bool {
    class_template(module, class).is_some()
}

fn is_instance_member(module: &HirModule, function: FunctionId) -> bool {
    let Some(model) = slot(function.0).and_then(|index| module.functions.get(index)) else {
        return false;
    };
    template_at(module, model.span).is_some()
        || model
            .owner
            .is_some_and(|owner| is_instance_class(module, owner))
}

fn canonical_function(module: &HirModule, function: FunctionId) -> Option<ServiceSymbolTarget> {
    let model = module.functions.get(slot(function.0)?)?;
    if let Some(template) = template_at(module, model.span) {
        return Some(template);
    }
    if !is_instance_member(module, function) {
        return None;
    }
    module
        .functions
        .iter()
        .position(|candidate| candidate.span == model.span)
        .and_then(|index| u32::try_from(index).ok())
        .map(|index| ServiceSymbolTarget::Function(FunctionId(index)))
}

fn canonical_field(module: &HirModule, field: FieldId) -> Option<ServiceSymbolTarget> {
    let fields = || module.classes.iter().flat_map(|class| class.fields.iter());
    let model = fields().find(|candidate| candidate.id == field)?;
    if !is_instance_class(module, model.owner) {
        return None;
    }
    fields()
        .find(|candidate| candidate.span == model.span)
        .map(|candidate| ServiceSymbolTarget::Field(candidate.id))
}

fn canonical_local(module: &HirModule, local: LocalId) -> Option<ServiceSymbolTarget> {
    let model = module.locals.get(slot(local.0)?)?;
    if !is_instance_member(module, model.scope) {
        return None;
    }
    module
        .locals
        .iter()
        .position(|candidate| candidate.span == model.span && candidate.name == model.name)
        .and_then(|index| u32::try_from(index).ok())
        .map(|index| ServiceSymbolTarget::Local(LocalId(index)))
}
