#[path = "support/translation.rs"]
mod translation;

use pseudolearn_transpiler::TargetLanguage;
use translation::code;

const FILES: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>
Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");
Definir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");
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
fn file_operations_report_failures_as_results() -> Result<(), String> {
    let text = code(FILES, TargetLanguage::Python)?;
    assert!(text.contains("import errno\nimport os\n"));
    assert!(text.contains("file = propagate(file_open(directory, \"a\", \"lectura\"))"));
    assert!(text.contains("return Err(IoError(error.code, error.uncertain))"));
    assert!(!text.contains("def directory_derive"));
    Ok(())
}

#[test]
fn the_exit_code_is_applied_after_main() -> Result<(), String> {
    let text = code(EXIT_CODE, TargetLanguage::Python)?;
    assert!(text.ends_with("main()\nsys.exit(EXIT_CODE[0])\n"));
    Ok(())
}

#[test]
fn awaited_timers_suspend_and_plain_timers_block() -> Result<(), String> {
    let text = code(TIMERS, TargetLanguage::Python)?;
    assert!(text.contains("return await timer_wait(timer, 100)"));
    assert!(text.contains("return timer_wait_blocking(timer, 100)"));
    Ok(())
}
