use pseudolearn_abi::EffectValueKind;
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source_with_terminator;

#[test]
fn resolves_network_and_http_types_in_both_profiles() -> Result<(), String> {
    for (profile, program) in [
        (
            Profile::Spanish,
            "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nSegun net.Enviar(request) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Incierto;\nFinSegun\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
        ),
        (
            Profile::English,
            "algorithm Main\nswitch requestNetwork() do\nsuccess(net):\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\nswitch net.send(request) do\nsuccess(response): write response.status();\nfailure(problem): write problem.uncertain;\nendSwitch\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n",
        ),
    ] {
        let source = SourceText::new(program.to_owned());
        let (tree, syntax) = parse_source_with_terminator(
            &source,
            profile,
            Some(DiagnosticCode::MissingStatementTerminator),
        );
        assert!(syntax.is_empty(), "{profile:?}: {syntax:?}");
        let (module, diagnostics) = analyze_with_options(
            &tree,
            &source,
            SemanticOptions {
                profile,
                strict: true,
            },
        );
        let module = module.ok_or_else(|| format!("{profile:?}: {diagnostics:?}"))?;
        assert!(diagnostics.is_empty(), "{profile:?}: {diagnostics:?}");
        assert!(module.builtin_enums.contains_key("httpMethod"));
        for kind in [
            EffectValueKind::Network,
            EffectValueKind::HttpRequest,
            EffectValueKind::HttpResponse,
        ] {
            assert!(module.opaque_types.values().any(|found| *found == kind));
        }
    }
    Ok(())
}

#[test]
fn awaits_http_effect_with_transferable_values_in_both_profiles() -> Result<(), String> {
    for (profile, program) in [
        (
            Profile::Spanish,
            "SubProceso Suspendible Fetch(net Como RedCap, request Como PeticionHttp) Como Resultado<RespuestaHttp, ErrorES>\nRetornar Aguardar net.Enviar(request);\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nTareas failureReport\nDefinir child Como Tarea<RespuestaHttp> <- Lanzar Fetch(net, request);\nDefinir response Como RespuestaHttp <- Aguardar child;\nEscribir response.Estado();\nFinTareas\nDescartar failureReport;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
        ),
        (
            Profile::English,
            "subroutine suspendable Fetch(net as NetworkCap, request as HttpRequest) as result<HttpResponse, IoError>\nreturn await net.send(request);\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\ntasks failureReport\ndefine child as task<HttpResponse> <- spawn Fetch(net, request);\ndefine response as HttpResponse <- await child;\nwrite response.status();\nendTasks\ndiscard failureReport;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n",
        ),
    ] {
        let source = SourceText::new(program.to_owned());
        let (tree, syntax) = parse_source_with_terminator(
            &source,
            profile,
            Some(DiagnosticCode::MissingStatementTerminator),
        );
        assert!(syntax.is_empty(), "{profile:?}: {syntax:?}");
        let (module, diagnostics) = analyze_with_options(
            &tree,
            &source,
            SemanticOptions {
                profile,
                strict: true,
            },
        );
        assert!(module.is_some(), "{profile:?}: {diagnostics:?}");
        assert!(diagnostics.is_empty(), "{profile:?}: {diagnostics:?}");
    }
    Ok(())
}

#[test]
fn analyzes_every_http_corpus_program_in_both_profiles() -> Result<(), String> {
    let corpus = include_str!("../../../../pseudolearn_spec/specifications/lib/lib.http.md");
    for block in corpus.split("```caso\n").skip(1) {
        let body = block.split("\n```").next().ok_or("missing case body")?;
        let case: serde_json::Value =
            serde_json::from_str(body).map_err(|error| error.to_string())?;
        let case_id = case
            .get("id")
            .and_then(serde_json::Value::as_str)
            .unwrap_or("?");
        for (name, profile) in [("es", Profile::Spanish), ("en", Profile::English)] {
            let program = case
                .pointer(&format!("/programas/{name}"))
                .and_then(serde_json::Value::as_str)
                .ok_or("missing HTTP program")?;
            let source = SourceText::new(program.to_owned());
            let (tree, syntax) = parse_source_with_terminator(
                &source,
                profile,
                Some(DiagnosticCode::MissingStatementTerminator),
            );
            assert!(syntax.is_empty(), "{case_id} {name}: {syntax:?}");
            let (module, diagnostics) = analyze_with_options(
                &tree,
                &source,
                SemanticOptions {
                    profile,
                    strict: true,
                },
            );
            let errors = diagnostics
                .iter()
                .filter(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
                .collect::<Vec<_>>();
            assert!(module.is_some(), "{case_id} {name}: {errors:?}");
            assert!(errors.is_empty(), "{case_id} {name}: {errors:?}");
        }
    }
    Ok(())
}
