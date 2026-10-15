use crate::hir::HirField;
use crate::identities::{ClassId, FieldId};
use crate::session::AnalysisSession;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::{NodeKind, TokenKind};

pub(crate) fn members(session: &mut AnalysisSession<'_>, class: ClassId) {
    let index = usize::try_from(class.0).unwrap_or(usize::MAX);
    let Some(model) = session.module.classes.get(index) else {
        return;
    };
    let syntax = model.syntax;
    let identifiers: Vec<_> = session
        .children(syntax)
        .into_iter()
        .filter(|node| session.kind(*node) == NodeKind::Identifier)
        .collect();
    if let Some(superclass) = identifiers.get(1).copied() {
        let name = session.name(superclass);
        if let Some(identifier) = session.classes.get(&name).copied() {
            if let Some(model) = session.module.classes.get_mut(index) {
                model.superclass = Some(identifier);
            }
        } else {
            session.named_report(DiagnosticCode::UndeclaredSuperclass, superclass, &name);
        }
    }
    for child in session.children(syntax) {
        match session.kind(child) {
            NodeKind::FieldDeclaration => fields(session, class, child),
            NodeKind::MethodMember | NodeKind::ConstructorMember => method(session, class, child),
            _ => (),
        }
    }
}

fn fields(session: &mut AnalysisSession<'_>, class: ClassId, node: usize) {
    let Some(declaration) = session.tree.child_indices(node).first().copied() else {
        return;
    };
    let Some(kind) = session.child(declaration, NodeKind::Type) else {
        return;
    };
    let type_id = crate::type_resolution::resolve(session, kind);
    let private =
        session.token_kind(node) == Some(TokenKind::Keyword(KeywordKind::PrivateVisibility));
    for name_node in session.children(declaration) {
        if session.kind(name_node) != NodeKind::Identifier {
            continue;
        }
        let name = session.name(name_node);
        let index = usize::try_from(class.0).unwrap_or(usize::MAX);
        let duplicate = session
            .module
            .classes
            .get(index)
            .is_some_and(|model| model.fields.iter().any(|field| field.name == name));
        if duplicate {
            session.named_report(DiagnosticCode::DuplicateMember, name_node, &name);
            continue;
        }
        let field = HirField {
            id: next_field_id(session),
            name,
            type_id,
            owner: class,
            private,
            span: session.span(name_node),
        };
        if let Some(model) = session.module.classes.get_mut(index) {
            model.fields.push(field);
        }
    }
}

fn method(session: &mut AnalysisSession<'_>, class: ClassId, node: usize) {
    let identifier = crate::unit_resolver::register_function(session, node, Some(class));
    let constructor = session.kind(node) == NodeKind::ConstructorMember;
    let index = usize::try_from(class.0).unwrap_or(usize::MAX);
    let duplicate = session
        .module
        .classes
        .get(index)
        .is_some_and(|model| constructor && model.constructor.is_some());
    if duplicate {
        session.report(DiagnosticCode::DuplicateConstructor, node);
    }
    let private =
        session.token_kind(node) == Some(TokenKind::Keyword(KeywordKind::PrivateVisibility));
    if let Some(function) = usize::try_from(identifier.0)
        .ok()
        .and_then(|index| session.module.functions.get_mut(index))
    {
        function.private = private;
    }
    if let Some(model) = session.module.classes.get_mut(index) {
        if constructor {
            model.constructor = Some(identifier);
        } else {
            model.methods.push(identifier);
        }
    }
}

fn next_field_id(session: &AnalysisSession<'_>) -> FieldId {
    let count = session
        .module
        .classes
        .iter()
        .map(|model| model.fields.len())
        .sum::<usize>();
    FieldId(u32::try_from(count).unwrap_or(u32::MAX))
}
