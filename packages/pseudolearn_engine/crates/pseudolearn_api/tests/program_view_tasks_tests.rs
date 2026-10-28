use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const SPANISH: &str = "SubProceso Suspendible Work(stream Como Canal<Entero>) Como Resultado<Entero, Cadena>\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nRetornar Exito(1);\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(Vector());\nTareas problem\nDefinir job Como Tarea<Entero> <- Lanzar Work(stream);\nLanzar Work(stream);\nFinTareas\nDescartar problem;\nElegir\nRecibir first Desde stream:\nEscribir 1;\nRecibir second Desde stream:\nEscribir 2;\nFinElegir\nFinAlgoritmo\n";
const ENGLISH: &str = "subroutine suspendable Work(stream as channel<integer>) as result<integer, string>\nswitch await stream.receive() do\nsome(value): write value;\nnone: write 0;\nendSwitch\nreturn success(1);\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ndefine frozen as immutable<vector<integer>> <- snapshot(vector());\ntasks problem\ndefine job as task<integer> <- spawn Work(stream);\nspawn Work(stream);\nendTasks\ndiscard problem;\nselect\nreceive first from stream:\nwrite 1;\nreceive second from stream:\nwrite 2;\nendSelect\nendAlgorithm\n";

fn nodes_of(program: &str, profile: &str) -> Result<Vec<Value>, String> {
    let mut session = ApiSession::default();
    let document = session
        .call(
            "create_document",
            &json!({"program": program, "profile": profile}),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or("missing document")?;
    session
        .call("program_view", &json!({"resource": document}))
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing nodes".to_owned())
}

fn texts(nodes: &[Value], field: &str) -> Vec<String> {
    nodes
        .iter()
        .filter_map(|node| node.get(field).and_then(Value::as_str).map(str::to_owned))
        .collect()
}

#[test]
fn every_task_construct_is_projected_as_an_explicit_node_in_both_profiles() -> Result<(), String> {
    for (program, profile) in [(SPANISH, "es"), (ENGLISH, "en")] {
        let nodes = nodes_of(program, profile)?;
        let names = texts(&nodes, "syntax_kind");
        for expected in [
            "task_scope",
            "spawn_statement",
            "spawn_expression",
            "await_expression",
            "select_statement",
            "receive_branch",
        ] {
            assert!(
                names.contains(&expected.to_owned()),
                "{profile}: {expected} in {names:?}"
            );
        }
    }
    Ok(())
}

#[test]
fn builtin_task_types_and_the_suspendable_marker_are_projected() -> Result<(), String> {
    for (program, profile) in [(SPANISH, "es"), (ENGLISH, "en")] {
        let nodes = nodes_of(program, profile)?;
        let builtins = texts(&nodes, "builtin_type");
        for expected in ["task", "channel", "immutable"] {
            assert!(
                builtins.contains(&expected.to_owned()),
                "{profile}: {expected}"
            );
        }
        let suspendable = nodes
            .iter()
            .filter(|node| node.get("suspendable") == Some(&json!(true)))
            .count();
        assert_eq!(suspendable, 1, "{profile}");
    }
    Ok(())
}

#[test]
fn plain_subroutines_are_not_marked_suspendable() -> Result<(), String> {
    let nodes = nodes_of(
        "SubProceso Plain()\nEscribir 1;\nFinSubProceso\nAlgoritmo Main\nPlain();\nFinAlgoritmo\n",
        "es",
    )?;
    assert!(nodes.iter().all(|node| node.get("suspendable").is_none()));
    Ok(())
}

fn roles_of(nodes: &[Value], syntax_kind: &str) -> Vec<Vec<String>> {
    nodes
        .iter()
        .filter(|node| node.get("syntax_kind") == Some(&json!(syntax_kind)))
        .map(|node| {
            node.get("child_roles")
                .and_then(Value::as_array)
                .map(|roles| {
                    roles
                        .iter()
                        .filter_map(|role| {
                            role.get("role").and_then(Value::as_str).map(str::to_owned)
                        })
                        .collect()
                })
                .unwrap_or_default()
        })
        .collect()
}

#[test]
fn task_scope_select_and_branches_declare_structural_roles() -> Result<(), String> {
    for (program, profile) in [(SPANISH, "es"), (ENGLISH, "en")] {
        let nodes = nodes_of(program, profile)?;
        assert_eq!(
            roles_of(&nodes, "task_scope"),
            vec![vec!["failure_binding".to_owned(), "body".to_owned()]],
            "{profile}"
        );
        assert_eq!(
            roles_of(&nodes, "select_statement"),
            vec![vec!["branch".to_owned(), "branch".to_owned()]],
            "{profile}"
        );
        for roles in roles_of(&nodes, "receive_branch") {
            assert_eq!(roles, ["binding", "channel", "body"], "{profile}");
        }
    }
    Ok(())
}
