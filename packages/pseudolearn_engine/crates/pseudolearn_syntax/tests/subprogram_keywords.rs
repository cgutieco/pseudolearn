use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_syntax::TokenKind;
use pseudolearn_syntax::subprogram_keywords::{
    closes_subprogram, opens_subprogram, subprogram_closing,
};

fn codes(program: &str, profile: Profile) -> Vec<DiagnosticCode> {
    let source = pseudolearn_source::SourceText::new(program.to_owned());
    let (_, diagnostics) = pseudolearn_syntax::parse_source(&source, profile);
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

#[test]
fn both_openings_are_subprogram_openings_with_their_own_closing() {
    let function = TokenKind::Keyword(KeywordKind::Function);
    let subroutine = TokenKind::Keyword(KeywordKind::Subroutine);
    assert!(opens_subprogram(function) && opens_subprogram(subroutine));
    assert_eq!(subprogram_closing(function), KeywordKind::EndFunction);
    assert_eq!(subprogram_closing(subroutine), KeywordKind::EndSubroutine);
    assert!(closes_subprogram(TokenKind::Keyword(
        KeywordKind::EndFunction
    )));
}

#[test]
fn other_tokens_neither_open_nor_close_a_subprogram() {
    let method = TokenKind::Keyword(KeywordKind::Method);
    assert!(!opens_subprogram(method));
    assert!(!opens_subprogram(TokenKind::Identifier));
    assert!(!closes_subprogram(TokenKind::Keyword(
        KeywordKind::EndMethod
    )));
    assert_eq!(subprogram_closing(method), KeywordKind::EndSubroutine);
}

#[test]
fn a_function_literal_and_type_close_with_their_own_word() {
    let program = "Algoritmo P\nDefinir f Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero\nRetornar x;\nFinFuncion;\nFinAlgoritmo\n";
    assert!(codes(program, Profile::Spanish).is_empty());
}

#[test]
fn a_foreign_closing_leaves_one_unclosed_subroutine_diagnostic() {
    let program = "SubProceso S()\nFinFuncion\nAlgoritmo P\nFinAlgoritmo\n";
    assert_eq!(
        codes(program, Profile::Spanish),
        vec![DiagnosticCode::UnclosedSubroutine]
    );
}

#[test]
fn the_canonical_english_closing_is_accepted() {
    let program = "Function r <- One()\nDefine r As Integer;\nr <- 1;\nEndFunction\nAlgorithm P\nEndAlgorithm\n";
    assert!(codes(program, Profile::English).is_empty());
}
