use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, RunExit, run};

#[test]
fn writes_integer_output_with_one_newline() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 42\n  out.write %0, newline @3:1-3:12\n  return\n}\n";
    let bytecode = compile_text(source_text);
    assert!(bytecode.is_ok());
    let Some(verified) = bytecode.ok() else {
        return;
    };
    let result = run(&verified, Fuel::unlimited());
    assert_eq!(result.exit, RunExit::Completed(None));
    assert_eq!(result.output, "42\n");
}

#[test]
fn rejects_output_without_a_value() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  out.write newline @3:1-3:12\n  return\n}\n";
    let bytecode = compile_text(source_text);
    assert!(bytecode.is_err());
}

#[test]
fn boolean_words_follow_the_profile_and_default_to_spanish() {
    assert_eq!(pseudolearn_vm::boolean_words("en"), ("true", "false"));
    assert_eq!(pseudolearn_vm::boolean_words("es"), ("Verdadero", "Falso"));
    assert_eq!(pseudolearn_vm::boolean_words("zz"), ("Verdadero", "Falso"));
}
