use pseudolearn_abi::{ClosureLayout, RecordBank, RecordLayout};

#[test]
fn separates_code_identity_from_environment_and_flattens_capture_roots() -> Result<(), String> {
    let first = RecordLayout::from_banks(&[RecordBank::Reference, RecordBank::Scalar])
        .map_err(|error| format!("{error:?}"))?;
    let second =
        RecordLayout::from_banks(&[RecordBank::Reference]).map_err(|error| format!("{error:?}"))?;
    let layout =
        ClosureLayout::from_captures(&[first, second]).map_err(|error| format!("{error:?}"))?;
    assert_eq!(layout.value().scalar_words(), 1);
    assert_eq!(layout.value().reference_words(), 1);
    assert_eq!(layout.environment().scalar_words(), 1);
    assert_eq!(layout.environment().reference_words(), 2);
    assert_eq!(layout.field(0), Some(1));
    assert_eq!(layout.field(1), Some(0));
    assert_eq!(layout.field(2), Some(2));
    assert_eq!(layout.field(3), None);
    Ok(())
}

#[test]
fn accepts_no_capture_and_rejects_an_oversized_environment() -> Result<(), String> {
    let empty = ClosureLayout::from_captures(&[]).map_err(|error| format!("{error:?}"))?;
    assert_eq!(empty.environment().leaf_count(), 0);
    assert_eq!(empty.field(0), None);
    let maximum = RecordLayout::from_banks(&vec![RecordBank::Scalar; 65_535])
        .map_err(|error| format!("{error:?}"))?;
    assert!(ClosureLayout::from_captures(&[maximum.clone()]).is_ok());
    assert!(ClosureLayout::from_captures(&[maximum.clone(), maximum]).is_err());
    Ok(())
}
