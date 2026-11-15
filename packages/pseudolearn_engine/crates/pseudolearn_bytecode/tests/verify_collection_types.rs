use pseudolearn_bytecode::{BytecodeOperand, Opcode, compile_text, verify_bytecode};

#[test]
fn validates_collection_instructions_and_rejects_wrong_leaf_ordinal() -> Result<(), String> {
    let source = "module P es\nclass \"$vector<integer>\" { \"$leaf:value\": i64 }\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = collection.new obj<\"$vector<integer>\"> @1:1-1:2\n  %1 = const.i64 0\n  %2 = collection.load i64, %0, %1, 0 @1:1-1:2\n  return\n}\n";
    let compiled = compile_text(source).map_err(|error| format!("{error:?}"))?;
    let mut module = compiled.module().clone();
    assert_eq!(verify_bytecode(&module), Ok(()));
    let function = module.functions.first_mut().ok_or("missing function")?;
    let ordinal = u16::try_from(function.constants.len()).map_err(|error| error.to_string())?;
    function
        .constants
        .push(pseudolearn_bytecode::Constant::I64(1));
    let instruction = function
        .fast
        .instructions
        .iter_mut()
        .find(|instruction| instruction.opcode == Opcode::CollectionLoad)
        .ok_or("missing load")?;
    let operand = instruction
        .operands
        .get_mut(3)
        .ok_or("missing leaf ordinal")?;
    *operand = BytecodeOperand::Constant(ordinal);
    assert!(verify_bytecode(&module).is_err());
    Ok(())
}
