use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

fn execute(body: &str) -> pseudolearn_api::ExecuteResponse {
    execute_program(&ExecuteRequest {
        program: format!("Algoritmo Main\n{body}FinAlgoritmo\n"),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    })
}

#[test]
fn snapshots_copy_vectors_and_keep_the_original_independent() {
    let response = execute(
        "Definir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nvalues[0] <- 9;\nEscribir frozen[0];\nEscribir values[0];\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "7\n9\n");
}

#[test]
fn empty_snapshots_are_readable_without_elements() {
    let response = execute(
        "Definir values Como Vector<Entero> <- Vector();\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nEscribir frozen.Longitud();\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "0\n");
}

#[test]
fn rejects_writes_and_mutating_methods_through_snapshots() {
    for operation in ["frozen[0] <- 9;", "frozen.Agregar(9);", "Leer frozen[0];"] {
        let response = execute(&format!(
            "Definir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\n{operation}\n"
        ));
        assert!(
            format!("{:?}", response.diagnostics).contains("immutableValueWrite"),
            "{response:?}"
        );
    }
}

#[test]
fn rejects_mutation_through_a_borrowed_snapshot_element() {
    let program = "SubProceso Mutate(value Como Entero Por Referencia)\nvalue <- 9;\nFinSubProceso\nAlgoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nMutate(frozen[0]);\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert!(
        format!("{:?}", response.diagnostics).contains("immutableValueWrite"),
        "{response:?}"
    );
}

#[test]
fn snapshots_of_snapshots_keep_the_same_type() {
    let response = execute(
        "Definir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nDefinir again Como Inmutable<Vector<Entero>> <- Instantanea(frozen);\nEscribir again[0];\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "7\n");
}

#[test]
fn immutable_text_supports_length_and_equality_queries() {
    let response = execute(
        "Definir frozen Como Inmutable<Cadena> <- Instantanea(\"abc\");\nEscribir Longitud(frozen);\nEscribir frozen = Instantanea(\"abc\");\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "3\nVerdadero\n");
}

#[test]
fn snapshots_share_channel_identity() {
    let response = execute(
        "Definir stream Como Canal<Entero> <- Canal(1);\nDefinir frozen Como Inmutable<Canal<Entero>> <- Instantanea(stream);\nfrozen.Cerrar();\nSegun Aguardar stream.Recibir() Hacer\nNada: Escribir 1;\nAlgo(value): Escribir value;\nFinSegun\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "1\n");
}

#[test]
fn failure_reports_do_not_expose_mutable_associated_errors() {
    let program = "SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo Main\nTareas failureReport\nLanzar Fail();\nFinTareas\nSegun failureReport Hacer\nNada: Escribir 0;\nAlgo(problem): problem.Asociados.Agregar(\"extra\");\nFinSegun\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert!(
        format!("{:?}", response.diagnostics).contains("immutableValueWrite"),
        "{response:?}"
    );
}

#[test]
fn mutable_containers_can_replace_whole_immutable_values() {
    let response = execute(
        "Definir values Como Vector<Inmutable<Entero>> <- Vector();\nvalues.Agregar(Instantanea(7));\nvalues[0] <- Instantanea(9);\nEscribir values[0];\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "9\n");
}

#[test]
fn immutable_records_flatten_all_fields_inside_collections() {
    let program = "Registro Pair\nDefinir first Como Entero;\nDefinir second Como Entero;\nFinRegistro\nAlgoritmo Main\nDefinir pair Como Pair <- Pair(7, 9);\nDefinir frozen Como Inmutable<Pair> <- Instantanea(pair);\nDefinir values Como Vector<Inmutable<Pair>> <- Vector();\nvalues.Agregar(frozen);\nEscribir values[0].first;\nEscribir values[0].second;\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "7\n9\n");
}

#[test]
fn generic_units_infer_payloads_of_immutable_parameters() {
    let program = "SubProceso Work<T>(value Como Inmutable<T>)\nFinSubProceso\nAlgoritmo Main\nDefinir frozen Como Inmutable<Entero> <- Instantanea(7);\nWork(frozen);\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
}

#[test]
fn array_snapshots_allow_direct_index_reads() {
    let response = execute(
        "Dimension values[2] Como Entero;\nvalues[0] <- 7;\nEscribir Instantanea(values)[0];\n",
    );
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "7\n");
}

#[test]
fn generic_tasks_transfer_immutable_arguments_and_return_them() {
    let program = "SubProceso Suspendible Echo<T>(value Como Inmutable<T>) Como Inmutable<T>\nRetornar value;\nFinSubProceso\nAlgoritmo Main\nDefinir frozen Como Inmutable<Entero> <- Instantanea(7);\nTareas\nDefinir handle Como Tarea<Inmutable<Entero>> <- Lanzar Echo(frozen);\nDefinir received Como Inmutable<Entero> <- Aguardar handle;\nEscribir received;\nFinTareas\nFinAlgoritmo\n";
    let response = execute_program(&ExecuteRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        ..Default::default()
    });
    assert_eq!(
        response.termination.get("kind"),
        Some(&json!("completed")),
        "{response:?}"
    );
    assert_eq!(response.output, "7\n");
}
