use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::fs;

fn open(session: &mut ApiSession, program: &str, profile: &str) -> Result<Value, String> {
    session
        .call(
            "create_document",
            &json!({"program":program,"profile":profile}),
        )
        .pointer("/value/resource")
        .cloned()
        .ok_or_else(|| "missing document".to_owned())
}

fn view(program: &str, profile: &str) -> Value {
    let mut session = ApiSession::default();
    let Ok(document) = open(&mut session, program, profile) else {
        return Value::Null;
    };
    session.call("program_view", &json!({"resource":document}))
}

fn dependencies(program: &str, profile: &str) -> Result<Vec<Value>, String> {
    view(program, profile)
        .pointer("/value/dependencies")
        .and_then(Value::as_array)
        .cloned()
        .ok_or_else(|| "missing dependencies".to_owned())
}

fn nth(items: &[Value], position: usize) -> Result<&Value, String> {
    items
        .get(position)
        .ok_or_else(|| format!("missing dependency {position}"))
}

fn path_of(dependency: &Value) -> Vec<&str> {
    dependency
        .get("path")
        .and_then(Value::as_array)
        .map(|segments| segments.iter().filter_map(Value::as_str).collect())
        .unwrap_or_default()
}

#[test]
fn symbol_import_with_alias_is_listed_unlinked_with_its_range() -> Result<(), String> {
    let program = "Importar geo.Punto Como P;\nAlgoritmo Main\nFinAlgoritmo\n";
    let listed = dependencies(program, "es")?;
    let [dependency] = listed.as_slice() else {
        return Err(format!("expected one dependency: {listed:?}"));
    };
    assert_eq!(path_of(dependency), vec!["geo", "Punto"]);
    assert_eq!(dependency.get("alias"), Some(&json!("P")));
    assert_eq!(dependency.get("kind"), Some(&json!("import")));
    assert_eq!(dependency.get("visibility"), Some(&json!("local")));
    assert_eq!(dependency.get("status"), Some(&json!("unlinked")));
    assert_eq!(
        dependency.get("diagnostic"),
        Some(&json!("moduleSyntaxOutsideProject"))
    );
    assert_eq!(dependency.pointer("/span/start/line"), Some(&json!(1)));
    assert_eq!(dependency.pointer("/span/start/column"), Some(&json!(1)));
    assert_eq!(dependency.pointer("/span/end/column"), Some(&json!(27)));
    Ok(())
}

#[test]
fn module_import_without_alias_and_chained_export_keep_source_order() -> Result<(), String> {
    let program = "import geo;\nexport geo.shapes.Circle;\nexport geo.shapes.Square;\nalgorithm Main\nendAlgorithm\n";
    let listed = dependencies(program, "en")?;
    let kinds: Vec<&Value> = listed
        .iter()
        .filter_map(|entry| entry.get("kind"))
        .collect();
    assert_eq!(
        kinds,
        vec![&json!("import"), &json!("export"), &json!("export")]
    );
    assert_eq!(path_of(nth(&listed, 1)?), vec!["geo", "shapes", "Circle"]);
    assert_eq!(nth(&listed, 0)?.get("alias"), Some(&Value::Null));
    assert_eq!(nth(&listed, 1)?.get("visibility"), Some(&json!("exported")));
    let orders: Vec<&Value> = listed
        .iter()
        .filter_map(|entry| entry.get("order"))
        .collect();
    assert_eq!(orders, vec![&json!(0), &json!(1), &json!(2)]);
    Ok(())
}

#[test]
fn other_units_stay_recoverable_and_no_dependency_node_leaks_into_the_tree() -> Result<(), String> {
    let program = "Importar geo.Punto;\nAlgoritmo Main\nEscribir 1;\nFinAlgoritmo\n";
    let result = view(program, "es");
    let units = result
        .pointer("/value/units")
        .and_then(Value::as_array)
        .ok_or("missing units")?;
    assert_eq!(units.len(), 1);
    let nodes = result
        .pointer("/value/nodes")
        .and_then(Value::as_array)
        .ok_or("missing nodes")?;
    assert!(nodes.iter().all(|node| node.get("parent_node_id").is_some()
        || node.get("syntax_kind") == Some(&json!("algorithm_unit"))));
    Ok(())
}

#[test]
fn clean_document_lists_no_dependencies() -> Result<(), String> {
    let listed = dependencies("Algoritmo Main\nFinAlgoritmo\n", "es")?;
    assert!(listed.is_empty());
    Ok(())
}

