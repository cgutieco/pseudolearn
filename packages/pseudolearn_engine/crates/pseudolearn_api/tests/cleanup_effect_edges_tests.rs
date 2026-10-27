const PROGRAM: &str = "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir text Como Cadena <- Propagar file.LeerTexto();\nRetornar Exito(text);\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";

const NO_CLEANUP: &str = "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";

fn blocks(source: &str) -> Result<Vec<Vec<String>>, String> {
    let text = pseudolearn_api::compile_source_to_ir(source, "es", "strict")
        .map_err(|errors| format!("{errors:?}"))?;
    let mut blocks: Vec<Vec<String>> = Vec::new();
    let mut functions = 0_u32;
    for line in text.lines() {
        if line.starts_with("func @") {
            functions = functions.saturating_add(1);
        }
        if functions > 1 {
            break;
        }
        if line.starts_with('b') && line.contains("() mass") {
            blocks.push(Vec::new());
        } else if let Some(block) = blocks.last_mut() {
            block.push(line.trim().to_owned());
        }
    }
    Ok(blocks)
}

fn position(block: &[String], needle: &str) -> Option<usize> {
    block.iter().position(|line| line.contains(needle))
}

#[test]
fn both_exit_edges_after_the_registration_close_the_file() -> Result<(), String> {
    let closing: Vec<_> = blocks(PROGRAM)?
        .into_iter()
        .filter(|block| position(block, "file_close").is_some())
        .collect();
    assert_eq!(closing.len(), 2, "{closing:?}");
    Ok(())
}

#[test]
fn result_is_stored_before_the_cleanup_runs() -> Result<(), String> {
    for block in blocks(PROGRAM)? {
        if let Some(close) = position(&block, "file_close") {
            let store = block.iter().rposition(|line| line.starts_with("cell.store"));
            assert!(store.is_some_and(|index| index < close), "{block:?}");
            assert!(block.iter().any(|line| line.starts_with("return")), "{block:?}");
        }
    }
    Ok(())
}

#[test]
fn failure_before_the_registration_runs_no_cleanup() -> Result<(), String> {
    let failing: Vec<_> = blocks(PROGRAM)?
        .into_iter()
        .filter(|block| position(block, "file_close").is_none())
        .filter(|block| block.iter().any(|line| line.starts_with("return")))
        .collect();
    assert_eq!(failing.len(), 1, "{failing:?}");
    Ok(())
}

#[test]
fn program_without_cleanup_emits_no_closing_effect() -> Result<(), String> {
    assert!(blocks(NO_CLEANUP)?.iter().all(|block| position(block, "file_close").is_none()));
    Ok(())
}
