#[path = "support/translation.rs"]
mod translation;

use pseudolearn_transpiler::TargetLanguage;
use translation::code;

const PLAIN_WAITS: &str = "SubProceso Suspendible Consume(stream Como Canal<Entero>)
Segun Aguardar stream.Recibir() Hacer
Algo(received): Escribir received;
Nada: Escribir \"closed\";
FinSegun
FinSubProceso
Algoritmo P
Definir stream Como Canal<Entero> <- Canal(1);
Tareas
Lanzar Consume(stream);
FinTareas
FinAlgoritmo
";

const CANCELLED_CLEANUP: &str = "SubProceso Suspendible Hold(stream Como Canal<Entero>)
Diferir
Escribir \"cleanup\";
FinDiferir
Segun Aguardar stream.Recibir() Hacer
Algo(value): Escribir value;
Nada: Escribir \"closed\";
FinSegun
FinSubProceso
SubProceso Suspendible Fail() Como Resultado<Entero, Cadena>
Retornar Error(\"failed\");
FinSubProceso
Algoritmo P
Definir stream Como Canal<Entero> <- Canal(1);
Tareas problem
Lanzar Hold(stream);
Lanzar Fail();
FinTareas
Segun problem Hacer
Nada: Escribir \"ok\";
Algo(report): Escribir report.Primero;
FinSegun
FinAlgoritmo
";

#[test]
fn waits_with_pending_cleanups_run_them_when_cancelled() -> Result<(), String> {
    let text = code(CANCELLED_CLEANUP, TargetLanguage::Rust)?;
    assert!(text.contains(
        "match until_cancelled(stream.receive()).await { Some(value) => value, None => { println!(\"cleanup\"); return unwound().await; } }"
    ));
    assert!(text.contains("fn cancel_task(index: usize) {"));
    assert!(text.contains("task_scope.join().await;"));
    Ok(())
}

#[test]
fn waits_without_cleanups_stay_plain() -> Result<(), String> {
    let text = code(PLAIN_WAITS, TargetLanguage::Rust)?;
    assert!(text.contains("stream.receive().await"));
    assert!(!text.contains("until_cancelled"));
    assert!(!text.contains("fn unwound"));
    Ok(())
}
