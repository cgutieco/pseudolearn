use pseudolearn_abi::{EffectValueKind, effect_operation, find_effect_operation};

const DIRECTORY_OPERATIONS: [(&str, &str, &str, usize, EffectValueKind); 6] = [
    (
        "directory_exists",
        "Existe",
        "exists",
        1,
        EffectValueKind::Boolean,
    ),
    (
        "directory_is_directory",
        "EsDirectorio",
        "isDirectory",
        1,
        EffectValueKind::Boolean,
    ),
    (
        "directory_list",
        "Listar",
        "list",
        1,
        EffectValueKind::TextList,
    ),
    (
        "directory_delete",
        "Borrar",
        "delete",
        1,
        EffectValueKind::Boolean,
    ),
    (
        "directory_rename",
        "Renombrar",
        "rename",
        2,
        EffectValueKind::Boolean,
    ),
    (
        "directory_create",
        "CrearDirectorio",
        "createDirectory",
        1,
        EffectValueKind::Boolean,
    ),
];

#[test]
fn directory_operations_are_effectful_fallible_and_filesystem_scoped() -> Result<(), String> {
    for (identity, spanish, english, arity, result) in DIRECTORY_OPERATIONS {
        let operation = effect_operation(identity).ok_or_else(|| identity.to_owned())?;
        assert_eq!(
            operation.receiver,
            Some(EffectValueKind::Directory),
            "{identity}"
        );
        assert_eq!(operation.parameters.len(), arity, "{identity}");
        assert!(
            operation
                .parameters
                .iter()
                .all(|kind| *kind == EffectValueKind::Text)
        );
        assert_eq!(operation.result, result, "{identity}");
        assert!(operation.effect && operation.fallible, "{identity}");
        assert_eq!(operation.capability_family(), "filesystem", "{identity}");
        let by_spanish = find_effect_operation(spanish, true, Some(EffectValueKind::Directory));
        let by_english = find_effect_operation(english, false, Some(EffectValueKind::Directory));
        assert_eq!(by_spanish.map(|found| found.identity), Some(identity));
        assert_eq!(by_english.map(|found| found.identity), Some(identity));
    }
    Ok(())
}

#[test]
fn append_operations_belong_to_the_file_receiver_and_return_the_byte_count() -> Result<(), String> {
    for (identity, parameter) in [
        ("file_append_text", EffectValueKind::Text),
        ("file_append_bytes", EffectValueKind::Bytes),
    ] {
        let operation = effect_operation(identity).ok_or_else(|| identity.to_owned())?;
        assert_eq!(operation.receiver, Some(EffectValueKind::File));
        assert_eq!(operation.parameters, [parameter]);
        assert_eq!(operation.result, EffectValueKind::Integer);
        assert!(operation.effect && operation.fallible);
        assert_eq!(operation.capability_family(), "filesystem");
    }
    Ok(())
}

#[test]
fn directory_names_do_not_resolve_on_other_receivers() {
    assert!(find_effect_operation("Listar", true, Some(EffectValueKind::File)).is_none());
    assert!(find_effect_operation("Listar", true, None).is_none());
    assert!(find_effect_operation("appendText", false, Some(EffectValueKind::Directory)).is_none());
}
