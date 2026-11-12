use crate::{Operand, Operation, parse_module, suspension_points};

#[test]
fn classifies_only_operations_that_can_change_the_running_task() {
    for operation in [
        Operation::TaskAwait,
        Operation::TaskScopeJoin,
        Operation::CallSuspendible,
        Operation::EffectAwait,
        Operation::TaskYieldCheck,
    ] {
        assert!(suspension_points::can_suspend(operation, &[]));
    }
    for command in ["send", "receive", "select"] {
        assert!(suspension_points::can_suspend(
            Operation::TaskChannel,
            &[Operand::Identifier(command.to_owned())]
        ));
    }
    for command in ["new", "close", "selected_present"] {
        assert!(!suspension_points::can_suspend(
            Operation::TaskChannel,
            &[Operand::Identifier(command.to_owned())]
        ));
    }
    assert!(!suspension_points::can_suspend(Operation::TaskSpawn, &[]));
}

#[test]
fn enumerates_suspensions_in_stable_block_order() -> Result<(), String> {
    let module = parse_module(
        "module P es\nfunc suspendible @main() -> unit {\nb0() mass 0:\n%0 = task.scope_open\n%1 = task.spawn %0, @worker()\n%2 = task.await %1, i64\ntask.scope_join %0\nreturn\n}\nfunc suspendible @worker() -> i64 {\nb0() mass 0:\n%0 = const.i64 1\nreturn %0\n}\n",
    )?;
    let function = module.functions.first().ok_or("missing main")?;
    let operations: Vec<_> = suspension_points::points(function)
        .into_iter()
        .filter_map(|instruction| function.columns.operation(instruction))
        .collect();
    assert_eq!(
        operations,
        vec![Operation::TaskAwait, Operation::TaskScopeJoin]
    );
    assert!(
        suspension_points::points(&crate::Function::new(
            "@empty".to_owned(),
            crate::IrType::Unit
        ))
        .is_empty()
    );
    Ok(())
}
