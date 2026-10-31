use crate::hir::{HirLocal, HirModule, Passing};
use crate::identities::{ExpressionId, FunctionId, LocalId, TypeId};
pub use crate::inspection_records::record_type;
use crate::session::{AnalysisSession, SemanticOptions};
use crate::types::Type;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::{IdentifierNormalizer, SourceText, Span};
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};

#[derive(Default)]
pub struct InspectionEnvironment {
    pub module: HirModule,
    pub bindings: Vec<(String, TypeId)>,
}

pub struct InspectionExpression {
    pub module: HirModule,
    pub expression: ExpressionId,
    pub parameters: Vec<LocalId>,
    pub text_captures: Vec<String>,
}

pub fn check_inspection(
    tree: &SyntaxTree,
    source: &SourceText,
    environment: InspectionEnvironment,
    profile: Profile,
) -> Result<InspectionExpression, Vec<Diagnostic>> {
    validate(tree)?;
    let root = tree.node_count().checked_sub(1).ok_or_else(rejection)?;
    let mut session = AnalysisSession::new(
        tree,
        source,
        SemanticOptions {
            profile,
            strict: true,
        },
    );
    session.module = environment.module;
    let mut parameters = bind_environment(&mut session, environment.bindings)?;
    crate::inspection_records::register(&mut session)?;
    let expression = crate::expression_checker::check_for(
        &mut session,
        root,
        crate::expression_checker::ExpressionPurpose::Argument,
    );
    if session
        .diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
    {
        return Err(session.diagnostics);
    }
    let text_captures = capture_text(&mut session, &mut parameters)?;
    Ok(InspectionExpression {
        module: session.module,
        expression,
        parameters,
        text_captures,
    })
}

fn validate(tree: &SyntaxTree) -> Result<(), Vec<Diagnostic>> {
    if tree.has_errors || tree.node_count() == 0 || tree.node_count() > 1024 {
        return Err(rejection());
    }
    for (index, node) in tree.nodes.iter().enumerate() {
        let allowed = matches!(
            node.kind,
            NodeKind::Identifier
                | NodeKind::Literal
                | NodeKind::Unary
                | NodeKind::Addition
                | NodeKind::Multiplication
                | NodeKind::PowerExpression
                | NodeKind::Equality
                | NodeKind::Ordering
                | NodeKind::Conjunction
                | NodeKind::Disjunction
                | NodeKind::Primary
                | NodeKind::Expressions
        ) || node.kind == NodeKind::Postfix && valid_postfix(tree, index);
        if !allowed {
            return Err(rejection());
        }
    }
    validate_depth(tree)
}

fn valid_postfix(tree: &SyntaxTree, index: usize) -> bool {
    tree.operator_tokens
        .get(index)
        .copied()
        .flatten()
        .and_then(|token| usize::try_from(token).ok())
        .and_then(|token| tree.tokens.kind(token))
        .is_some_and(|kind| matches!(kind, TokenKind::Dot | TokenKind::LeftBracket))
}

fn validate_depth(tree: &SyntaxTree) -> Result<(), Vec<Diagnostic>> {
    let root = tree.node_count().checked_sub(1).ok_or_else(rejection)?;
    let mut pending = vec![(root, 1_u32)];
    while let Some((node, depth)) = pending.pop() {
        if depth > 64 {
            return Err(rejection());
        }
        pending.extend(
            tree.child_indices(node)
                .iter()
                .map(|child| (*child, depth.saturating_add(1))),
        );
    }
    Ok(())
}

fn bind_environment(
    session: &mut AnalysisSession<'_>,
    bindings: Vec<(String, TypeId)>,
) -> Result<Vec<LocalId>, Vec<Diagnostic>> {
    let mut parameters = Vec::new();
    for (name, type_id) in bindings {
        let local = bind(session, &name, type_id)?;
        session.bindings.insert(
            IdentifierNormalizer::normalize(&name),
            crate::block_scopes::BindingTarget::Local(local),
        );
        parameters.push(local);
    }
    Ok(parameters)
}

pub(super) fn bind(
    session: &mut AnalysisSession<'_>,
    name: &str,
    type_id: TypeId,
) -> Result<LocalId, Vec<Diagnostic>> {
    let local = LocalId(u32::try_from(session.module.locals.len()).map_err(|_| rejection())?);
    session.module.locals.push(HirLocal {
        name: name.to_owned(),
        type_id,
        passing: Passing::Value,
        span: Span::default(),
        scope: FunctionId(0),
        parameter: true,
        mutable: false,
    });
    session.initialized.push(true);
    Ok(local)
}

fn capture_text(
    session: &mut AnalysisSession<'_>,
    parameters: &mut Vec<LocalId>,
) -> Result<Vec<String>, Vec<Diagnostic>> {
    let mut captures = Vec::new();
    for index in 0..session.module.expressions.kinds.len() {
        let Some(crate::expression_model::HirExpression::Literal(
            crate::expression_model::Literal::String(text),
        )) = session.module.expressions.kinds.get(index).cloned()
        else {
            continue;
        };
        let kind = session.module.types.intern(Type::String);
        let name = format!("inspection_text_{}", captures.len());
        let local = bind(session, &name, kind)?;
        if let Some(expression) = session.module.expressions.kinds.get_mut(index) {
            *expression = crate::expression_model::HirExpression::Local(local);
        }
        parameters.push(local);
        captures.push(text);
    }
    Ok(captures)
}

pub(super) fn rejection() -> Vec<Diagnostic> {
    vec![Diagnostic::new(
        DiagnosticCode::ExpectedExpression,
        Span::default(),
    )]
}
