use pseudolearn_bytecode::{
    BytecodeModule, BytecodeOperand, Constant, Opcode, compile_module, verify_bytecode,
};
use pseudolearn_ir::parse_module;

fn fixture() -> Result<BytecodeModule, String> {
    let source = "module P en\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  switch %0, b1(), 0, b1(), 1, b1()\nb1() mass 0:\n  return\n}\n";
    let module = parse_module(source).map_err(|failure| format!("{failure:?}"))?;
    compile_module(&module)
        .map(|verified| verified.module().clone())
        .map_err(|failure| format!("{failure:?}"))
}

#[test]
fn validates_dense_switches_before_loading() -> Result<(), String> {
    let module = fixture()?;
    assert_eq!(verify_bytecode(&module), Ok(()));
    Ok(())
}

#[test]
fn rejects_out_of_range_ordinals_and_malformed_selectors() -> Result<(), String> {
    for ordinal in [-1, 65_536] {
        let mut module = fixture()?;
        let function = module.functions.first_mut().ok_or("missing function")?;
        let index =
            u16::try_from(function.constants.len()).map_err(|failure| failure.to_string())?;
        function.constants.push(Constant::I64(ordinal));
        let instruction = function
            .fast
            .instructions
            .iter_mut()
            .find(|instruction| instruction.opcode == Opcode::Switch)
            .ok_or("missing switch")?;
        *instruction.operands.get_mut(2).ok_or("missing ordinal")? =
            BytecodeOperand::Constant(index);
        assert!(verify_bytecode(&module).is_err());
    }
    let mut module = fixture()?;
    let function = module.functions.first_mut().ok_or("missing function")?;
    let instruction = function
        .fast
        .instructions
        .iter_mut()
        .find(|instruction| instruction.opcode == Opcode::Switch)
        .ok_or("missing switch")?;
    instruction.operands.remove(0);
    assert!(verify_bytecode(&module).is_err());
    Ok(())
}
