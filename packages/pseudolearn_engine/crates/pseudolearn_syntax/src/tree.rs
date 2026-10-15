use crate::tokens::Tokens;
use pseudolearn_source::Span;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum NodeKind {
    ProgramUnit,
    ProcedureUnit,
    FunctionUnit,
    ClassUnit,

    VariableDeclaration,
    DimensionDeclaration,
    FieldDeclaration,
    MethodDeclaration,
    ConstructorDeclaration,

    AssignmentStatement,
    IfStatement,
    WhileStatement,
    RepeatStatement,
    ForStatement,
    SwitchStatement,
    CaseClause,
    OtherwiseClause,
    ReturnStatement,
    CallStatement,
    ReadStatement,
    WriteStatement,
    Block,

    BinaryExpression,
    UnaryExpression,
    LiteralExpression,
    IdentifierExpression,
    IndexingExpression,
    MemberAccessExpression,
    CallExpression,
    NewInstanceExpression,
    ThisExpression,
    SuperExpression,

    ErrorNode,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct SyntaxNode {
    pub kind: NodeKind,
    pub first_token: u32,
    pub subtree_size: u32,
}

impl SyntaxNode {
    pub const fn new(kind: NodeKind, first_token: u32, subtree_size: u32) -> Self {
        Self {
            kind,
            first_token,
            subtree_size,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SyntaxTree {
    pub nodes: Vec<SyntaxNode>,
    pub tokens: Tokens,
}

impl SyntaxTree {
    pub fn new(nodes: Vec<SyntaxNode>, tokens: Tokens) -> Self {
        Self { nodes, tokens }
    }

    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }

    pub fn node(&self, index: usize) -> Option<&SyntaxNode> {
        self.nodes.get(index)
    }

    pub fn span_for_node(&self, node_index: usize) -> Option<Span> {
        let node = self.nodes.get(node_index)?;
        let start_token = usize::try_from(node.first_token).ok()?;
        let start_span = self.tokens.span(start_token)?;
        let mut ending_span = start_span;
        let mut candidate_token = start_token;
        while let Some(current_span) = self.tokens.span(candidate_token) {
            ending_span = current_span;
            candidate_token = candidate_token.saturating_add(1);
            if candidate_token >= self.tokens.token_count() {
                break;
            }
        }
        Some(Span::new(start_span.start, ending_span.ending))
    }
}
