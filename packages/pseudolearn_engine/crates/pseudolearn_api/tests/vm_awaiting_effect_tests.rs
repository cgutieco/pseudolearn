use pseudolearn_vm::{Fuel, RunExit, RunOptions};

const CLOCK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const READ: &str =
    "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x;\nFinAlgoritmo\n";

fn exit_of(source: &str) -> Result<RunExit, String> {
    let module = pseudolearn_api::compile_source_to_module(source, "es", "strict")
        .map_err(|errors| format!("{errors:?}"))?;
    let bytecode =
        pseudolearn_bytecode::compile_module(&module).map_err(|error| format!("{error:?}"))?;
    let loaded = pseudolearn_vm::load(&bytecode).map_err(|error| format!("{error:?}"))?;
    let fuel = Fuel {
        statements: 1000,
        probes: 1000,
    };
    Ok(pseudolearn_vm::run_with_options(&loaded, fuel, RunOptions::default()).exit)
}

#[test]
fn capability_operation_exits_with_the_pending_effect() -> Result<(), String> {
    match exit_of(CLOCK)? {
        RunExit::AwaitingEffect(pending) => {
            assert_eq!(pending.effect_seq, 1);
            assert_eq!(pending.operation, "request_clock");
            assert_eq!(pending.capability_kind, "clock");
            assert_eq!(pending.arguments_summary, "{\"count\":0}");
            assert!(pending.source_node_id.is_some());
            Ok(())
        }
        other => Err(format!("expected awaiting_effect, got {other:?}")),
    }
}

#[test]
fn read_exits_with_awaiting_input_and_never_with_awaiting_effect() -> Result<(), String> {
    let exit = exit_of(READ)?;
    assert_eq!(exit, RunExit::AwaitingInput);
    Ok(())
}

#[test]
fn program_without_effects_never_suspends() -> Result<(), String> {
    let exit = exit_of("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n")?;
    assert!(matches!(exit, RunExit::Completed(_)), "{exit:?}");
    Ok(())
}
