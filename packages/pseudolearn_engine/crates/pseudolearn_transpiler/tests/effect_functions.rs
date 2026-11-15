#[path = "support/translation.rs"]
mod translation;

use pseudolearn_transpiler::{TargetLanguage, TranspileOutcome};
use translation::{code, translate};

const CLOCK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>
Definir clock Como Reloj <- Propagar SolicitarReloj();
Retornar clock.Ahora();
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo, problem.Incierto;
FinSegun
FinAlgoritmo
";

const LOCAL_CLOCK: &str = "Algoritmo Main
Segun SolicitarReloj() Hacer
Exito(clock):
Segun clock.AhoraLocal() Hacer
Exito(moment): Escribir moment.Anio();
Error(problem): Escribir problem.Codigo;
FinSegun
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
";

const JSON: &str = "Algoritmo P
Definir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(\"{\");
Segun parsed Hacer
Exito(document): Escribir \"ok\";
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
";

const LIBRARY: &str = "Algoritmo P
Escribir AMayusculas(\"hola\"), Subcadena(\"hola\", 1, 2), RellenarIzquierda(\"7\", 3, \"0\");
Escribir Decimales(2.5, 0), FechaHoraUtc(0).FormatoIso();
FinAlgoritmo
";

const RESERVED_SUPPORT: &str = "Algoritmo P
Definir request_clock Como Entero <- 1;
Escribir request_clock;
FinAlgoritmo
";

fn constructs(program: &str, target: TargetLanguage) -> Result<Vec<String>, String> {
    match translate(program, target)? {
        TranspileOutcome::Unavailable(blockers) => Ok(blockers
            .into_iter()
            .map(|blocker| blocker.construct)
            .collect()),
        TranspileOutcome::Code(_) => Ok(Vec::new()),
    }
}

#[test]
fn capability_operations_translate_in_both_targets() -> Result<(), String> {
    let rust = code(CLOCK, TargetLanguage::Rust)?;
    assert!(rust.contains("let clock: Clock = request_clock()?;"));
    assert!(rust.contains("return clock_now(&clock);"));
    assert!(rust.contains("IoError { codigo: code.to_string(), incierto: uncertain }"));
    let python = code(CLOCK, TargetLanguage::Python)?;
    assert!(python.contains("clock = propagate(request_clock())"));
    assert!(python.contains("@host_operation\ndef clock_now(clock):"));
    Ok(())
}

#[test]
fn library_functions_translate_in_both_targets() -> Result<(), String> {
    let rust = code(LIBRARY, TargetLanguage::Rust)?;
    assert!(rust.contains("text_to_upper(\"hola\")"));
    assert!(rust.contains("substring(\"hola\", 1, 2)"));
    assert!(rust.contains("date_time_iso_format(&date_time_utc(0))"));
    let python = code(LIBRARY, TargetLanguage::Python)?;
    assert!(python.contains("text_pad_left(\"7\", 3, \"0\")"));
    assert!(python.contains("text_decimals(2.5, 0)"));
    Ok(())
}

#[test]
fn json_stays_pending_in_both_targets() -> Result<(), String> {
    for target in [TargetLanguage::Rust, TargetLanguage::Python] {
        let found = constructs(JSON, target)?;
        assert!(!found.is_empty());
        assert!(found.iter().all(|construct| construct == "capability"));
    }
    Ok(())
}

#[test]
fn local_time_is_pending_only_in_rust() -> Result<(), String> {
    assert_eq!(
        constructs(LOCAL_CLOCK, TargetLanguage::Rust)?,
        ["capability"]
    );
    let python = code(LOCAL_CLOCK, TargetLanguage::Python)?;
    assert!(python.contains("clock_local_now(clock)"));
    Ok(())
}

#[test]
fn user_names_never_hide_support_functions() -> Result<(), String> {
    let rust = code(RESERVED_SUPPORT, TargetLanguage::Rust)?;
    assert!(rust.contains("let request_clock_value: i64 = 1;"));
    let python = code(RESERVED_SUPPORT, TargetLanguage::Python)?;
    assert!(python.contains("request_clock_value = 1"));
    Ok(())
}

#[test]
fn programs_without_effects_request_no_effect_support() -> Result<(), String> {
    let rust = code(
        "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
        TargetLanguage::Rust,
    )?;
    assert!(!rust.contains("IoError"));
    assert!(!rust.contains("host_error"));
    Ok(())
}
