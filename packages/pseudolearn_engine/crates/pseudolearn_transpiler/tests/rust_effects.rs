#[path = "support/translation.rs"]
mod translation;

use pseudolearn_transpiler::TargetLanguage;
use translation::code;

const FILES: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");
Definir child Como DirectorioCap <- Propagar directory.Subdirectorio(\"sub\", \"lectura\");
Definir file Como ArchivoCap <- Propagar child.Abrir(\"b\", \"lectura\");
Diferir
Descartar file.Cerrar();
FinDiferir
Retornar file.LeerTexto();
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
";

const EXIT_CODE: &str = "SubProceso Marcar() Como Resultado<Entero, ErrorES>
Definir consola Como Consola <- Propagar SolicitarConsola();
Retornar consola.EstablecerCodigoSalida(3);
FinSubProceso
Algoritmo P
Descartar Marcar();
FinAlgoritmo
";

const TIMERS: &str = "SubProceso Suspendible Wait() Como Resultado<Entero, ErrorES>
Definir timer Como Temporizador <- Propagar SolicitarTemporizador();
Retornar Aguardar timer.Esperar(100);
FinSubProceso
SubProceso Pause() Como Resultado<Entero, ErrorES>
Definir timer Como Temporizador <- Propagar SolicitarTemporizador();
Retornar timer.Esperar(100);
FinSubProceso
Algoritmo P
Descartar Pause();
Tareas report
Lanzar Wait();
FinTareas
Descartar report;
FinAlgoritmo
";

#[test]
fn files_carry_rights_and_confinement() -> Result<(), String> {
    let text = code(FILES, TargetLanguage::Rust)?;
    assert!(text.contains("directory_derive(&directory, \"sub\", \"lectura\")?"));
    assert!(text.contains("file_open(&child, \"b\", \"lectura\")?"));
    assert!(text.contains("fn checked_path(path: &str) -> Result<(), IoError> {"));
    assert!(text.contains("Err(host_error(\"capacidad_cerrada\"))"));
    assert!(!text.contains("fn directory_list("));
    Ok(())
}

#[test]
fn the_exit_code_is_applied_when_main_ends() -> Result<(), String> {
    let text = code(EXIT_CODE, TargetLanguage::Rust)?;
    assert!(text.contains("fn main() {\n    marcar();\n    finish_with_exit_code();\n}"));
    assert!(text.contains("if !(0..=255).contains(&code) {"));
    Ok(())
}

#[test]
fn awaited_timers_suspend_and_plain_timers_block() -> Result<(), String> {
    let text = code(TIMERS, TargetLanguage::Rust)?;
    assert!(text.contains("return timer_wait(&timer, 100).await;"));
    assert!(text.contains("return timer_wait_blocking(&timer, 100);"));
    assert!(text.contains("fn wake_next_timers() -> bool {"));
    Ok(())
}
