use super::channel_types_tests::analyze;
use pseudolearn_diagnostics::DiagnosticCode;

#[test]
fn select_accepts_same_channel_and_creates_branch_local_optional_bindings() {
    let diagnostics = analyze(
        "Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nElegir\nRecibir first Desde queue:\nSegun first Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nRecibir second Desde queue:\nSegun second Hacer\nNada: Escribir 0;\nAlgo(other): Escribir other;\nFinSegun\nFinElegir\nFinAlgoritmo\n",
    );
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
}

#[test]
fn select_rejects_a_single_branch() {
    assert!(analyze("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nElegir\nRecibir first Desde queue:\nSegun first Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinElegir\nFinAlgoritmo\n").contains(&DiagnosticCode::SelectNeedsTwoBranches));
}

#[test]
fn select_binding_cannot_escape_its_branch() {
    assert!(analyze("Algoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(2);\nElegir\nRecibir first Desde queue:\nSegun first Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nRecibir second Desde queue:\nSegun first Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinElegir\nFinAlgoritmo\n").contains(&DiagnosticCode::BindingOutsideScope));
}
