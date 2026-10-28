use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::json;

fn check(program: &str, expected: &str) {
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
    assert_eq!(response.output, expected);
}

#[test]
fn cyclic_snapshots_survive_channel_transport() {
    check(
        "Registro Node\nDefinir children Como Vector<Node>;\nFinRegistro\nAlgoritmo Main\nDefinir children Como Vector<Node> <- Vector();\nchildren.Agregar(Node(children));\nDefinir frozen Como Inmutable<Vector<Node>> <- Instantanea(children);\nDefinir queue Como Canal<Inmutable<Vector<Node>>> <- Canal(1);\nDefinir accepted Como Logico <- Aguardar queue.Enviar(frozen);\nchildren.Eliminar(0);\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value[0].children.Longitud();\nFinSegun\nFinAlgoritmo\n",
        "1\n",
    );
}

#[test]
fn closure_environments_remain_live_across_suspension() {
    check(
        "SubProceso Suspendible Work(queue Como Canal<Entero>)\nDefinir text Como Cadena <- \"kept\";\nDefinir render Como Funcion() Como Cadena <- Funcion() Como Cadena\nRetornar text;\nFinFuncion;\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir render();\nAlgo(value): Escribir render(), value;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Close(queue Como Canal<Entero>)\nqueue.Cerrar();\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Work(queue);\nLanzar Close(queue);\nFinTareas\nFinAlgoritmo\n",
        "kept\n",
    );
}

#[test]
fn one_hundred_suspended_reference_frames_resume_in_fifo_order() {
    let mut program = "SubProceso Suspendible Work(queue Como Canal<Entero>)\nDefinir text Como Cadena <- \"kept\";\nSegun Aguardar queue.Recibir() Hacer\nNada: Escribir text;\nAlgo(value): Escribir text, value;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Close(queue Como Canal<Entero>)\nqueue.Cerrar();\nFinSubProceso\nAlgoritmo Main\nDefinir queue Como Canal<Entero> <- Canal(1);\nTareas\n".to_owned();
    program.push_str(&"Lanzar Work(queue);\n".repeat(100));
    program.push_str("Lanzar Close(queue);\nFinTareas\nFinAlgoritmo\n");
    check(&program, &"kept\n".repeat(100));
}
