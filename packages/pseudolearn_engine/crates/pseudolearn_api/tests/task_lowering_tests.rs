use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

#[test]
fn verifies_channel_suspension_edges() -> Result<(), Box<dyn std::error::Error>> {
    let source = SourceText::new("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nDefinir sent Como Logico <- Aguardar queue.Enviar(81);\nEscribir sent;\nFinAlgoritmo\n".to_owned());
    let (tree, syntax) = pseudolearn_syntax::parse_source(&source, Profile::Spanish);
    assert!(syntax.is_empty(), "{syntax:?}");
    let (module, diagnostics) = pseudolearn_semantic::analyze_with_options(
        &tree,
        &source,
        pseudolearn_semantic::SemanticOptions {
            profile: Profile::Spanish,
            strict: true,
        },
    );
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let module =
        pseudolearn_lowering::lower_module(module.as_ref().ok_or("analysis failed")?, &source);
    assert!(module.is_ok(), "{module:?}");
    if let Ok(module) = module {
        let verified = pseudolearn_ir::verify_module(&module);
        assert!(verified.is_ok(), "{verified:?}\n{module:#?}");
        let bytecode = pseudolearn_bytecode::compile_module(&module);
        assert!(bytecode.is_ok(), "{bytecode:?}");
    }
    Ok(())
}
