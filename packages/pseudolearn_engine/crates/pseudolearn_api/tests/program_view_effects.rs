use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

const SPANISH: &str = "SubProceso Probe() Como Resultado<Bytes, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nRetornar file.LeerBytes();\nFinSubProceso\nAlgoritmo Main\nEscribir 1;\nFinAlgoritmo\n";
const ENGLISH: &str = "subroutine Probe() as result<Bytes, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\nreturn file.readBytes();\nendSubroutine\nalgorithm Main\nwrite 1;\nendAlgorithm\n";

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

fn attribute_values(nodes: &[Value], attribute: &str) -> Vec<String> {
    nodes
        .iter()
        .filter_map(|node| {
            node.get(attribute)
                .and_then(Value::as_str)
                .map(str::to_owned)
        })
        .collect()
}

#[test]
fn capability_and_builtin_types_are_projected_in_both_profiles() -> Result<(), String> {
    for (program, profile) in [(SPANISH, "es"), (ENGLISH, "en")] {
        let nodes = nodes_of(program, profile)?;
        let capabilities = attribute_values(&nodes, "capability_type");
        assert!(capabilities.contains(&"directory".to_owned()), "{profile}");
        assert!(capabilities.contains(&"file".to_owned()), "{profile}");
        let builtins = attribute_values(&nodes, "builtin_type");
        assert!(builtins.contains(&"bytes".to_owned()), "{profile}");
        assert!(builtins.contains(&"io_error".to_owned()), "{profile}");
    }
    Ok(())
}

#[test]
fn effect_operations_are_projected_by_identity() -> Result<(), String> {
    for (program, profile) in [(SPANISH, "es"), (ENGLISH, "en")] {
        let operations = attribute_values(&nodes_of(program, profile)?, "effect_operation");
        for expected in [
            "request_directory",
            "file_open",
            "file_close",
            "file_read_bytes",
        ] {
            assert!(
                operations.contains(&expected.to_owned()),
                "{profile}: {expected}"
            );
        }
    }
    Ok(())
}

#[test]
fn a_program_without_capabilities_projects_no_effect_attributes() -> Result<(), String> {
    let nodes = nodes_of(
        "Proceso P\nDefinir x Como Entero <- 1;\nEscribir x;\nFinProceso\n",
        "es",
    )?;
    assert!(attribute_values(&nodes, "effect_operation").is_empty());
    assert!(attribute_values(&nodes, "capability_type").is_empty());
    assert!(attribute_values(&nodes, "builtin_type").is_empty());
    Ok(())
}
