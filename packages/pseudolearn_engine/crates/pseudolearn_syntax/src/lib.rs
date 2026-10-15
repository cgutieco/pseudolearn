pub(crate) mod control_statement_parser;
pub(crate) mod expression_parser;
pub mod lexer;
pub(crate) mod literal_scanner;
pub(crate) mod operator_scanner;
pub mod parser;
pub(crate) mod parser_state;
pub mod reprint;
pub mod schema;
pub(crate) mod statement_parser;
pub mod tokens;
pub mod tree;

pub use lexer::Lexer;
pub use parser::Parser;
pub use reprint::reprint_lossless;
pub use schema::{ModuleSchema, ParameterSignature, UnitDeclaration, UnitKind};
pub use tokens::{TokenKind, Tokens};
pub use tree::{NodeKind, SyntaxNode, SyntaxTree};

use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

pub fn parse_source(source: &SourceText, profile: Profile) -> (SyntaxTree, Vec<Diagnostic>) {
    let lexer = Lexer::new(source, profile);
    let (tokens, mut diagnostics) = lexer.scan();
    let parser = Parser::new(&tokens);
    let (tree, mut parser_diagnostics) = parser.parse();
    diagnostics.append(&mut parser_diagnostics);
    (tree, diagnostics)
}
