use pseudolearn_runtime::CollectionPolicy;
use pseudolearn_vm::{Fuel, RunExit, RunOptions, RunResult};

fn execute(source: &str, options: RunOptions) -> Result<RunResult, String> {
    let module = pseudolearn_api::compile_source_to_module(source, "es", "strict")
        .map_err(|errors| format!("{errors:?}"))?;
    let bytecode =
        pseudolearn_bytecode::compile_module(&module).map_err(|error| format!("{error:?}"))?;
    let loaded = pseudolearn_vm::load(&bytecode).map_err(|error| format!("{error:?}"))?;
    Ok(pseudolearn_vm::run_with_options(
        &loaded,
        Fuel {
            statements: 100000,
            probes: 100000,
        },
        options,
    ))
}

fn policies(source: &str, output: &str) -> Result<(), String> {
    let mut previous = None;
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut options = RunOptions::default();
        options.memory.collection = collection;
        let result = execute(source, options)?;
        assert!(matches!(result.exit, RunExit::Completed(_)), "{result:?}");
        assert_eq!(result.output, output);
        if let Some(previous) = previous {
            assert_eq!(result, previous);
        }
        previous = Some(result);
    }
    Ok(())
}

#[test]
fn reference_arguments_evaluate_indices_once_and_alias_immediately() -> Result<(), String> {
    let source = "SubProceso Index(count Como Entero Por Referencia) Como Entero\ncount <- count + 1;\nRetornar 0;\nFinSubProceso\nSubProceso Change(left Como Entero Por Referencia,right Como Entero Por Referencia)\nleft <- 12;\nright <- right + 5;\nFinSubProceso\nAlgoritmo P\nDimension values[1] Como Entero;\nDefinir Mutable count Como Entero <- 0;\nvalues[0] <- 0;\nChange(values[Index(count)],values[Index(count)]);\nEscribir values[0],count;\nFinAlgoritmo\n";
    policies(source, "172\n")
}

#[test]
fn suspended_frames_retain_roots_across_recursive_bank_growth() -> Result<(), String> {
    let source = "Clase Node\nPublico Definir value Como Entero;\nFinClase\nSubProceso Build(depth Como Entero) Como Node\nDefinir local Como Node <- Nuevo Node();\nlocal.value <- depth;\nSi depth > 0 Entonces\nDefinir child Como Node <- Build(depth - 1);\nlocal.value <- local.value + child.value;\nFinSi\nRetornar local;\nFinSubProceso\nAlgoritmo P\nDefinir result Como Node <- Build(150);\nEscribir result.value;\nFinAlgoritmo\n";
    policies(source, "11325\n")
}

#[test]
fn depth_includes_main_and_accepts_exact_boundary() -> Result<(), String> {
    let source = "SubProceso Recur(depth Como Entero)\nSi depth > 0 Entonces\nRecur(depth - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nRecur(8);\nEscribir 1;\nFinAlgoritmo\n";
    for (depth, success) in [(0, false), (9, false), (10, true)] {
        let result = execute(
            source,
            RunOptions {
                depth,
                ..RunOptions::default()
            },
        )?;
        if success {
            assert_eq!(result.output, "1\n");
        } else {
            assert!(
                matches!(result.exit,RunExit::Trap(ref trap) if trap.code=="recursionDepthExceeded")
            );
        }
    }
    Ok(())
}

#[test]
fn constructor_reference_parameters_and_super_calls_share_one_receiver() -> Result<(), String> {
    let source = "Clase Base\nPublico Definir value Como Entero;\nMetodo Constructor(count Como Entero Por Referencia)\ncount <- count + 1;\nEste.value <- count;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nClase Derived Hereda De Base\nMetodo Constructor(count Como Entero Por Referencia)\nSuper.Constructor(count);\ncount <- count + 2;\nFinMetodo\nMetodo get() Como Entero\nRetornar Super.get() + 100;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir Mutable count Como Entero <- 3;\nDefinir result Como Base <- Nuevo Derived(count);\nEscribir result.get(),count;\nFinAlgoritmo\n";
    policies(source, "1046\n")
}

#[test]
fn mutually_recursive_subprograms_return_through_reused_windows() -> Result<(), String> {
    let source = "SubProceso First(depth Como Entero) Como Entero\nSi depth = 0 Entonces\nRetornar 0;\nFinSi\nRetornar Second(depth - 1) + 1;\nFinSubProceso\nSubProceso Second(depth Como Entero) Como Entero\nSi depth = 0 Entonces\nRetornar 0;\nFinSi\nRetornar First(depth - 1) + 1;\nFinSubProceso\nSubProceso Increment(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nSubProceso Pair(value Como Entero Por Referencia)\nIncrement(value);\nIncrement(value);\nFinSubProceso\nAlgoritmo P\nDefinir Mutable total Como Entero <- First(12);\nPair(total);\nIncrement(total);\nPair(total);\nEscribir total;\nFinAlgoritmo\n";
    policies(source, "17\n")
}

#[test]
fn invalid_reference_index_traps_before_entering_the_callee() -> Result<(), String> {
    let source = "SubProceso Index() Como Entero\nEscribir \"index\";\nRetornar 2;\nFinSubProceso\nSubProceso Touch(value Como Entero Por Referencia)\nEscribir \"body\";\nvalue <- 1;\nFinSubProceso\nAlgoritmo P\nDimension values[1] Como Entero;\nTouch(values[Index()]);\nFinAlgoritmo\n";
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut options = RunOptions::default();
        options.memory.collection = collection;
        let result = execute(source, options)?;
        assert!(matches!(
            result.exit,
            RunExit::Trap(ref trap) if trap.code == "arrayIndexOutOfRange"
        ));
        assert_eq!(result.output, "index\n");
    }
    Ok(())
}

#[test]
fn receiver_escape_dispatches_before_derived_integer_initialization() -> Result<(), String> {
    let source = "Clase Base\nMetodo publish(output Como Base Por Referencia)\noutput <- Este;\nEscribir \"base\";\nEscribir output.read();\nFinMetodo\nMetodo read() Como Entero\nRetornar 0;\nFinMetodo\nFinClase\nClase Derived Hereda De Base\nPublico Definir value Como Entero;\nMetodo Constructor(output Como Base Por Referencia)\nEste.publish(output);\nEste.value <- 7;\nFinMetodo\nMetodo read() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir Mutable result Como Base <- Nuevo Base();\nresult <- Nuevo Derived(result);\nFinAlgoritmo\n";
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut options = RunOptions::default();
        options.memory.collection = collection;
        let result = execute(source, options)?;
        assert!(matches!(
            result.exit,
            RunExit::Trap(ref trap) if trap.code == "uninitializedVariableRead"
        ));
        assert_eq!(result.output, "base\n");
    }
    Ok(())
}

#[test]
fn shallow_copy_keeps_cycles_and_uninitialized_fields() -> Result<(), String> {
    let source = "Clase Node\nPublico Definir next Como Node;\nPublico Definir value Como Entero;\nFinClase\nAlgoritmo P\nDefinir original Como Node <- Nuevo Node();\noriginal.next <- original;\nDefinir copia Como Node <- Copiar(original);\nEscribir copia = original, copia.next = original;\nEscribir copia.value;\nFinAlgoritmo\n";
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut options = RunOptions::default();
        options.memory.collection = collection;
        let result = execute(source, options)?;
        assert!(matches!(
            result.exit,
            RunExit::Trap(ref trap) if trap.code == "uninitializedVariableRead"
        ));
        assert_eq!(result.output, "FalsoVerdadero\n");
    }
    Ok(())
}
