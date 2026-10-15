use crate::arena::{Arena, ScopeId};
use crate::hir::SemanticModel;
use crate::scopes::{Scope, ScopeKind};
use crate::session::AnalysisSession;
use crate::statement_checker::check_statement_node;
use crate::symbols::Symbol;
use crate::unit_resolver::resolve_units;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::SyntaxTree;

pub struct SemanticChecker<'syntax> {
    syntax_tree: &'syntax SyntaxTree,
    source_text: &'syntax SourceText,
    is_strict: bool,
    symbols: Arena<Symbol>,
    scopes: Arena<Scope>,
    root_scope: ScopeId,
    diagnostics: Vec<Diagnostic>,
}

impl<'syntax> SemanticChecker<'syntax> {
    pub fn new(
        syntax_tree: &'syntax SyntaxTree,
        source_text: &'syntax SourceText,
        is_strict: bool,
    ) -> Self {
        let mut scopes = Arena::new();
        let root_index = scopes.allocate(Scope::new(None, ScopeKind::Global));
        let root_scope = ScopeId(root_index);
        Self {
            syntax_tree,
            source_text,
            is_strict,
            symbols: Arena::new(),
            scopes,
            root_scope,
            diagnostics: Vec::new(),
        }
    }

    pub fn check(mut self) -> (SemanticModel, Vec<Diagnostic>) {
        let mut session = AnalysisSession {
            syntax_tree: self.syntax_tree,
            source_text: self.source_text,
            symbols: &mut self.symbols,
            scopes: &mut self.scopes,
            current_scope: self.root_scope,
            is_strict: self.is_strict,
            diagnostics: &mut self.diagnostics,
        };
        resolve_units(&mut session);
        let node_count = session.syntax_tree.nodes.len();
        for index in 0..node_count {
            let node_kind = session.syntax_tree.nodes.get(index).map(|node| node.kind);
            match node_kind {
                Some(pseudolearn_syntax::NodeKind::IdentifierExpression)
                | Some(pseudolearn_syntax::NodeKind::BinaryExpression)
                | Some(pseudolearn_syntax::NodeKind::UnaryExpression) => {
                    crate::expression_checker::check_expression_node(&mut session, index);
                }
                _ => {
                    check_statement_node(&mut session, index);
                }
            }
        }
        self.check_unused_symbols();
        let model = SemanticModel::new(self.symbols, self.scopes, self.root_scope, self.is_strict);
        (model, self.diagnostics)
    }

    fn check_unused_symbols(&mut self) {
        if !self.is_strict {
            return;
        }
        for symbol in self.symbols.iter() {
            if symbol.kind != crate::symbols::SymbolKind::Variable {
                continue;
            }
            if !symbol.is_read && !symbol.is_assigned {
                self.diagnostics.push(
                    Diagnostic::new(DiagnosticCode::VariableDeclaredNeverUsed, symbol.span)
                        .with_severity(pseudolearn_diagnostics::DiagnosticSeverity::Warning)
                        .with_argument("lexeme", &symbol.name),
                );
            } else if symbol.is_assigned && !symbol.is_read {
                self.diagnostics.push(
                    Diagnostic::new(DiagnosticCode::VariableAssignedNeverRead, symbol.span)
                        .with_severity(pseudolearn_diagnostics::DiagnosticSeverity::Warning)
                        .with_argument("lexeme", &symbol.name),
                );
            }
        }
    }
}
