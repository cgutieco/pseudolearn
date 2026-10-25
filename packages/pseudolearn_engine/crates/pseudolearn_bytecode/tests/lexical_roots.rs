use pseudolearn_bytecode::compile_module;
use pseudolearn_ir::{IrSpan, ValueId, VariableId, parse_module};

#[test]
fn lexical_roots_expire_in_both_twins_while_live_temporaries_survive() -> Result<(), String> {
    let text = "module P es\nfunc @visit() -> unit {\nb0() mass 0:\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"owned\"\n  call @visit() @3:1-3:8\n  call @visit() @6:1-6:8\n  return\n}\n";
    let mut module = parse_module(text).map_err(|error| error.to_string())?;
    module
        .origins
        .record(ValueId(0), VariableId(0), "value".to_owned());
    let origin = module.origins.entries.first_mut().ok_or("missing origin")?;
    origin.function = "@main".to_owned();
    origin.visibility = Some(IrSpan::new(2, 1, 5, 1));
    let compiled = compile_module(&module).map_err(|error| format!("{error:?}"))?;
    let function = compiled.module().functions.get(1).ok_or("missing main")?;
    for variant in [&function.fast, &function.probed] {
        let roots: Vec<_> = variant.roots.values().map(Vec::len).collect();
        assert_eq!(roots, vec![1, 0]);
    }
    Ok(())
}