#[test]
fn incomplete_path_yields_no_view_instead_of_an_invented_dependency() {
    for program in [
        "Importar geo.;\nAlgoritmo Main\nFinAlgoritmo\n",
        "Importar ;\nAlgoritmo Main\nFinAlgoritmo\n",
    ] {
        let result = view(program, "es");
        assert!(result.get("failure").is_some(), "{result}");
    }
}

#[test]
fn escaping_and_absolute_paths_are_not_dependencies() {
    for program in [
        "Importar ../secreto;\nAlgoritmo Main\nFinAlgoritmo\n",
        "Importar /etc/passwd;\nAlgoritmo Main\nFinAlgoritmo\n",
        "Importar C:\\datos;\nAlgoritmo Main\nFinAlgoritmo\n",
    ] {
        let result = view(program, "es");
        assert!(result.get("failure").is_some(), "{program}: {result}");
    }
}

#[test]
fn reserved_local_name_is_still_a_pending_dependency_with_its_alias_absent() -> Result<(), String> {
    let listed = dependencies(
        "Importar geo.Mientras;\nAlgoritmo Main\nFinAlgoritmo\n",
        "es",
    )?;
    assert_eq!(path_of(nth(&listed, 0)?), vec!["geo", "Mientras"]);
    assert_eq!(nth(&listed, 0)?.get("alias"), Some(&Value::Null));
    Ok(())
}

#[test]
fn a_document_with_only_a_dependency_and_no_entry_has_no_view() {
    let result = view("Importar geo.Punto;\n", "es");
    assert!(result.get("failure").is_some(), "{result}");
}

#[test]
fn other_syntax_errors_next_to_a_dependency_reject_the_whole_view() {
    let result = view(
        "Importar geo.Punto;\nAlgoritmo Main\nEscribir 1 +;\nFinAlgoritmo\n",
        "es",
    );
    assert!(result.get("failure").is_some(), "{result}");
}

#[test]
fn execution_is_blocked_while_a_link_is_pending() -> Result<(), String> {
    let mut session = ApiSession::default();
    let program = "Importar geo.Punto;\nAlgoritmo Main\nEscribir 1;\nFinAlgoritmo\n";
    let document = open(&mut session, program, "es")?;
    let analysis = session
        .call("analyze_document", &json!({"resource":document}))
        .pointer("/value/resource")
        .cloned();
    let blocked = match analysis {
        Some(resource) => session.call("start", &json!({"resource":resource})),
        None => session.call("execute", &json!({"program":program,"profile":"es"})),
    };
    assert!(blocked.get("failure").is_some(), "{blocked}");
    Ok(())
}

#[test]
fn naming_an_existing_package_on_disk_neither_reads_nor_changes_it() -> Result<(), String> {
    let root = std::env::temp_dir().join(format!("pseudolearn_dependency_{}", std::process::id()));
    let package = root.join("geo");
    fs::create_dir_all(&package).map_err(|error| error.to_string())?;
    let file = package.join("shapes.pseudo");
    let content = "Publico SubProceso Origen()\nFinSubProceso\n";
    fs::write(&file, content).map_err(|error| error.to_string())?;
    let before = fs::metadata(&file).map_err(|error| error.to_string())?;
    let listed = dependencies(
        "Importar geo.shapes.Origen;\nAlgoritmo Main\nFinAlgoritmo\n",
        "es",
    )?;
    assert_eq!(nth(&listed, 0)?.get("status"), Some(&json!("unlinked")));
    let after = fs::metadata(&file).map_err(|error| error.to_string())?;
    assert_eq!(
        fs::read_to_string(&file).map_err(|error| error.to_string())?,
        content
    );
    assert_eq!(before.modified().ok(), after.modified().ok());
    assert_eq!(before.accessed().ok(), after.accessed().ok());
    fs::remove_dir_all(&root).map_err(|error| error.to_string())?;
    Ok(())
}

#[test]
fn identical_text_gives_identical_dependency_identity_and_other_revisions_differ()
-> Result<(), String> {
    let program = "Importar geo.Punto;\nAlgoritmo Main\nFinAlgoritmo\n";
    let first = dependencies(program, "es")?;
    let again = dependencies(program, "es")?;
    assert_eq!(first, again);
    let mut session = ApiSession::default();
    let _skipped = open(&mut session, "Algoritmo Other\nFinAlgoritmo\n", "es")?;
    let second_document = open(&mut session, program, "es")?;
    let second = session.call("program_view", &json!({"resource":second_document}));
    let other = second
        .pointer("/value/dependencies/0/dependency_id")
        .cloned();
    assert_ne!(other, nth(&first, 0)?.get("dependency_id").cloned());
    Ok(())
}
