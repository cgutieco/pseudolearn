use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;
use crate::template_model::{HirTemplate, HirTypeParameter, TemplateId, TemplateKind};
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn declare(
    session: &mut AnalysisSession<'_>,
    (node, name, kind): (usize, &str, NodeKind),
    parameter_nodes: &[usize],
) -> TemplateId {
    let identity = TemplateId(u32::try_from(session.module.templates.len()).unwrap_or(u32::MAX));
    let parameters: Vec<HirTypeParameter> = parameter_nodes
        .iter()
        .map(|parameter| type_parameter(session, *parameter))
        .collect();
    let template = HirTemplate {
        name: name.to_owned(),
        kind: template_kind(kind),
        header: header(session, node),
        span: session.span(node),
        parameters,
    };
    session.module.templates.push(template);
    session.note_declaration(node, ServiceSymbolTarget::Template(identity));
    for (index, parameter) in parameter_nodes.iter().enumerate() {
        let ordinal = u32::try_from(index).unwrap_or(u32::MAX);
        session.note_declaration(
            *parameter,
            ServiceSymbolTarget::TypeParameter(identity, ordinal),
        );
    }
    note_parameter_uses(session, node, identity);
    identity
}

pub(crate) fn note_named_use(session: &mut AnalysisSession<'_>, node: usize, name: &str) {
    let scope = &session.generics;
    let identity = scope
        .records
        .get(name)
        .or_else(|| scope.classes.get(name))
        .or_else(|| scope.variants.get(name))
        .or_else(|| scope.interfaces.get(name))
        .or_else(|| scope.functions.get(name))
        .map(|template| template.identity);
    if let Some(identity) = identity
        && session.token_kind(node) == Some(TokenKind::Identifier)
    {
        session.note_use(node, ServiceSymbolTarget::Template(identity));
    }
}

fn template_kind(kind: NodeKind) -> TemplateKind {
    match kind {
        NodeKind::RecordUnit => TemplateKind::Record,
        NodeKind::ClassUnit => TemplateKind::Class,
        NodeKind::InterfaceUnit => TemplateKind::Interface,
        NodeKind::VariantUnit => TemplateKind::Variant,
        _ => TemplateKind::Subprogram,
    }
}

fn type_parameter(session: &AnalysisSession<'_>, node: usize) -> HirTypeParameter {
    let parts = session.children(node);
    let name_node = parts.first().copied().unwrap_or(node);
    HirTypeParameter {
        name: session.name(name_node),
        constraint: parts.get(1).map(|constraint| session.name(*constraint)),
        span: session.span(name_node),
    }
}

fn header(session: &AnalysisSession<'_>, node: usize) -> String {
    let span = session.span(node);
    let start = usize::try_from(span.start).unwrap_or(usize::MAX);
    let text = session.source.as_str().get(start..).unwrap_or("");
    text.lines().next().unwrap_or("").trim().to_owned()
}

fn note_parameter_uses(session: &mut AnalysisSession<'_>, node: usize, identity: TemplateId) {
    let names: Vec<String> = usize::try_from(identity.0)
        .ok()
        .and_then(|slot| session.module.templates.get(slot))
        .map(|template| {
            template
                .parameters
                .iter()
                .map(|parameter| parameter.name.clone())
                .collect()
        })
        .unwrap_or_default();
    let span = session.span(node);
    let uses: Vec<(usize, usize)> = (0..session.tree.nodes.len())
        .filter(|candidate| session.kind(*candidate) == NodeKind::Type)
        .filter(|candidate| encloses(span, session.span(*candidate)))
        .filter(|candidate| session.token_kind(*candidate) == Some(TokenKind::Identifier))
        .filter_map(|candidate| {
            let name = session.name(candidate);
            names
                .iter()
                .position(|parameter| *parameter == name)
                .map(|ordinal| (candidate, ordinal))
        })
        .collect();
    for (candidate, ordinal) in uses {
        let ordinal = u32::try_from(ordinal).unwrap_or(u32::MAX);
        session.note_use(
            candidate,
            ServiceSymbolTarget::TypeParameter(identity, ordinal),
        );
    }
}

fn encloses(outer: pseudolearn_source::Span, inner: pseudolearn_source::Span) -> bool {
    outer.source_id == inner.source_id && outer.start <= inner.start && inner.ending <= outer.ending
}
