use cranelift_codegen::ir::condcodes::IntCC;
use cranelift_codegen::ir::{AbiParam, Function, InstBuilder, types};
use cranelift_frontend::{FunctionBuilder, FunctionBuilderContext};

#[test]
fn dead_loop_cycles_disappear_without_changing_the_entry_signature() -> Result<(), String> {
    let mut function = Function::new();
    function.signature.params.push(AbiParam::new(types::I64));
    function.signature.returns.push(AbiParam::new(types::I64));
    let mut storage = FunctionBuilderContext::new();
    let mut builder = FunctionBuilder::new(&mut function, &mut storage);
    let entry = builder.create_block();
    let header = builder.create_block();
    let exit = builder.create_block();
    builder.append_block_params_for_function_params(entry);
    let live = builder.append_block_param(header, types::I64);
    let unused = builder.append_block_param(header, types::I64);
    builder.switch_to_block(entry);
    let zero = builder.ins().iconst(types::I64, 0);
    builder.ins().jump(header, &[zero.into(), zero.into()]);
    builder.switch_to_block(header);
    let next = builder.ins().iadd_imm_s(live, 1);
    let again = builder.ins().icmp_imm_s(IntCC::SignedLessThan, next, 10);
    builder
        .ins()
        .brif(again, header, &[next.into(), unused.into()], exit, &[]);
    builder.switch_to_block(exit);
    builder.ins().return_(&[next]);
    builder.seal_all_blocks();
    let target = crate::TargetConfig::host()
        .build_isa()
        .map_err(|error| error.to_string())?;
    builder.finalize(target.frontend_config());
    super::eliminate(&mut function);
    assert_eq!(function.dfg.block_params(entry).len(), 1);
    assert_eq!(function.dfg.block_params(header).len(), 1);
    let flags = cranelift_codegen::settings::Flags::new(cranelift_codegen::settings::builder());
    cranelift_codegen::verify_function(&function, &flags).map_err(|error| error.to_string())?;
    Ok(())
}
