use pseudolearn_runtime::{
    HostCapability, HostEffectProvider, HostEffectRequest, HostReply, HostValue, MemoryHostProvider,
};
use serde_json::json;

fn capability(slot: u32) -> HostCapability {
    HostCapability {
        slot,
        generation: 1,
        rights: 3,
        kind: 2,
    }
}

fn provider(host: serde_json::Value) -> Result<MemoryHostProvider, String> {
    let mut provider =
        MemoryHostProvider::from_value(&host).map_err(|error| error.code().to_owned())?;
    let reply = provider.perform(&HostEffectRequest {
        effect_seq: 1,
        operation: "request_directory".to_owned(),
        receiver: None,
        arguments: vec![HostValue::Text("root".to_owned())],
        result_capability: Some(capability(1)),
        source_node_id: 0,
    });
    assert!(matches!(reply, HostReply::Committed(_)));
    Ok(provider)
}

fn run(
    provider: &mut MemoryHostProvider,
    operation: &str,
    arguments: &[&str],
) -> Result<HostValue, String> {
    let reply = provider.perform(&HostEffectRequest {
        effect_seq: 2,
        operation: operation.to_owned(),
        receiver: Some(capability(1)),
        arguments: arguments
            .iter()
            .map(|argument| HostValue::Text((*argument).to_owned()))
            .collect(),
        result_capability: None,
        source_node_id: 0,
    });
    match reply {
        HostReply::Committed(value) => Ok(value),
        HostReply::Failed(error) | HostReply::Uncertain(error) => Err(error.code),
    }
}

#[test]
fn listing_merges_files_and_explicit_directories_sorted_by_code_point() -> Result<(), String> {
    let mut host = provider(
        json!({"files":{"d/b":"1","d/a":"2","d/s/x":"3","d/á":"4"},"directories":["d/e","d/Z"]}),
    )?;
    assert_eq!(
        run(&mut host, "directory_list", &["d"])?,
        HostValue::TextList(["Z", "a", "b", "e", "s", "á"].map(str::to_owned).to_vec())
    );
    assert_eq!(
        run(&mut host, "directory_list", &["d/e"])?,
        HostValue::TextList(Vec::new())
    );
    Ok(())
}

#[test]
fn deleting_the_last_entry_keeps_an_explicit_parent_directory_alive() -> Result<(), String> {
    let mut host = provider(json!({"directories":["d"],"files":{"d/a":"x"}}))?;
    run(&mut host, "directory_delete", &["d/a"])?;
    assert_eq!(
        run(&mut host, "directory_is_directory", &["d"])?,
        HostValue::Boolean(true)
    );
    assert_eq!(
        run(&mut host, "directory_delete", &["d"])?,
        HostValue::Boolean(true)
    );
    assert_eq!(
        run(&mut host, "directory_exists", &["d"])?,
        HostValue::Boolean(false)
    );
    Ok(())
}

#[test]
fn renaming_a_directory_moves_nested_files_and_empty_directories() -> Result<(), String> {
    let mut host = provider(json!({"files":{"d/x/f":"1"},"directories":["d/empty"]}))?;
    run(&mut host, "directory_rename", &["d", "n"])?;
    assert_eq!(
        run(&mut host, "directory_exists", &["n/x/f"])?,
        HostValue::Boolean(true)
    );
    assert_eq!(
        run(&mut host, "directory_is_directory", &["n/empty"])?,
        HostValue::Boolean(true)
    );
    assert_eq!(
        run(&mut host, "directory_exists", &["d"])?,
        HostValue::Boolean(false)
    );
    Ok(())
}

#[test]
fn rename_edge_cases_report_their_cause() -> Result<(), String> {
    let mut host = provider(json!({"files":{"a":"1","b":"2","d/x":"3"}}))?;
    assert_eq!(
        run(&mut host, "directory_rename", &["a", "b"]),
        Err("ya_existe".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_rename", &["zz", "c"]),
        Err("no_encontrado".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_rename", &["a", "q/c"]),
        Err("no_encontrado".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_rename", &["a", "b/c"]),
        Err("ruta_invalida".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_rename", &["d", "d/n"]),
        Err("ruta_invalida".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_rename", &[".", "r"]),
        Err("ruta_invalida".to_owned())
    );
    Ok(())
}

#[test]
fn create_and_delete_edge_cases_report_their_cause() -> Result<(), String> {
    let mut host = provider(json!({"files":{"a":"1","d/x":"2"}}))?;
    assert_eq!(
        run(&mut host, "directory_create", &["a"]),
        Err("ya_existe".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_create", &["d"]),
        Err("ya_existe".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_create", &["a/n"]),
        Err("ruta_invalida".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_create", &["p/n"]),
        Err("no_encontrado".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_delete", &["d"]),
        Err("peticion_invalida".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_delete", &["zz"]),
        Err("no_encontrado".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_delete", &["."]),
        Err("ruta_invalida".to_owned())
    );
    Ok(())
}

#[test]
fn listing_a_file_or_an_absent_path_fails() -> Result<(), String> {
    let mut host = provider(json!({"files":{"a":"1"}}))?;
    assert_eq!(
        run(&mut host, "directory_list", &["a"]),
        Err("ruta_invalida".to_owned())
    );
    assert_eq!(
        run(&mut host, "directory_list", &["zz"]),
        Err("no_encontrado".to_owned())
    );
    Ok(())
}
