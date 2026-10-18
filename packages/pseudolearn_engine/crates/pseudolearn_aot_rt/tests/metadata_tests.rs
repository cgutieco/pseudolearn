use pseudolearn_aot_rt::*;

fn sample() -> ExecutableMetadata {
    ExecutableMetadata {
        settings: ExecutableSettings {
            source_name: "p.pseudo".to_owned(),
            locale: "es".to_owned(),
            seed: -7,
            forced_collection: true,
            limits: AotLimits {
                frames: 12,
                instruction_units: Some(99),
                cells: 5,
                root_capacity: 8,
            },
            boolean_words: BooleanWords {
                truth: "Verdadero".to_owned(),
                falsity: "Falso".to_owned(),
            },
            error_template: "{path}:{line}:{column}\n".to_owned(),
            warning_template: "{path}:{line}:{column}: warning: {message} [{code}]\n".to_owned(),
            information_template: "{path}:{line}:{column}: info: {message} [{code}]\n".to_owned(),
            exhausted_template: "{path}\n".to_owned(),
        },
        sites: vec![FaultSite {
            lexeme: "sourceName".to_owned(),
            code: DiagnosticCode::InternalFault,
            range: SourceRange {
                start_line: 1,
                start_column: 2,
                end_line: 3,
                end_column: 4,
            },
        }],
        classes: vec![
            ClassDescriptor {
                fields: vec![KIND_INTEGER, KIND_REFERENCE],
                dense: true,
            },
            ClassDescriptor {
                fields: Vec::new(),
                dense: false,
            },
        ],
    }
}

#[test]
fn encoded_metadata_decodes_to_the_same_value() -> Result<(), String> {
    let metadata = sample();
    assert_eq!(decode_metadata(&encode_metadata(&metadata)), Some(metadata));
    Ok(())
}

#[test]
fn metadata_without_budget_keeps_the_budget_absent() -> Result<(), String> {
    let mut metadata = sample();
    metadata.settings.limits.instruction_units = None;
    metadata.sites.clear();
    metadata.classes.clear();
    assert_eq!(decode_metadata(&encode_metadata(&metadata)), Some(metadata));
    Ok(())
}

#[test]
fn every_truncation_of_the_encoding_is_rejected() -> Result<(), String> {
    let bytes = encode_metadata(&sample());
    for count in 0..bytes.len() {
        let prefix = bytes.get(..count).ok_or("prefix out of range")?;
        assert_eq!(decode_metadata(prefix), None, "prefix {count}");
    }
    Ok(())
}

#[test]
fn trailing_bytes_and_wrong_magic_are_rejected() -> Result<(), String> {
    let mut bytes = encode_metadata(&sample());
    bytes.push(0);
    assert_eq!(decode_metadata(&bytes), None);
    let mut wrong = encode_metadata(&sample());
    *wrong.first_mut().ok_or("empty encoding")? = b'X';
    assert_eq!(decode_metadata(&wrong), None);
    Ok(())
}

#[test]
fn unknown_diagnostic_names_are_rejected() -> Result<(), String> {
    let bytes = encode_metadata(&sample());
    let name = DiagnosticCode::InternalFault.as_str().as_bytes();
    let position = bytes
        .windows(name.len())
        .position(|window| window == name)
        .ok_or("code name not found")?;
    let mut corrupted = bytes.clone();
    *corrupted.get_mut(position).ok_or("position out of range")? = b'#';
    assert_eq!(decode_metadata(&corrupted), None);
    Ok(())
}

#[test]
fn the_exported_main_rejects_missing_metadata() -> Result<(), String> {
    extern "C" fn nothing(_context: *mut AotRuntimeContext) {}
    assert_eq!(
        pseudolearn_aot_main(nothing, std::ptr::null(), 4),
        EXIT_INTERNAL
    );
    let garbage = [1u8, 2, 3];
    assert_eq!(
        pseudolearn_aot_main(nothing, garbage.as_ptr(), garbage.len()),
        EXIT_INTERNAL
    );
    Ok(())
}
