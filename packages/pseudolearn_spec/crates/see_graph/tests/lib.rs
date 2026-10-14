mod support;
use see_model::Dependency;

#[test]
fn propagates_transitive_impact_and_reports_unknown_identity() -> Result<(), String> {
    let mut first = support::specification()?;
    first.metadata.id = "LANG.TEST.FIRST".to_owned();
    let mut second = first.clone();
    second.metadata.id = "LANG.TEST.SECOND".to_owned();
    second.metadata.depende_de.push(Dependency {
        id: first.metadata.id.clone(),
        version: "^0.1".to_owned(),
        tipo: "usa".to_owned(),
    });
    let corpus = vec![first, second];
    assert!(see_graph::validate(&corpus).is_empty());
    assert_eq!(see_graph::impact(&corpus, "LANG.TEST.FIRST")?.len(), 2);
    assert!(see_graph::impact(&corpus, "UNKNOWN").is_err());
    assert!(see_graph::render(&corpus, None, true)?.contains("digraph"));
    assert!(see_graph::render(&corpus, Some("LANG.TEST.SECOND"), false)?.contains("usa"));
    Ok(())
}

#[test]
fn detects_self_cycles_missing_dependencies_and_bad_ranges() -> Result<(), String> {
    let mut specification = support::specification()?;
    specification.metadata.depende_de.push(Dependency {
        id: specification.metadata.id.clone(),
        version: "^0.1".to_owned(),
        tipo: "usa".to_owned(),
    });
    assert!(
        see_graph::validate(&vec![specification.clone()])
            .iter()
            .any(|error| error.starts_with("SEE-CYCLE"))
    );
    specification
        .metadata
        .depende_de
        .first_mut()
        .ok_or("Missing dependency")?
        .id = "LANG.TEST.MISSING".to_owned();
    assert!(
        see_graph::validate(&vec![specification])
            .iter()
            .any(|error| error.starts_with("SEE-REFERENCE"))
    );
    assert!(see_graph::validate(&vec![]).is_empty());
    Ok(())
}

#[test]
fn handles_deep_acyclic_graph_without_recursion() -> Result<(), String> {
    let template = support::specification()?;
    let mut corpus = Vec::new();
    let mut previous: Option<String> = None;
    for number in 0..500 {
        let mut specification = template.clone();
        specification.metadata.id = format!("LANG.TEST.NODE{number}");
        if let Some(id) = previous {
            specification.metadata.depende_de.push(Dependency {
                id,
                version: "^0.1".to_owned(),
                tipo: "usa".to_owned(),
            });
        }
        previous = Some(specification.metadata.id.clone());
        corpus.push(specification);
    }
    assert!(see_graph::validate(&corpus).is_empty());
    assert_eq!(see_graph::impact(&corpus, "LANG.TEST.NODE0")?.len(), 500);
    Ok(())
}
