#[path = "support/fixture.rs"]
mod fixture;

#[test]
fn accepts_safe_source_without_rows() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    assert!(
        pseudolearn_checks::safety::check(&fixture.source()?, &fixture.rules()?, &fixture.root)?
            .is_empty()
    );
    Ok(())
}

#[test]
fn rejects_unsafe_without_permission_or_row() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    std::fs::write(
        fixture.root.join("subject/src/lib.rs"),
        include_str!("../../../fixtures/unsafe.rs.txt"),
    )?;
    assert!(
        !pseudolearn_checks::safety::check(&fixture.source()?, &fixture.rules()?, &fixture.root)?
            .is_empty()
    );
    Ok(())
}

#[test]
fn accepts_documented_short_unsafe_function() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    std::fs::write(
        fixture.root.join("subject/src/lib.rs"),
        "unsafe fn read_verified_slot() {}",
    )?;
    std::fs::write(
        fixture.root.join("subject/README.md"),
        "# Subject\n## Invariantes de `unsafe`\n| `read_verified_slot` | Valid slot | Caller validates |\n",
    )?;
    let mut rules = fixture.rules()?;
    rules
        .layers
        .first_mut()
        .ok_or("Missing layer")?
        .unsafe_allowed = true;
    assert!(
        pseudolearn_checks::safety::check(&fixture.source()?, &rules, &fixture.root)?.is_empty()
    );
    assert!(
        pseudolearn_checks::safety::check_orphan_rows(&[fixture.source()?], &rules, &fixture.root)?
            .is_empty()
    );
    Ok(())
}

#[test]
fn rejects_orphan_invariant_row() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = fixture::Fixture::create()?;
    std::fs::write(
        fixture.root.join("subject/README.md"),
        "# Subject\n## Invariantes de `unsafe`\n| `read_verified_slot` | Valid slot | Caller validates |\n",
    )?;
    assert!(
        !pseudolearn_checks::safety::check_orphan_rows(
            &[fixture.source()?],
            &fixture.rules()?,
            &fixture.root
        )?
        .is_empty()
    );
    Ok(())
}
