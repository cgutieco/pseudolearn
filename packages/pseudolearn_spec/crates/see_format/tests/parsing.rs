mod support;

#[test]
fn parses_typed_blocks_and_preserves_programs() -> Result<(), String> {
    let specification = support::specification()?;
    assert_eq!(specification.metadata.id, "LANG.TEST.SAMPLE");
    assert_eq!(specification.blocks.len(), 2);
    let rewritten = see_format::write(&specification)?;
    let reread = see_format::parsing::parse("sample.md", &rewritten)?;
    assert_eq!(specification, reread);
    Ok(())
}

#[test]
fn rejects_empty_headers_unknown_fields_and_unclosed_fences() -> Result<(), String> {
    let specification = support::specification()?;
    let text = see_format::write(&specification)?;
    assert!(see_format::parsing::parse("empty", "").is_err());
    assert!(see_format::parsing::parse("unclosed", "---\nid: X").is_err());
    assert!(see_format::parsing::parse("unknown", &text.replace("formato:", "unknown:")).is_err());
    assert!(see_format::parsing::parse("unclosed", &format!("{text}\n```regla\nid: R9")).is_err());
    assert!(
        see_format::parsing::parse("unknown", &format!("{text}\n```unknown\nid: R9\n```\n"))
            .is_err()
    );
    Ok(())
}

#[test]
fn accepts_crlf_and_yaml_sequences() -> Result<(), String> {
    let specification = support::specification()?;
    let text = see_format::write(&specification)?;
    let parsed = see_format::parsing::parse("sample.md", &text.replace('\n', "\r\n"))?;
    assert_eq!(specification, parsed);
    let text = format!("{text}\n```definicion\n- {{ id: D1, termino: uno, texto: Uno }}\n```\n");
    assert_eq!(
        see_format::parsing::parse("sequence", &text)?.blocks.len(),
        3
    );
    Ok(())
}

#[test]
fn rejects_external_documentation_links_in_prose_and_contracts() -> Result<(), String> {
    let specification = support::specification()?;
    let text = see_format::write(&specification)?;
    assert!(see_format::parsing::parse("internal", &text).is_ok());
    assert_eq!(
        see_format::parsing::parse(
            "external",
            &format!("{text}\nEnlace: www.example.com/spec\n")
        ),
        Err("SEE-REFERENCE: external documentation link forbidden".to_owned())
    );
    Ok(())
}
