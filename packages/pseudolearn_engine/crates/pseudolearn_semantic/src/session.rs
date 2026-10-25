use crate::constant_registry::{ConstantEntry, ConstantLimits};
use crate::expression_model::HirExpression;
use crate::hir::HirModule;
use crate::identities::{ClassId, ExpressionId, FunctionId, LocalId, StatementId, TypeId};
use crate::statement_model::HirStatement;
use crate::type_scope::TypeScope;
use crate::types::Type;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::{IdentifierNormalizer, SourceText, Span};
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use std::collections::{BTreeMap, BTreeSet};

#[derive(Clone, Copy, Debug)]
pub struct SemanticOptions {
    pub profile: Profile,
    pub strict: bool,
}

#[derive(Clone, Copy)]
pub(crate) struct UnitView<'syntax> {
    pub tree: &'syntax SyntaxTree,
    pub source: &'syntax SourceText,
    pub profile: Profile,
}

#[derive(Clone, Default)]
pub(crate) struct UnitScope {
    pub functions: BTreeMap<String, FunctionId>,
    pub classes: BTreeMap<String, ClassId>,
    pub modules: BTreeMap<String, BTreeMap<String, FunctionId>>,
    pub declared: TypeScope,
}

pub(crate) struct AnalysisSession<'syntax> {
    pub tree: &'syntax SyntaxTree,
    pub source: &'syntax SourceText,
    pub options: SemanticOptions,
    pub module: HirModule,
    pub diagnostics: Vec<Diagnostic>,
    pub functions: BTreeMap<String, FunctionId>,
    pub classes: BTreeMap<String, ClassId>,
    pub declared: TypeScope,
    pub constants: Vec<ConstantEntry>,
    pub local_constants: Vec<BTreeMap<String, usize>>,
    pub constant_limits: ConstantLimits,
    pub local_names: Vec<BTreeMap<String, LocalId>>,
    pub declarations: BTreeMap<usize, Vec<LocalId>>,
    pub initialized: Vec<bool>,
    pub reads: BTreeSet<LocalId>,
    pub pending_results: BTreeSet<LocalId>,
    pub writes: BTreeSet<LocalId>,
    pub invalid: BTreeSet<LocalId>,
    pub inferred: BTreeSet<LocalId>,
    pub called: BTreeSet<FunctionId>,
    pub current: FunctionId,
    pub controls: Vec<LocalId>,
    pub returned: bool,
    pub signature_changed: bool,
    pub units: Vec<UnitView<'syntax>>,
    pub unit: usize,
    pub scopes: Vec<UnitScope>,
    pub modules: BTreeMap<String, BTreeMap<String, FunctionId>>,
}

impl<'syntax> AnalysisSession<'syntax> {
    pub(crate) fn new(
        tree: &'syntax SyntaxTree,
        source: &'syntax SourceText,
        options: SemanticOptions,
    ) -> Self {
        Self {
            tree,
            source,
            options,
            module: HirModule::default(),
            diagnostics: Vec::new(),
            functions: BTreeMap::new(),
            classes: BTreeMap::new(),
            declared: TypeScope::default(),
            constants: Vec::new(),
            local_constants: Vec::new(),
            constant_limits: ConstantLimits::default(),
            local_names: Vec::new(),
            declarations: BTreeMap::new(),
            initialized: Vec::new(),
            reads: BTreeSet::new(),
            pending_results: BTreeSet::new(),
            writes: BTreeSet::new(),
            invalid: BTreeSet::new(),
            inferred: BTreeSet::new(),
            called: BTreeSet::new(),
            current: FunctionId(0),
            controls: Vec::new(),
            returned: false,
            signature_changed: false,
            units: vec![UnitView {
                tree,
                source,
                profile: options.profile,
            }],
            unit: 0,
            scopes: vec![UnitScope::default()],
            modules: BTreeMap::new(),
        }
    }

    pub(crate) fn kind(&self, index: usize) -> NodeKind {
        self.tree
            .node(index)
            .map_or(NodeKind::ErrorNode, |node| node.kind)
    }
    pub(crate) fn children(&self, index: usize) -> Vec<usize> {
        self.tree.child_indices(index).to_vec()
    }
    pub(crate) fn child(&self, index: usize, kind: NodeKind) -> Option<usize> {
        self.tree
            .child_indices(index)
            .iter()
            .copied()
            .find(|child| self.kind(*child) == kind)
    }
    pub(crate) fn span(&self, index: usize) -> Span {
        self.tree.span_for_node(index).unwrap_or_default()
    }
    pub(crate) fn token_kind(&self, index: usize) -> Option<TokenKind> {
        let token = usize::try_from(self.tree.node(index)?.first_token).ok()?;
        self.tree.tokens.kind(token)
    }
    pub(crate) fn lexeme(&self, index: usize) -> &str {
        self.tree
            .node(index)
            .and_then(|node| usize::try_from(node.first_token).ok())
            .and_then(|token| self.tree.tokens.text(self.source.as_str(), token))
            .unwrap_or("")
    }
    pub(crate) fn name(&self, index: usize) -> String {
        IdentifierNormalizer::normalize(self.lexeme(index))
    }
}

