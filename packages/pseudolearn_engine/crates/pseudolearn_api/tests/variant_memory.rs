use pseudolearn_runtime::{CollectionPolicy, MemoryOptions};
use pseudolearn_vm::{Fuel, RunExit, RunOptions, TwinMode};

#[test]
fn switching_away_from_reference_payloads_clears_inactive_roots_in_both_twins() -> Result<(), String>
{
    let program = "class Holder\ndefine amount as integer;\nendClass\nsubroutine Fetch() as result<integer, Holder>\nreturn failure(new Holder());\nendSubroutine\nalgorithm Main\ndefine mutable outcome as result<integer, Holder> <- Fetch();\ndiscard outcome;\noutcome <- success(9);\ndefine keeper as Holder <- new Holder();\nkeeper.amount <- 7;\nswitch outcome do\nsuccess(number): write number;\nfailure(problem): write problem.amount;\nendSwitch\nwrite keeper.amount;\nendAlgorithm\n";
    let module = pseudolearn_api::compile_source_to_module(program, "en", "strict")
        .map_err(|errors| format!("{errors:?}"))?;
    let bytecode =
        pseudolearn_bytecode::compile_module(&module).map_err(|failure| format!("{failure:?}"))?;
    let loaded = pseudolearn_vm::load(&bytecode).map_err(|failure| format!("{failure:?}"))?;
    for twin_mode in [TwinMode::Fast, TwinMode::Probed] {
        let options = RunOptions {
            twin_mode,
            memory: MemoryOptions {
                cells: 64,
                collection: CollectionPolicy::Forced,
                collection_minimum: 1,
            },
            ..RunOptions::default()
        };
        let result = pseudolearn_vm::run_with_options(&loaded, Fuel::unlimited(), options);
        assert!(matches!(result.exit, RunExit::Completed(_)), "{result:?}");
        assert_eq!(result.output, "9\n7\n");
    }
    Ok(())
}
