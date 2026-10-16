use pseudolearn_bytecode::{
    BytecodeError, BytecodeModule, Register, RegisterClass, compile_text, verify_bytecode,
};

fn module() -> Result<BytecodeModule, BytecodeError> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"x\"\n  %1 = text.concat %0, %0 @1:1-1:2\n  %2 = text.concat %1, %0 @1:1-1:2\n  out.write %2 @1:1-1:2\n  return\n}\n";
    Ok(compile_text(source)?.module().clone())
}

#[test]
fn rejects_missing_root_and_definition_maps() -> Result<(), BytecodeError> {
    for definitions in [false, true] {
        let mut module = module()?;
        let function = module
            .functions
            .first_mut()
            .ok_or(BytecodeError::InvalidModule)?;
        if definitions {
            function.fast.definitions.clear();
        } else {
            function.fast.roots.clear();
        }
        assert!(verify_bytecode(&module).is_err());
    }
    Ok(())
}

#[test]
fn rejects_root_classes_offsets_and_duplicate_entries() -> Result<(), BytecodeError> {
    for root in [
        Register {
            class: RegisterClass::Scalar,
            index: 0,
        },
        Register {
            class: RegisterClass::Reference,
            index: u16::MAX,
        },
    ] {
        let mut module = module()?;
        let function = module
            .functions
            .first_mut()
            .ok_or(BytecodeError::InvalidModule)?;
        let roots = function
            .fast
            .roots
            .values_mut()
            .next()
            .ok_or(BytecodeError::InvalidModule)?;
        roots.push(root);
        assert!(verify_bytecode(&module).is_err());
    }
    let mut module = module()?;
    let function = module
        .functions
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    function.fast.roots.insert(u32::MAX, Vec::new());
    assert!(verify_bytecode(&module).is_err());
    Ok(())
}

#[test]
fn live_temporaries_expire_after_their_last_use() -> Result<(), BytecodeError> {
    let module = module()?;
    let function = module
        .functions
        .first()
        .ok_or(BytecodeError::InvalidModule)?;
    let points = function.fast.roots.values().collect::<Vec<_>>();
    assert_eq!(points.len(), 2);
    assert_eq!(points.first().map(|roots| roots.len()), Some(0));
    assert_eq!(points.last().map(|roots| roots.len()), Some(1));
    assert_eq!(verify_bytecode(&module), Ok(()));
    Ok(())
}
