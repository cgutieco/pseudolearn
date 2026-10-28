use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

#[test]
fn channel_operations_produce_boolean_and_optional_element_types() {
    let diagnostics = analyze(
        "Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nDefinir accepted Como Logico <- Aguardar queue.Enviar(8);\nDefinir received Como Opcional<Entero> <- Aguardar queue.Recibir();\nqueue.Cerrar();\nEscribir accepted;\nSegun received Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinAlgoritmo\n",
    );
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn channel_rejects_mutable_elements_and_unawaited_receive() {
    assert!(
        analyze(
            "Algoritmo Main\nDefinir queue Como Canal<Vector<Entero>> <- Canal(2);\nFinAlgoritmo\n"
        )
        .contains(&DiagnosticCode::ChannelElementNotTransferable)
    );
    assert!(analyze("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nDescartar queue.Recibir();\nFinAlgoritmo\n").contains(&DiagnosticCode::ChannelOperationWithoutAwait));
}

#[test]
fn channel_rejects_zero_capacity_before_execution() {
    assert!(
        analyze("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(0);\nFinAlgoritmo\n")
            .contains(&DiagnosticCode::ChannelCapacityInvalid)
    );
}

pub(super) fn analyze(program: &str) -> Vec<DiagnosticCode> {
    let source = SourceText::new(program.to_owned());
    let (tree, syntax) = pseudolearn_syntax::parse_source(&source, Profile::Spanish);
    assert!(syntax.is_empty(), "{syntax:?}");
    let (_, diagnostics) = crate::analyze_with_options(
        &tree,
        &source,
        crate::SemanticOptions {
            profile: Profile::Spanish,
            strict: true,
        },
    );
    diagnostics
        .into_iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

#[test]
fn channel_rejects_negative_constant_expressions_and_comparison() {
    assert!(analyze("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2 - 3);\nqueue.Cerrar();\nFinAlgoritmo\n").contains(&DiagnosticCode::ChannelCapacityInvalid));
    assert!(analyze("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nEscribir queue = queue;\nFinAlgoritmo\n").contains(&DiagnosticCode::IncompatibleOperandTypes));
}
