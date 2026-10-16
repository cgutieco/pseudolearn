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
    let source = "SubProceso Index(count Como Entero Por Referencia) Como Entero\ncount <- count + 1;\nRetornar 0;\nFinSubProceso\nSubProceso Change(left Como Entero Por Referencia,right Como Entero Por Referencia)\nleft <- 12;\nright <- right + 5;\nFinSubProceso\nAlgoritmo P\nDimension values[1] Como Entero;\nDefinir count Como Entero;\ncount <- 0;\nvalues[0] <- 0;\nChange(values[Index(count)],values[Index(count)]);\nEscribir values[0],count;\nFinAlgoritmo\n";
    policies(source, "172\n")
}

#[test]
fn suspended_frames_retain_roots_across_recursive_bank_growth() -> Result<(), String> {
    let source = "Clase Node\nPublico Definir value Como Entero;\nFinClase\nSubProceso Build(depth Como Entero) Como Node\nDefinir local,child Como Node;\nlocal <- Nuevo Node();\nlocal.value <- depth;\nSi depth > 0 Entonces\nchild <- Build(depth - 1);\nlocal.value <- local.value + child.value;\nFinSi\nRetornar local;\nFinSubProceso\nAlgoritmo P\nDefinir result Como Node;\nresult <- Build(150);\nEscribir result.value;\nFinAlgoritmo\n";
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
    let source = "Clase Base\nPublico Definir value Como Entero;\nMetodo Constructor(count Como Entero Por Referencia)\ncount <- count + 1;\nEste.value <- count;\nFinMetodo\nMetodo get() Como Entero\nRetornar Este.value;\nFinMetodo\nFinClase\nClase Derived Hereda De Base\nMetodo Constructor(count Como Entero Por Referencia)\nSuper.Constructor(count);\ncount <- count + 2;\nFinMetodo\nMetodo get() Como Entero\nRetornar Super.get() + 100;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir result Como Base;\nDefinir count Como Entero;\ncount <- 3;\nresult <- Nuevo Derived(count);\nEscribir result.get(),count;\nFinAlgoritmo\n";
    policies(source, "1046\n")
}
