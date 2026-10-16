use pseudolearn_bytecode::{
    BytecodeError, BytecodeModule, ValueType, compile_text, verify_bytecode,
};

fn module(source: &str) -> Result<BytecodeModule, BytecodeError> {
    Ok(compile_text(source)?.module().clone())
}

#[test]
fn rejects_missing_and_cyclic_superclass_metadata() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let mut missing = module(source)?;
    missing
        .classes
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)?
        .superclass = Some("Missing".to_owned());
    assert_eq!(verify_bytecode(&missing), Err(BytecodeError::InvalidModule));

    let mut cycle = module(source)?;
    cycle
        .classes
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?
        .superclass = Some("Derived".to_owned());
    assert_eq!(verify_bytecode(&cycle), Err(BytecodeError::InvalidModule));
    Ok(())
}

#[test]
fn rejects_inherited_field_layout_and_reference_metadata() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base { name: str, value: i64 }\nclass Derived : Base { extra: str }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let mut reordered = module(source)?;
    let fields = &mut reordered
        .classes
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)?
        .fields;
    fields.swap(0, 1);
    assert_eq!(
        verify_bytecode(&reordered),
        Err(BytecodeError::InvalidModule)
    );

    let mut references = module(source)?;
    references
        .classes
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?
        .references
        .clear();
    assert_eq!(
        verify_bytecode(&references),
        Err(BytecodeError::InvalidModule)
    );

    let mut duplicate_field = module(source)?;
    let base = duplicate_field
        .classes
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?;
    base.fields.push(("name".to_owned(), ValueType::I64));
    assert_eq!(
        verify_bytecode(&duplicate_field),
        Err(BytecodeError::InvalidModule)
    );

    let mut unknown_field_type = module(source)?;
    unknown_field_type
        .classes
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?
        .fields
        .push((
            "missing".to_owned(),
            ValueType::Object("Missing".to_owned()),
        ));
    assert_eq!(
        verify_bytecode(&unknown_field_type),
        Err(BytecodeError::InvalidModule)
    );
    Ok(())
}

#[test]
fn rejects_method_targets_with_missing_or_unrelated_receivers() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nclass Other {}\nfunc @base(%0: obj<Base>) -> unit {\nb0() mass 0:\n  return\n}\nfunc @other(%0: obj<Other>) -> unit {\nb0() mass 0:\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let mut missing = module(source)?;
    missing
        .classes
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?
        .methods
        .insert("run".to_owned(), u16::MAX);
    assert_eq!(verify_bytecode(&missing), Err(BytecodeError::InvalidModule));

    let mut unrelated = module(source)?;
    unrelated
        .classes
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)?
        .methods
        .insert("run".to_owned(), 1);
    assert_eq!(
        verify_bytecode(&unrelated),
        Err(BytecodeError::InvalidModule)
    );

    let mut inherited = module(source)?;
    inherited
        .classes
        .first_mut()
        .ok_or(BytecodeError::InvalidModule)?
        .methods
        .insert("run".to_owned(), 0);
    inherited
        .classes
        .get_mut(1)
        .ok_or(BytecodeError::InvalidModule)?
        .methods
        .insert("run".to_owned(), 0);
    assert_eq!(verify_bytecode(&inherited), Ok(()));
    Ok(())
}

#[test]
fn rejects_duplicate_class_names() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let mut candidate = module(source)?;
    let class = candidate
        .classes
        .first()
        .cloned()
        .ok_or(BytecodeError::InvalidModule)?;
    candidate.classes.push(class);
    assert_eq!(
        verify_bytecode(&candidate),
        Err(BytecodeError::InvalidModule)
    );
    Ok(())
}

#[test]
fn accepts_empty_method_table() -> Result<(), BytecodeError> {
    let source = "module P es\nclass Base {}\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let candidate = module(source)?;
    assert!(
        candidate
            .classes
            .first()
            .is_some_and(|class| class.methods.is_empty())
    );
    assert_eq!(verify_bytecode(&candidate), Ok(()));
    Ok(())
}
