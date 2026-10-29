use pseudolearn_bytecode::compile_text;

use super::load;

#[test]
fn task_free_bytecode_does_not_enable_task_runtime() {
    let source =
        "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 42\n  return %0\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok());
    let Some(bytecode) = compiled.ok() else {
        return;
    };
    let loaded = load(&bytecode);
    assert!(loaded.is_ok());
    let Some(loaded) = loaded.ok() else {
        return;
    };
    assert!(!loaded.uses_task_runtime());
    assert_eq!(loaded.inner.functions.len(), 1);
    let Some(function) = loaded.inner.functions.first() else {
        return;
    };
    assert!(function.task_operations.is_empty());
    assert!(function.task_operation_indices.is_empty());
    assert!(function.probed_task_operation_indices.is_empty());
}

#[test]
fn task_bytecode_enables_task_runtime() {
    let source = "module P es\nfunc suspendible @main() -> unit {\nb0() mass 0:\n %0 = const.str \"kept\" @1:1-1:5\n %1 = task.scope_open @1:1-1:5\n %2 = task.spawn %1, @worker() @2:1-2:5\n %3 = task.await %2, i64 @3:1-3:5\n task.scope_join %1 @4:1-4:5\n out.write %0, newline @5:1-5:5\n out.write %3, newline @6:1-6:5\n return\n}\nfunc suspendible @worker() -> i64 {\nb0() mass 0:\n %0 = const.i64 42\n return %0\n}\n";
    let compiled = compile_text(source);
    assert!(compiled.is_ok());
    let Some(bytecode) = compiled.ok() else {
        return;
    };
    let loaded = load(&bytecode);
    assert!(loaded.is_ok());
    let Some(loaded) = loaded.ok() else {
        return;
    };
    assert!(loaded.uses_task_runtime());
    assert_eq!(loaded.inner.functions.len(), 2);
    let Some(function) = loaded.inner.functions.first() else {
        return;
    };
    assert!(!function.task_operations.is_empty());
    assert!(function.task_operation(0, false).is_some());
    assert!(function.task_operation(0, true).is_some());
}
