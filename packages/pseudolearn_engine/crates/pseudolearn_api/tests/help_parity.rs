use pseudolearn_api::ApiSession;
use pseudolearn_api::service::LspServer;
use serde_json::{Value, json};

const URI: &str = "file:///paridad.pseudo";

struct Case {
    program: &'static str,
    line: u32,
    lsp_line: u32,
    scalar_column: u32,
    utf16_character: u32,
}

const CASES: [Case; 3] = [
    Case {
        program: "Algoritmo P\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n",
        line: 2,
        lsp_line: 1,
        scalar_column: 5,
        utf16_character: 4,
    },
    Case {
        program: "Algoritmo P\nEscribir \"🧩\"; Longitud(\"x\");\nFinAlgoritmo\n",
        line: 2,
        lsp_line: 1,
        scalar_column: 18,
        utf16_character: 19,
    },
    Case {
        program: "Algoritmo P\r\nPara i <- 1 Hasta 2 Con Paso 1 Hacer\r\nFinPara\r\nFinAlgoritmo\r\n",
        line: 2,
        lsp_line: 1,
        scalar_column: 27,
        utf16_character: 26,
    },
];

fn api_answer(case: &Case, language: &str) -> Result<Value, String> {
    let mut session = ApiSession::default();
    let opened = session.call(
        "open_edit_session",
        &json!({"program": case.program, "profile": "es", "strictness": "strict"}),
    );
    let resource = opened
        .pointer("/value/resource")
        .and_then(Value::as_u64)
        .ok_or("missing resource")?;
    Ok(session.call(
        "help_query",
        &json!({
            "resource": resource, "revision": "1",
            "position": {"line": case.line, "column": case.scalar_column, "unit": "unicode_scalar"},
            "language": language, "detail": "full"
        }),
    ))
}

fn lsp_answer(case: &Case, locale: &str) -> Value {
    let mut server = LspServer::new();
    server.handle_message(&json!({
        "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"locale": locale}
    }));
    server.handle_message(&json!({
        "jsonrpc": "2.0", "method": "textDocument/didOpen",
        "params": {"textDocument": {"uri": URI, "languageId": "pseudolearn", "version": 1, "text": case.program}}
    }));
    server
        .handle_message(&json!({
            "jsonrpc": "2.0", "id": 2, "method": "textDocument/hover",
            "params": {"textDocument": {"uri": URI},
                "position": {"line": case.lsp_line, "character": case.utf16_character}}
        }))
        .into_iter()
        .next()
        .unwrap_or(Value::Null)
}

fn utf16_range(program: &str, range: &Value) -> Result<Value, String> {
    let point = |name: &str| -> Result<(u64, u64), String> {
        let line = range
            .pointer(&format!("/{name}/line"))
            .and_then(Value::as_u64)
            .ok_or("missing line")?;
        let column = range
            .pointer(&format!("/{name}/column"))
            .and_then(Value::as_u64)
            .ok_or("missing column")?;
        let text = program
            .split('\n')
            .nth(usize::try_from(line.saturating_sub(1)).map_err(|error| error.to_string())?)
            .ok_or("line out of range")?;
        let skipped =
            usize::try_from(column.saturating_sub(1)).map_err(|error| error.to_string())?;
        let units: u64 = text
            .chars()
            .take(skipped)
            .map(|glyph| u64::try_from(glyph.len_utf16()).unwrap_or(0))
            .sum();
        Ok((line.saturating_sub(1), units))
    };
    let (start_line, start_character) = point("start")?;
    let (end_line, end_character) = point("end")?;
    Ok(json!({
        "start": {"line": start_line, "character": start_character},
        "end": {"line": end_line, "character": end_character}
    }))
}

fn escape(text: &str) -> String {
    text.chars()
        .flat_map(|glyph| {
            if "\\`*_{}[]()#+-.!|<>~&:/@".contains(glyph) {
                vec!['\\', glyph]
            } else {
                vec![glyph]
            }
        })
        .collect()
}

#[test]
fn api_and_lsp_describe_the_same_card_and_range() -> Result<(), String> {
    for case in &CASES {
        for language in ["es", "en"] {
            let api = api_answer(case, language)?;
            let lsp = lsp_answer(case, language);
            let title = api
                .pointer("/value/card/title")
                .and_then(Value::as_str)
                .ok_or("API gave no card")?;
            let summary = api
                .pointer("/value/card/summary")
                .and_then(Value::as_str)
                .ok_or("API gave no summary")?;
            let text = lsp
                .pointer("/result/contents/value")
                .and_then(Value::as_str)
                .ok_or("LSP gave no hover")?;
            assert!(text.contains(&escape(title)), "{language}: {title}");
            assert!(text.contains(&escape(summary)), "{language}: {summary}");
            let range = api
                .pointer("/value/resolution/lexical_range")
                .ok_or("API gave no range")?;
            assert_eq!(
                lsp.pointer("/result/range"),
                Some(&utf16_range(case.program, range)?)
            );
        }
    }
    Ok(())
}

#[test]
fn languages_differ_but_identity_and_range_do_not() -> Result<(), String> {
    for case in &CASES {
        let spanish = api_answer(case, "es")?;
        let english = api_answer(case, "en")?;
        assert_ne!(
            spanish.pointer("/value/card/title"),
            english.pointer("/value/card/title")
        );
        for path in ["/value/resolution", "/value/card/id"] {
            assert_eq!(spanish.pointer(path), english.pointer(path), "{path}");
        }
    }
    Ok(())
}
