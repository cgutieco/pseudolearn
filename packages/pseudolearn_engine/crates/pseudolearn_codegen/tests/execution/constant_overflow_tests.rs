use crate::support::{
    Call, Failure, Kind, Signature, build_harness, expect_fault, expect_value, no_patch,
};

#[test]
fn constant_overflow_specializations_match_checked_arithmetic_at_both_extremes()
-> Result<(), Failure> {
    let constants = [i64::MIN, -7, -1, 0, 1, 7, i64::MAX];
    let mut module = String::from("module P es\n");
    let mut cases = Vec::new();
    for constant in constants {
        for operation in ["add", "sub"] {
            for constant_left in [false, true] {
                let number = cases.len();
                let operands = if constant_left { "%1, %0" } else { "%0, %1" };
                module.push_str(&format!("func @case_{number}(%0: i64) -> i64 {{\nb0() mass 0:\n  %1 = const.i64 {constant}\n  %2 = int.{operation} {operands} @3:1-3:5\n  return %2\n}}\n"));
                cases.push((constant, operation, constant_left));
            }
        }
    }
    let signatures: Vec<_> = cases
        .iter()
        .map(|_| Signature {
            parameters: vec![Kind::Integer],
            returns: Kind::Integer,
        })
        .collect();
    let harness = build_harness(&module, (&signatures, no_patch))?;
    for (function, (constant, operation, constant_left)) in cases.into_iter().enumerate() {
        for input in [
            i64::MIN,
            i64::MIN + 1,
            -8,
            -1,
            0,
            1,
            8,
            i64::MAX - 1,
            i64::MAX,
        ] {
            let (left, right) = if constant_left {
                (constant, input)
            } else {
                (input, constant)
            };
            let expected = if operation == "add" {
                left.checked_add(right)
            } else {
                left.checked_sub(right)
            };
            let outcome = harness.run(&Call::with(function, &[&input.to_string()]))?;
            match expected {
                Some(value) => expect_value(&outcome, &value.to_string())?,
                None => expect_fault(&outcome, 1, "integerOverflow", "3:1-3:5")?,
            }
        }
    }
    Ok(())
}
