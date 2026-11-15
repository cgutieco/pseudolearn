#[test]
fn rejects_direct_imports_exports_and_workflow_dependencies() {
    for (source, extension) in [
        (
            "import 'package:pseudolearn_core/pseudolearn_core.dart';",
            "dart",
        ),
        (
            "export 'package:pseudolearn_core/pseudolearn_core.dart';",
            "dart",
        ),
        (
            "  pseudolearn_core:\n    path: ../../packages/pseudolearn_core",
            "yaml",
        ),
        ("working-directory: packages/pseudolearn_core", "yml"),
    ] {
        assert!(super::violates(source, extension));
    }
}

#[test]
fn accepts_rust_consumers_and_historical_evidence() {
    assert!(!super::violates("import 'rust_transport.dart';", "dart"));
    assert!(!super::violates(
        "{\"subject\":\"reference\",\"actual\":{}}",
        "json"
    ));
}
