use pseudolearn_api::{AnalyzeRequest, ExecuteRequest, execute_analyze, execute_program};

#[test]
fn analyzes_valid_program() {
    let request = AnalyzeRequest {
        program: "Algoritmo Test\n  Definir a Como Entero <- 1;\n  Escribir a;\nFinAlgoritmo\n"
            .to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    };
    let response = execute_analyze(&request);
    assert_eq!(response.kind, "analyze");
    assert!(response.tree);
    assert_eq!(response.diagnostics, Vec::new());
}

#[test]
fn analyzes_original_unicode_identifiers_in_every_profile_and_strictness() -> Result<(), String> {
    for (profile, program, declaration_column) in [
        (
            "es",
            "Algoritmo P\nDefinir Mutable año Como Entero <- 0;\nan\u{0303}o <- 5;\nEscribir año;\nFinAlgoritmo\n",
            17,
        ),
        (
            "en",
            "algorithm P\ndefine mutable año as integer <- 0;\nan\u{0303}o <- 5;\nwrite año;\nendAlgorithm\n",
            16,
        ),
    ] {
        for strictness in ["strict", "flexible"] {
            let response = execute_analyze(&AnalyzeRequest {
                program: program.to_owned(),
                profile: profile.to_owned(),
                strictness: strictness.to_owned(),
                source: None,
            });
            assert!(
                response.diagnostics.is_empty(),
                "{profile}/{strictness}: {:?}",
                response.diagnostics
            );
            let identifier_spans: Vec<_> = response
                .tokens
                .iter()
                .filter(|token| token.kind == "identifier")
                .map(|token| (&token.span.start, &token.span.end))
                .collect();
            assert!(identifier_spans.iter().any(|(start, end)| {
                start.line == 2
                    && start.column == declaration_column
                    && end.line == 2
                    && end.column == declaration_column + 3
            }));
            assert!(identifier_spans.iter().any(|(start, end)| {
                start.line == 3 && start.column == 1 && end.line == 3 && end.column == 5
            }));
        }
    }
    Ok(())
}

#[test]
fn empty_single_file_analysis_keeps_the_algorithm_start_diagnostic() {
    let response = execute_analyze(&AnalyzeRequest {
        program: String::new(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    });
    assert_eq!(
        response
            .diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code.as_str())
            .collect::<Vec<_>>(),
        ["expectedAlgorithmStart"]
    );
}

#[test]
fn loose_module_directive_names_execute_as_identifiers() {
    for (profile, program) in [
        (
            "es",
            "Algoritmo P\nDefinir Importar Como Entero <- 1;\nDefinir Exportar Como Entero <- 2;\nDefinir import Como Entero <- 3;\nDefinir export Como Entero <- 4;\nEscribir Importar, Exportar, import, export;\nFinAlgoritmo\n",
        ),
        (
            "en",
            "algorithm P\ndefine Importar as integer <- 1;\ndefine Exportar as integer <- 2;\ndefine import as integer <- 3;\ndefine export as integer <- 4;\nwrite Importar, Exportar, import, export;\nendAlgorithm\n",
        ),
    ] {
        for strictness in ["strict", "flexible"] {
            let response = execute_program(&ExecuteRequest {
                program: program.to_owned(),
                profile: profile.to_owned(),
                strictness: strictness.to_owned(),
                ..ExecuteRequest::default()
            });
            assert_eq!(response.output, "1234\n");
            assert!(response.diagnostics.is_empty());
        }
    }
}

#[test]
fn reports_diagnostics_for_invalid_program() {
    let request = AnalyzeRequest {
        program: "Algoritmo Test\n  a <- 1;\nFinAlgoritmo\n".to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        source: None,
    };
    let response = execute_analyze(&request);
    assert_eq!(response.kind, "analyze");
    assert!(response.tree);
    assert!(!response.diagnostics.is_empty());
}
