mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_semantic::HirModule;
use serde_json::Value;

fn example(identity: &str) -> Result<String, String> {
    let corpus =
        include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.function.md");
    for block in corpus.split("```caso\n").skip(1) {
        let source = block.split("\n```").next().ok_or("missing case")?;
        let case: Value = serde_json::from_str(source).map_err(|error| error.to_string())?;
        if case.get("id").and_then(Value::as_str) == Some(identity) {
            return case
                .pointer("/programas/en")
                .and_then(Value::as_str)
                .map(str::to_owned)
                .ok_or("missing program".to_owned());
        }
    }
    Err("missing identity".to_owned())
}

fn analyze(identity: &str) -> Result<HirModule, String> {
    let (module, diagnostics) = support::analyze(&example(identity)?, true);
    module.ok_or_else(|| format!("{diagnostics:?}"))
}

#[test]
fn environments_contain_only_effective_captures() -> Result<(), String> {
    let module = analyze("C6")?;
    assert!(!module.closures.is_empty());
    assert!(
        module
            .closures
            .values()
            .all(|closure| closure.captures.is_empty())
    );
    assert!(
        module
            .closures
            .values()
            .all(|closure| closure.class.is_none())
    );
    let captured = analyze("C2")?;
    assert!(
        captured
            .closures
            .values()
            .any(|closure| closure.captures.len() == 1)
    );
    assert!(
        captured
            .closures
            .values()
            .all(|closure| closure.captures.len() <= 1)
    );
    Ok(())
}

#[test]
fn transitive_environments_preserve_capture_origins() -> Result<(), String> {
    let module = analyze("C7")?;
    let closures: Vec<_> = module
        .closures
        .values()
        .filter(|closure| !closure.captures.is_empty())
        .collect();
    assert_eq!(closures.len(), 2);
    for closure in closures {
        assert_eq!(closure.captures.len(), 1);
        let (source, proxy) = closure.captures.first().ok_or("missing capture")?;
        let source = usize::try_from(source.0).map_err(|error| error.to_string())?;
        let proxy = usize::try_from(proxy.0).map_err(|error| error.to_string())?;
        assert_eq!(
            module.locals.get(source).map(|local| local.span),
            module.locals.get(proxy).map(|local| local.span)
        );
    }
    Ok(())
}

#[test]
fn mutable_capture_reports_both_use_and_declaration() -> Result<(), String> {
    let (module, diagnostics) = support::analyze(&example("C3")?, true);
    assert!(module.is_none());
    let diagnostic = diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code == DiagnosticCode::MutableClosureCapture)
        .ok_or("missing diagnostic")?;
    assert_eq!(diagnostic.related.len(), 1);
    assert_ne!(diagnostic.related.first(), Some(&diagnostic.span));
    Ok(())
}
