use reference_model::Profile;
use reference_resolve::AliasTable;

fn table() -> AliasTable {
    AliasTable::from_json(r#"[{"es": "FinFuncion", "en": "End Function"}]"#).unwrap_or_default()
}

#[test]
fn translates_an_alias_in_both_directions() {
    let aliases = table();
    assert_eq!(
        aliases.translate("FinFuncion", Profile::Spanish, Profile::English),
        Some("End Function")
    );
    assert_eq!(
        aliases.translate("End Function", Profile::English, Profile::Spanish),
        Some("FinFuncion")
    );
    assert!(aliases.contains("FinFuncion", Profile::Spanish));
}

#[test]
fn ignores_unknown_spellings_and_other_profiles() {
    let aliases = table();
    assert_eq!(
        aliases.translate("FinSubProceso", Profile::Spanish, Profile::English),
        None
    );
    assert!(!aliases.contains("FinFuncion", Profile::English));
    assert!(!AliasTable::default().contains("", Profile::Spanish));
}

#[test]
fn rejects_a_malformed_table() {
    assert!(AliasTable::from_json(r#"[{"es": "Funcion"}]"#).is_err());
    assert!(AliasTable::from_json("{").is_err());
    assert!(AliasTable::from_json("[]").is_ok());
}
