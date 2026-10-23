use pseudolearn_project::{
    Configuration, HostGrants, ManifestError, ManifestErrorCode, ManifestRequest, PackageKind,
    ProfileChoice, Provenance,
};

const MINIMAL: &str = "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n";
const BUDGET: usize = 65_536;

fn resolve_with(
    text: &str,
    location: &str,
    budget: usize,
) -> Result<Configuration, Vec<ManifestError>> {
    let grants = HostGrants::default();
    Configuration::resolve(&ManifestRequest {
        text,
        location,
        grants: &grants,
        max_bytes: budget,
    })
}

fn resolve(text: &str) -> Result<Configuration, Vec<ManifestError>> {
    resolve_with(text, "geo", BUDGET)
}

fn failures(text: &str) -> Vec<(ManifestErrorCode, String, usize, usize)> {
    match resolve(text) {
        Ok(_) => Vec::new(),
        Err(errors) => errors
            .into_iter()
            .map(|error| {
                (
                    error.code,
                    error.field,
                    error.position.line,
                    error.position.column,
                )
            })
            .collect(),
    }
}

fn only(text: &str, code: ManifestErrorCode, field: &str, line: usize, column: usize) {
    assert_eq!(failures(text), [(code, field.to_owned(), line, column)]);
}

#[test]
fn minimal_manifest_gets_defaults_and_provenance() -> Result<(), String> {
    let configuration = resolve(MINIMAL).map_err(|errors| format!("{errors:?}"))?;
    let manifest = &configuration.manifest;
    assert_eq!(manifest.name.value, "geo");
    assert_eq!(manifest.kind.value, PackageKind::Library);
    assert_eq!(manifest.profile.value, ProfileChoice::Spanish);
    assert_eq!(manifest.profile.provenance, Provenance::Default);
    assert!(manifest.entries.value.is_empty());
    assert_eq!(configuration.root, "geo");
    Ok(())
}

#[test]
fn full_manifest_resolves_every_section() -> Result<(), String> {
    let text = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nprofile = \"en\"\nentries = [\n  \"app/main\", # entry\n]\n[profiles]\n\"app/legacy\" = \"es\"\n[dependencies]\ngeo = { package = \"geo\" }\n";
    let configuration =
        resolve_with(text, "app", BUDGET).map_err(|errors| format!("{errors:?}"))?;
    let manifest = configuration.manifest;
    assert_eq!(manifest.entries.value, ["app/main"]);
    assert_eq!(manifest.profile.value, ProfileChoice::English);
    assert_eq!(manifest.profiles.len(), 1);
    assert_eq!(manifest.dependencies.len(), 1);
    Ok(())
}

#[test]
fn escapes_unicode_crlf_and_bom_are_accepted() -> Result<(), String> {
    let text = "\u{feff}schema = 1\r\n[package]\r\nname = \"g\\u00e9o\\t\\\"x\\\\\"\r\nkind = \"library\"\r\n";
    let configuration = resolve(text).map_err(|errors| format!("{errors:?}"))?;
    assert_eq!(configuration.manifest.name.value, "géo\t\"x\\");
    Ok(())
}

#[test]
fn empty_and_comment_only_texts_are_empty_manifests() {
    for text in ["", "   \n\t\n", "# only a comment\n\n"] {
        only(text, ManifestErrorCode::ManifestEmpty, "", 1, 1);
    }
}

#[test]
fn syntax_errors_carry_their_position() {
    only("schema 1\n", ManifestErrorCode::ManifestSyntax, "", 1, 8);
    only(
        "schema = 1\n[package\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        2,
        9,
    );
    only(
        "schema = 01\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        1,
        10,
    );
    only(
        "schema = 1.5\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        1,
        11,
    );
    only(
        "schema = true\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        1,
        10,
    );
    only(
        "schema = \"a\nb\"\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        1,
        12,
    );
    only(
        "schema = \"\\q\"\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        1,
        12,
    );
    only(
        "schema = 99999999999999999999\n",
        ManifestErrorCode::ManifestSyntax,
        "",
        1,
        10,
    );
    only("a.b = 1\n", ManifestErrorCode::ManifestSyntax, "", 1, 2);
}

#[test]
fn duplicates_are_reported_with_the_second_occurrence() {
    only(
        "schema = 1\nschema = 1\n",
        ManifestErrorCode::DuplicateKey,
        "schema",
        2,
        1,
    );
    let table_twice = "schema = 1\n[package]\nname = \"a\"\n[package]\n";
    only(
        table_twice,
        ManifestErrorCode::DuplicateKey,
        "package",
        4,
        1,
    );
    let inline_twice = "schema = 1\n[dependencies]\ng = { package = \"a\", package = \"b\" }\n";
    only(
        inline_twice,
        ManifestErrorCode::DuplicateKey,
        "package",
        3,
        22,
    );
}

#[test]
fn unknown_fields_never_select_an_edition_or_language() {
    let text = "schema = 1\nedition = \"2027\"\n[package]\nname = \"a\"\nkind = \"library\"\nlanguage = \"es\"\n[ui]\nlocale = \"es\"\n";
    let found: Vec<_> = failures(text).into_iter().map(|error| error.1).collect();
    assert_eq!(found, ["edition", "package.language", "ui"]);
}

