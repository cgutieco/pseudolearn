use pseudolearn_abi::EffectValueKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source_with_terminator;

#[test]
fn json_values_and_errors_are_typed_and_transferable_in_both_profiles() -> Result<(), String> {
    let programs = [
        (
            Profile::Spanish,
            "Registro JsonInfo\nDefinir valueData Como ValorJson;\nDefinir kindData Como TipoJson;\nDefinir errorData Como ErrorJson;\nDefinir codeData Como CodigoErrorJson;\nFinRegistro\nSubProceso Suspendible Child(value Como ValorJson) Como Cadena\nRetornar TextoJson(value);\nFinSubProceso\nAlgoritmo Main\nDefinir value Como ValorJson <- JsonCadena(\"ok\");\nTareas\nDefinir child Como Tarea<Cadena> <- Lanzar Child(value);\nEscribir Aguardar child;\nFinTareas\nFinAlgoritmo\n",
        ),
        (
            Profile::English,
            "record JsonInfo\ndefine valueData as JsonValue;\ndefine kindData as JsonKind;\ndefine errorData as JsonError;\ndefine codeData as JsonErrorCode;\nendRecord\nsubroutine suspendable Child(value as JsonValue) as string\nreturn jsonText(value);\nendSubroutine\nalgorithm Main\ndefine value as JsonValue <- jsonString(\"ok\");\ntasks\ndefine child as task<string> <- spawn Child(value);\nwrite await child;\nendTasks\nendAlgorithm\n",
        ),
    ];
    for (profile, program) in programs {
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
        assert!(
            module
                .opaque_types
                .values()
                .any(|kind| *kind == EffectValueKind::JsonValue)
        );
        assert!(module.builtin_enums.contains_key("jsonKind"));
        assert!(module.builtin_enums.contains_key("jsonErrorCode"));
    }
    Ok(())
}
