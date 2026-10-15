#![forbid(unsafe_code)]

mod compound_scanner;
pub(crate) mod control_statement_parser;
pub(crate) mod declaration_parser;
pub(crate) mod expression_parser;
pub mod lexer;
pub(crate) mod literal_scanner;
pub(crate) mod operator_scanner;
pub(crate) mod parameter_parser;
pub mod parser;
pub(crate) mod parser_state;
pub(crate) mod postfix_parser;
pub mod reprint;
pub mod schema;
pub(crate) mod statement_parser;
pub(crate) mod switch_parser;
pub mod tokens;
pub mod tree;
pub(crate) mod unit_parser;
pub(crate) mod unsupported;

pub use lexer::Lexer;
pub use literal_scanner::{ScannedLiteral, scan_literal};
pub use parser::Parser;
pub use reprint::reprint_lossless;
pub use schema::{ModuleSchema, ParameterSignature, UnitDeclaration, UnitKind};
pub use tokens::{TokenKind, Tokens};
pub use tree::{NodeKind, SyntaxNode, SyntaxTree};

use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

pub fn parse_source(source: &SourceText, profile: Profile) -> (SyntaxTree, Vec<Diagnostic>) {
    parse_source_with_terminator(source, profile, None)
}

pub fn parse_source_with_terminator(
    source: &SourceText,
    profile: Profile,
    terminator: Option<pseudolearn_diagnostics::DiagnosticCode>,
) -> (SyntaxTree, Vec<Diagnostic>) {
    let lexer = Lexer::new(source, profile);
    let (tokens, mut diagnostics) = lexer.scan();
    let parser = Parser::new(&tokens, source.as_str()).with_terminator(terminator);
    let (mut tree, mut parser_diagnostics) = parser.parse();
    diagnostics.append(&mut parser_diagnostics);
    tree.has_errors = !diagnostics.is_empty();
    (tree, diagnostics)
}