#[test]
fn schema_version_is_checked() {
    let package = "[package]\nname = \"a\"\nkind = \"library\"\n";
    only(
        &format!("schema = 2\n{package}"),
        ManifestErrorCode::UnsupportedSchema,
        "schema",
        1,
        10,
    );
    only(package, ManifestErrorCode::MissingField, "schema", 1, 1);
    only(
        &format!("schema = \"1\"\n{package}"),
        ManifestErrorCode::InvalidValue,
        "schema",
        1,
        10,
    );
}

#[test]
fn missing_required_fields_point_at_their_table() {
    only(
        "schema = 1\n[package]\nkind = \"library\"\n",
        ManifestErrorCode::MissingField,
        "package.name",
        2,
        1,
    );
    only(
        "schema = 1\n[package]\nname = \"a\"\n",
        ManifestErrorCode::MissingField,
        "package.kind",
        2,
        1,
    );
    only(
        "schema = 1\n",
        ManifestErrorCode::MissingField,
        "package",
        1,
        1,
    );
}

#[test]
fn invalid_values_are_rejected_by_field() {
    let head = "schema = 1\n[package]\nname = \"a\"\n";
    only(
        &format!("{head}kind = \"service\"\n"),
        ManifestErrorCode::InvalidValue,
        "package.kind",
        4,
        8,
    );
    only(
        &format!("{head}kind = 3\n"),
        ManifestErrorCode::InvalidValue,
        "package.kind",
        4,
        8,
    );
    let profile = format!("{head}kind = \"library\"\nprofile = \"fr\"\n");
    only(
        &profile,
        ManifestErrorCode::InvalidValue,
        "package.profile",
        5,
        11,
    );
    only(
        "schema = 1\n[package]\nname = \"\"\nkind = \"library\"\n",
        ManifestErrorCode::InvalidValue,
        "package.name",
        3,
        8,
    );
}

#[test]
fn paths_must_be_logical_and_under_the_root() {
    let head = "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n";
    let entries = format!("{head}entries = [\"../x\", \"otra/main\", \"geo\", \"geo/ok\"]\n");
    let found = failures(&entries);
    let fields: Vec<_> = found.iter().map(|error| error.1.as_str()).collect();
    assert_eq!(
        fields,
        [
            "package.entries[0]",
            "package.entries[1]",
            "package.entries[2]"
        ]
    );
    assert!(
        found
            .iter()
            .all(|error| error.0 == ManifestErrorCode::InvalidPath)
    );
    let profiles = format!("{head}[profiles]\n\"/abs\" = \"es\"\n");
    only(
        &profiles,
        ManifestErrorCode::InvalidPath,
        "profiles./abs",
        6,
        1,
    );
}

#[test]
fn dependencies_need_a_package_name() {
    let head = "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[dependencies]\n";
    only(
        &format!("{head}g = {{ }}\n"),
        ManifestErrorCode::MissingField,
        "dependencies.g.package",
        6,
        5,
    );
    only(
        &format!("{head}g = \"geo\"\n"),
        ManifestErrorCode::InvalidValue,
        "dependencies.g",
        6,
        5,
    );
    only(
        &format!("{head}g = {{ package = \"x\", path = \"y\" }}\n"),
        ManifestErrorCode::UnknownField,
        "dependencies.g.path",
        6,
        22,
    );
}

#[test]
fn permissions_are_a_closed_empty_vocabulary() {
    let head = "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests]\n";
    assert!(resolve(&format!("{head}permissions = []\n")).is_ok());
    only(
        &format!("{head}permissions = [\"net\"]\n"),
        ManifestErrorCode::UnknownPermission,
        "requests.permissions[0]",
        6,
        16,
    );
    only(
        &format!("{head}permissions = [1]\n"),
        ManifestErrorCode::InvalidValue,
        "requests.permissions[0]",
        6,
        16,
    );
}

#[test]
fn limits_must_be_positive_integers() {
    let head = "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests.limits]\n";
    only(
        &format!("{head}depth = 0\n"),
        ManifestErrorCode::InvalidValue,
        "requests.limits.depth",
        6,
        9,
    );
    only(
        &format!("{head}depth = \"5\"\n"),
        ManifestErrorCode::InvalidValue,
        "requests.limits.depth",
        6,
        9,
    );
    only(
        &format!("{head}speed = 5\n"),
        ManifestErrorCode::UnknownField,
        "requests.limits.speed",
        6,
        1,
    );
}

#[test]
fn byte_budget_accepts_the_boundary_and_rejects_beyond_it() {
    let exact = MINIMAL.len();
    assert!(resolve_with(MINIMAL, "geo", exact).is_ok());
    let rejected = resolve_with(MINIMAL, "geo", exact.saturating_sub(1));
    let code = rejected
        .err()
        .and_then(|errors| errors.first().map(|error| error.code));
    assert_eq!(code, Some(ManifestErrorCode::ManifestTooLarge));
}

#[test]
fn location_must_be_a_logical_path() {
    for location in ["", "../x", "a//b", "/a"] {
        let rejected = resolve_with(MINIMAL, location, BUDGET);
        assert!(rejected.is_err(), "{location}");
    }
}

#[test]
fn errors_are_ordered_by_position_then_code() {
    let text = "schema = 1\nzzz = 1\n[package]\nname = \"a\"\nkind = \"x\"\naaa = 1\n";
    let lines: Vec<_> = failures(text).into_iter().map(|error| error.2).collect();
    assert_eq!(lines, [2, 5, 6]);
}
