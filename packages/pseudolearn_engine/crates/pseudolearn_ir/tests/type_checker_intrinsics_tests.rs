use pseudolearn_ir::{parse_module, verify_module};

fn verify(source_text: &str) -> Result<(), &'static str> {
    match parse_module(source_text) {
        Ok(module) => verify_module(&module),
        Err(_) => Err("parse"),
    }
}

#[test]
fn infers_real_results_for_mathematical_intrinsics() {
    for name in ["sqrt", "abs", "ln", "exp", "sin", "cos", "atan"] {
        let source = format!(
            "module P es\nfunc @main() -> f64 {{\nb0() mass 0:\n  %0 = const.f64 2.0\n  %1 = math.{name} %0 @1:1-1:2\n  %2 = real.add %1, %0 @1:1-1:2\n  return %2\n}}\n"
        );
        assert_eq!(verify(&source), Ok(()), "{name}");
    }
}

#[test]
fn infers_character_code_conversions() {
    let source = "module P es\nfunc @main() -> char {\nb0() mass 0:\n  %0 = const.char 'a'\n  %1 = char.code %0 @1:1-1:2\n  %2 = char.from_code %1 @1:1-1:2\n  return %2\n}\n";
    assert_eq!(verify(source), Ok(()));
}

#[test]
fn rejects_an_integer_argument_to_a_mathematical_intrinsic() {
    let source = "module P es\nfunc @main() -> f64 {\nb0() mass 0:\n  %0 = const.i64 2\n  %1 = math.ln %0 @1:1-1:2\n  return %1\n}\n";
    assert_eq!(verify(source), Err("IR.WELL-FORMEDNESS#R3"));
}

#[test]
fn rejects_a_real_argument_to_character_from_code() {
    let source = "module P es\nfunc @main() -> char {\nb0() mass 0:\n  %0 = const.f64 65.0\n  %1 = char.from_code %0 @1:1-1:2\n  return %1\n}\n";
    assert_eq!(verify(source), Err("IR.WELL-FORMEDNESS#R3"));
}
