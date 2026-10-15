use crate::arena::SymbolId;
use crate::session::AnalysisSession;
use crate::symbols::{Symbol, SymbolKind};
use crate::types::Type;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_syntax::NodeKind;

pub fn resolve_units(session: &mut AnalysisSession<'_>) {
    let node_count = session.syntax_tree.nodes.len();
    for node_index in 0..node_count {
        let node = match session.syntax_tree.nodes.get(node_index) {
            Some(entry) => *entry,
            None => continue,
        };
        if let Some(kind) = symbol_kind_for_node(node.kind) {
            declare_unit(session, node.first_token, kind);
        }
    }
}

fn symbol_kind_for_node(kind: NodeKind) -> Option<SymbolKind> {
    match kind {
        NodeKind::ProgramUnit | NodeKind::ProcedureUnit => Some(SymbolKind::Procedure {
            parameter_types: Vec::new(),
        }),
        NodeKind::FunctionUnit => Some(SymbolKind::Function {
            return_type: Type::Unknown,
            parameter_types: Vec::new(),
        }),
        NodeKind::ClassUnit => Some(SymbolKind::Class {
            superclass_name: None,
        }),
        _ => None,
    }
}

fn duplicate_diagnostic_code(kind: &SymbolKind) -> DiagnosticCode {
    match kind {
        SymbolKind::Class { .. } => DiagnosticCode::DuplicateClass,
        _ => DiagnosticCode::DuplicateSubroutine,
    }
}

fn declare_unit(
    session: &mut AnalysisSession<'_>,
    first_token_index: u32,
    symbol_kind: SymbolKind,
) {
    let name_token_index = usize::try_from(first_token_index)
        .unwrap_or(0)
        .saturating_add(1);
    let name_text = match session
        .syntax_tree
        .tokens
        .text(session.source_text.as_str(), name_token_index)
    {
        Some(text) => text,
        None => return,
    };
    let span = session
        .syntax_tree
        .tokens
        .span(name_token_index)
        .unwrap_or_default();
    let root_scope = session.current_scope;
    let root_scope_instance = match session.scopes.get_mut(root_scope.0) {
        Some(scope) => scope,
        None => return,
    };
    if root_scope_instance.find_local(name_text).is_some() {
        let code = duplicate_diagnostic_code(&symbol_kind);
        session.diagnostics.push(Diagnostic::new(code, span));
        return;
    }
    let symbol =
        Symbol::new(name_text.to_owned(), symbol_kind, span, root_scope).with_type(Type::Void);
    let identifier = session.symbols.allocate(symbol);
    root_scope_instance.insert(name_text, SymbolId(identifier));
}
