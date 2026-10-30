use serde_json::json;
use std::io::Write;
use std::process::{Command, Stdio};

fn isolated(input: &[u8]) -> Result<Vec<serde_json::Value>, String> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_conformance_adapter"))
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|error| error.to_string())?;
    child
        .stdin
        .take()
        .ok_or("Missing stdin")?
        .write_all(input)
        .map_err(|error| error.to_string())?;
    let output = child
        .wait_with_output()
        .map_err(|error| error.to_string())?;
    assert!(output.status.success(), "{:?}", output.status);
    assert!(
        output.stderr.is_empty(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    String::from_utf8(output.stdout)
        .map_err(|error| error.to_string())?
        .lines()
        .map(|line| serde_json::from_str(line).map_err(|error| error.to_string()))
        .collect()
}

#[test]
fn handles_random_unicode_and_extreme_depth_in_isolated_processes() -> Result<(), String> {
    let mut sources = vec![String::new(), " \t\r\n".to_owned(), "// trivia\n/* only */".to_owned(), "algorithm Main\ndefine e\u{301} as integer;\ne\u{301} <- 1;\nwrite e\u{301};\nendAlgorithm\n".to_owned()];
    let mut seed = 42_u64;
    let alphabet = [
        'a', '\n', '\t', 'ñ', '\u{301}', '😀', '\0', '+', '(', ')', '[', ']', '"', '/', '*', ';',
        '0', '1',
    ];
    for _ in 0..200 {
        let mut source = String::new();
        for _ in 0..1000 {
            seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1);
            let index = usize::try_from(
                seed.checked_rem(u64::try_from(alphabet.len()).unwrap_or(1))
                    .unwrap_or(0),
            )
            .unwrap_or(0);
            source.push(alphabet.get(index).copied().unwrap_or(' '));
        }
        sources.push(source);
    }
    for expression in [
        format!("{}1{}", "(".repeat(100000), ")".repeat(100000)),
        format!("{}1", "-".repeat(100000)),
        format!("1{}", "^1".repeat(100000)),
    ] {
        sources.push(format!(
            "algorithm Main\nwrite {expression};\nendAlgorithm\n"
        ));
    }
    sources.push(format!(
        "algorithm Main\n{}{}endAlgorithm\n",
        "if true then\n".repeat(10000),
        "endIf\n".repeat(10000)
    ));
    for profile in ["es", "en"] {
        for strictness in ["strict", "flexible"] {
            for source in &sources {
                let input = format!(
                    "{}\n",
                    json!({"kind": "analyze", "program": source, "profile": profile, "strictness": strictness})
                );
                let responses = isolated(input.as_bytes())?;
                assert_eq!(responses.len(), 1);
                let response = responses.first().ok_or("Missing analysis")?;
                assert_eq!(
                    response.get("tree").and_then(serde_json::Value::as_bool),
                    Some(true)
                );
                assert!(!response.to_string().contains("internalFault"));
            }
        }
    }
    Ok(())
}

#[test]
fn rejects_invalid_utf8_without_panicking() -> Result<(), String> {
    assert!(isolated(&[0xff, 0xfe, b'\n'])?.is_empty());
    Ok(())
}

#[test]
fn workspace_overlay_repairs_source_and_resolves_a_closed_import() -> Result<(), String> {
    let request = json!({
        "kind": "service",
        "suboperacion": "workspace",
        "workspace": {
            "project": {
                "project_id": "1",
                "revision_id": "1",
                "packages": [
                    {"name": "app", "root": "app", "kind": "application", "entries": ["app/main"], "dependencies": {"geo": "geo"}},
                    {"name": "geo", "root": "geo", "kind": "library", "entries": [], "dependencies": {}}
                ],
                "files": [
                    {"path": "app/main", "source_id": 1, "text": "@"},
                    {"path": "geo/vectores", "source_id": 2, "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"}
                ]
            },
            "options": {"profile": "es", "strictness": "strict"}
        },
        "actions": [
            {"operation": "open", "path": "app/main", "version": 1, "text": "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n"}
        ]
    });
    let responses = isolated(format!("{request}\n").as_bytes())?;
    assert_eq!(responses.len(), 1);
    let result = responses
        .first()
        .and_then(|response| response.get("service"))
        .ok_or("Missing workspace response")?;
    assert_eq!(result.get("diagnostics"), Some(&json!([])));
    assert_eq!(result.get("project_errors"), Some(&json!([])));
    assert_eq!(result.get("errores"), Some(&json!([])));
    assert_eq!(result.get("coincide_con_frio"), Some(&json!(true)));
    Ok(())
}
