use crate::hover::{HoverCategory, HoverOutcome, plain, symbol_hover};
use crate::query_context::QueryContext;
use pseudolearn_semantic::template_model::{HirTemplate, TemplateId};
use pseudolearn_source::Span;

pub(crate) fn template_hover(
    context: &QueryContext<'_>,
    span: Span,
    template: TemplateId,
) -> Option<HoverOutcome> {
    let model = template_model(context, template)?;
    let instance = pseudolearn_semantic::instance_at_span(context.analysis, span)
        .and_then(|target| symbol_hover(context, target));
    let mut outcome = instance.unwrap_or_else(|| {
        let mut declaration = plain(HoverCategory::Template, &model.name, String::new());
        declaration.signature = Some(model.header.clone());
        declaration
    });
    outcome.template = Some(model.header.clone());
    Some(outcome)
}

pub(crate) fn type_parameter_hover(
    context: &QueryContext<'_>,
    template: TemplateId,
    ordinal: u32,
) -> Option<HoverOutcome> {
    let model = template_model(context, template)?;
    let parameter = model.parameters.get(usize::try_from(ordinal).ok()?)?;
    let mut outcome = plain(
        HoverCategory::TypeParameter,
        &parameter.name,
        parameter.constraint.clone().unwrap_or_default(),
    );
    outcome.template = Some(model.header.clone());
    Some(outcome)
}

fn template_model<'context>(
    context: &'context QueryContext<'_>,
    template: TemplateId,
) -> Option<&'context HirTemplate> {
    context
        .analysis
        .module
        .templates
        .get(usize::try_from(template.0).ok()?)
}