impl AnalysisSession<'_> {
    pub(crate) fn report(&mut self, code: DiagnosticCode, index: usize) {
        let rigor = if self.options.strict {
            "estricto"
        } else {
            "flexible"
        };
        let mut diagnostic =
            Diagnostic::new(code, self.span(index)).with_severity(code.severity(rigor));
        if code.argument_kind("lexeme").is_some() {
            diagnostic = diagnostic.with_argument(
                "lexeme",
                &crate::diagnostic_arguments::lexeme(self, code, index),
            );
        }
        self.diagnostics.push(diagnostic);
    }

    pub(crate) fn named_report(&mut self, code: DiagnosticCode, index: usize, name: &str) {
        self.report(code, index);
        if let Some(diagnostic) = self
            .diagnostics
            .last_mut()
            .filter(|diagnostic| diagnostic.code.argument_kind("lexeme").is_some())
        {
            diagnostic.arguments.insert(
                "lexeme".to_owned(),
                pseudolearn_diagnostics::DiagnosticArgument::Lexeme(name.to_owned()),
            );
        }
    }

    pub(crate) fn emit(
        &mut self,
        kind: HirExpression,
        type_id: TypeId,
        span: Span,
    ) -> ExpressionId {
        let identifier =
            ExpressionId(u32::try_from(self.module.expressions.kinds.len()).unwrap_or(u32::MAX));
        self.module.expressions.kinds.push(kind);
        self.module.expressions.types.push(type_id);
        self.module
            .expressions
            .value_classes
            .push(self.module.types.value_class(type_id));
        self.module.expressions.spans.push(span);
        identifier
    }

    pub(crate) fn statement(&mut self, kind: HirStatement, span: Span) -> StatementId {
        let identifier =
            StatementId(u32::try_from(self.module.statements.kinds.len()).unwrap_or(u32::MAX));
        self.module.statements.kinds.push(kind);
        self.module.statements.spans.push(span);
        identifier
    }

    pub(crate) fn expression_type(&self, expression: ExpressionId) -> Type {
        usize::try_from(expression.0)
            .ok()
            .and_then(|index| self.module.expressions.types.get(index))
            .map(|identifier| self.module.types.get(*identifier))
            .unwrap_or(Type::Error)
    }

    pub(crate) fn owner(&self) -> Option<ClassId> {
        usize::try_from(self.current.0)
            .ok()
            .and_then(|index| self.module.functions.get(index))
            .and_then(|function| function.owner)
    }

    pub(crate) fn local(&self, name: &str) -> Option<LocalId> {
        usize::try_from(self.current.0)
            .ok()
            .and_then(|index| self.local_names.get(index))
            .and_then(|names| names.get(name))
            .copied()
    }
}

impl AnalysisSession<'_> {
    pub(crate) fn has_token(&self, node: usize, kind: TokenKind) -> bool {
        self.count_token(node, kind) > 0
    }

    pub(crate) fn count_token(&self, node: usize, kind: TokenKind) -> u32 {
        let start = self
            .tree
            .node(node)
            .and_then(|node| usize::try_from(node.first_token).ok())
            .unwrap_or(0);
        let ending = self
            .tree
            .ending_tokens
            .get(node)
            .and_then(|token| usize::try_from(*token).ok())
            .unwrap_or(start);
        u32::try_from(
            (start..=ending)
                .filter(|token| self.tree.tokens.kind(*token) == Some(kind))
                .count(),
        )
        .unwrap_or(u32::MAX)
    }
}

impl AnalysisSession<'_> {
    pub(crate) fn inferred_place(&self, place: &crate::expression_model::HirPlace) -> bool {
        matches!(place, crate::expression_model::HirPlace::Local(local) if self.inferred.contains(local))
    }
}

impl AnalysisSession<'_> {
    pub(crate) fn operator_kind(&self, node: usize) -> Option<TokenKind> {
        let token = self.tree.operator_tokens.get(node).copied().flatten()?;
        self.tree.tokens.kind(usize::try_from(token).ok()?)
    }
    pub(crate) fn operator_span(&self, node: usize) -> Span {
        self.tree
            .operator_tokens
            .get(node)
            .copied()
            .flatten()
            .and_then(|token| usize::try_from(token).ok())
            .and_then(|token| self.tree.tokens.span(token))
            .unwrap_or_default()
    }
}

impl AnalysisSession<'_> {
    pub(crate) fn closing_span(&self, node: usize) -> Span {
        self.tree
            .ending_tokens
            .get(node)
            .copied()
            .and_then(|token| usize::try_from(token).ok())
            .and_then(|token| self.tree.tokens.span(token))
            .unwrap_or_default()
    }
}
