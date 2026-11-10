use pseudolearn_service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///tokens.pseudo";

fn tokens_for(text: &str) -> Vec<u64> {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc":"2.0","id":1,"method":"initialize",
        "params":{"locale":"en","capabilities":{"textDocument":{"semanticTokens":{"requests":{"full":true}}}}}
    }));
    server.handle_message(&json!({
        "jsonrpc":"2.0","method":"textDocument/didOpen",
        "params":{"textDocument":{"uri":URI,"languageId":"pseudolearn","version":1,"text":text}}
    }));
    let answer = server.handle_message(&json!({
        "jsonrpc":"2.0","id":2,"method":"textDocument/semanticTokens/full",
        "params":{"textDocument":{"uri":URI}}
    }));
    answer
        .first()
        .and_then(|response| response.pointer("/result/data"))
        .and_then(Value::as_array)
        .map(|token_words| token_words.iter().filter_map(Value::as_u64).collect())
        .unwrap_or_default()
}

fn token_types(token_words: &[u64]) -> Vec<u64> {
    token_words
        .chunks(5)
        .filter_map(|chunk| chunk.get(3).copied())
        .collect()
}

#[test]
fn parameters_are_typed_as_parameters_even_when_a_function_shares_their_identifier() {
    let text = "SubProceso Show(count Como Entero)\nEscribir count;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let types = token_types(&tokens_for(text));
    assert_eq!(
        types.iter().filter(|kind| **kind == 9).count(),
        2,
        "{types:?}"
    );
}

#[test]
fn local_variables_stay_variables_and_functions_stay_functions() {
    let text = "SubProceso Show()\nFinSubProceso\nAlgoritmo Main\nDefinir total Como Entero <- 0;\nEscribir total;\nFinAlgoritmo\n";
    let types = token_types(&tokens_for(text));
    assert!(types.contains(&6), "{types:?}");
    assert_eq!(
        types.iter().filter(|kind| **kind == 5).count(),
        2,
        "{types:?}"
    );
    assert!(!types.contains(&9));
}

#[test]
fn encoded_positions_are_relative_and_span_many_lines() {
    let text =
        "Algoritmo Main\nDefinir a Como Entero <- 1;\nDefinir b Como Entero <- 2;\nFinAlgoritmo\n";
    let token_words = tokens_for(text);
    assert_eq!(token_words.len() % 5, 0);
    assert_eq!(token_words.get(..3), Some(&[0, 0, 9][..]));
    let line_deltas: u64 = token_words
        .chunks(5)
        .filter_map(|chunk| chunk.first())
        .sum();
    assert_eq!(line_deltas, 3);
}

#[test]
fn empty_documents_yield_no_tokens() {
    assert!(tokens_for("").is_empty());
}

fn comment_tokens(token_words: &[u64]) -> Vec<[u64; 3]> {
    token_words
        .chunks(5)
        .filter(|chunk| chunk.get(3) == Some(&4))
        .filter_map(|chunk| Some([*chunk.first()?, *chunk.get(1)?, *chunk.get(2)?]))
        .collect()
}

fn lines_in_utf16(text: &str) -> Vec<u64> {
    text.split('\n')
        .map(|line| line.trim_end_matches('\r'))
        .map(|line| u64::try_from(line.encode_utf16().count()).unwrap_or(u64::MAX))
        .collect()
}

#[test]
fn a_block_comment_is_split_into_one_token_per_line() {
    let token_words = tokens_for("/* a\nbb\nccc */\nAlgoritmo Main\nFinAlgoritmo\n");
    assert_eq!(
        comment_tokens(&token_words),
        [[0, 0, 4], [1, 0, 2], [1, 0, 6]]
    );
}

#[test]
fn split_comments_skip_empty_lines_and_crlf_terminators() {
    let token_words = tokens_for("/* a\r\n\r\nb */\r\nAlgoritmo Main\r\nFinAlgoritmo\r\n");
    assert_eq!(comment_tokens(&token_words), [[0, 0, 4], [2, 0, 4]]);
}

#[test]
fn split_comment_lengths_count_utf16_units() {
    let token_words = tokens_for("/* 😀\n😀 */\nAlgoritmo Main\nFinAlgoritmo\n");
    assert_eq!(comment_tokens(&token_words), [[0, 0, 5], [1, 0, 5]]);
}

#[test]
fn no_encoded_token_crosses_the_end_of_its_line() {
    let text = "// header\n/* first\n   second */ Algoritmo Main\nDefinir total Como Entero <- 1; /* x\ny */\nEscribir \"a😀\", total;\nFinAlgoritmo\n";
    let lines = lines_in_utf16(text);
    let (mut line, mut character) = (0_u64, 0_u64);
    for chunk in tokens_for(text).chunks(5) {
        let [line_delta, character_delta, length, ..] = chunk else {
            continue;
        };
        character = if *line_delta == 0 {
            character + character_delta
        } else {
            *character_delta
        };
        line += line_delta;
        let width = usize::try_from(line)
            .ok()
            .and_then(|index| lines.get(index))
            .copied()
            .unwrap_or(0);
        assert!(
            *length > 0 && character + length <= width,
            "{chunk:?} at {line}"
        );
    }
}
