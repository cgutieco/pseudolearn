use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const LISTER: &str = "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const RENAMER: &str = "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"a\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir \"hecho\";\nError(problem): Si problem.Incierto Entonces Escribir \"incierto\"; Sino Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n";

const QUERY: &str = "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

struct Run {
    session: ApiSession,
    resource: Value,
}

fn start(program: &str, _families: &[&str]) -> Result<Run, String> {
    let mut session = ApiSession::default();
    let analysis = session.call("create_analysis", &json!({"program":program}));
    let started = session.call(
        "start",
        &json!({"analysis":analysis.pointer("/value/resource"),"program":program,
            "host":{"detached":true}}),
    );
    let resource = started
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| format!("start failed: {started}"))?;
    Ok(Run { session, resource })
}

impl Run {
    fn advance(&mut self) -> Value {
        self.session.call(
            "advance",
            &json!({"resource":self.resource,"batch_size":1000}),
        )
    }

    fn feed(&mut self, operation: &str, fields: Value) -> Value {
        let mut arguments = json!({"resource":self.resource});
        if let (Some(target), Some(extra)) = (arguments.as_object_mut(), fields.as_object()) {
            target.extend(extra.clone());
        }
        self.session.call(operation, &arguments)
    }

    fn reply(&mut self, sequence: &Value, result: Value) -> Value {
        self.feed(
            "effect_result",
            json!({"effect_seq":sequence,"result":result}),
        )
    }
}

fn kind(response: &Value) -> Option<&str> {
    response
        .pointer("/value/termination/kind")
        .and_then(Value::as_str)
}

fn pending(response: &Value) -> Result<(Value, Value), String> {
    let sequence = response
        .pointer("/value/termination/effect_seq")
        .cloned()
        .ok_or_else(|| format!("no sequence: {response}"))?;
    let capability = response
        .pointer("/value/pending_effect/result_capability")
        .cloned()
        .unwrap_or(Value::Null);
    Ok((sequence, capability))
}

fn committed(kind: &str, value: Value) -> Value {
    json!({"outcome":"committed","value":{"kind":kind,"value":value}})
}

fn resolve_root(run: &mut Run) -> Result<(), String> {
    let step = run.advance();
    let (sequence, capability) = pending(&step)?;
    run.reply(&sequence, committed("capability", capability));
    Ok(())
}

#[test]
fn list_suspends_with_its_operation_and_resumes_with_the_text_list() -> Result<(), String> {
    let mut run = start(LISTER, &["archivos_lectura"])?;
    resolve_root(&mut run)?;
    let listing = run.advance();
    assert_eq!(
        listing.pointer("/value/termination/operation"),
        Some(&json!("directory_list"))
    );
    let (sequence, _) = pending(&listing)?;
    run.reply(&sequence, committed("text_list", json!(["a", "b"])));
    let done = run.advance();
    assert_eq!(kind(&done), Some("completed"), "{done}");
    assert_eq!(done.pointer("/value/output"), Some(&json!("2:a,b\n")));
    Ok(())
}

#[test]
fn uncertain_rename_is_visible_to_the_program_and_marks_the_tape() -> Result<(), String> {
    let mut run = start(RENAMER, &["archivos_escritura"])?;
    resolve_root(&mut run)?;
    let rename = run.advance();
    assert_eq!(
        rename.pointer("/value/termination/operation"),
        Some(&json!("directory_rename"))
    );
    let (sequence, _) = pending(&rename)?;
    let uncertain = json!({"outcome":"uncertain","value":{"code":"interrumpido","uncertain":true}});
    assert!(run.reply(&sequence, uncertain).get("value").is_some());
    let done = run.advance();
    assert_eq!(
        done.pointer("/value/output"),
        Some(&json!("incierto\n")),
        "{done}"
    );
    assert_eq!(
        done.pointer("/value/effect_tape/status"),
        Some(&json!("uncertain_external_state"))
    );
    Ok(())
}

#[test]
fn read_only_directory_query_cannot_be_reported_as_uncertain() -> Result<(), String> {
    let mut run = start(QUERY, &["archivos_lectura"])?;
    resolve_root(&mut run)?;
    let query = run.advance();
    let (sequence, _) = pending(&query)?;
    let uncertain = json!({"outcome":"uncertain","value":{"code":"interrumpido","uncertain":true}});
    let rejected = run.reply(&sequence, uncertain);
    assert!(rejected.get("failure").is_some(), "{rejected}");
    Ok(())
}

#[test]
fn committed_value_of_the_wrong_kind_is_rejected_for_directory_operations() -> Result<(), String> {
    let mut run = start(QUERY, &["archivos_lectura"])?;
    resolve_root(&mut run)?;
    let query = run.advance();
    let (sequence, _) = pending(&query)?;
    let rejected = run.reply(&sequence, committed("integer", json!(1)));
    assert!(rejected.get("failure").is_some(), "{rejected}");
    Ok(())
}
