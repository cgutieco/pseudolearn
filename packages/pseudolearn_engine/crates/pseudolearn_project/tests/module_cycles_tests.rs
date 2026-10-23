use pseudolearn_project::{
    FileInput, ImportEdge, ModuleId, PackageInput, PackageKind, ProjectCatalog, ProjectInput,
    module_cycles,
};
use std::collections::BTreeMap;

fn catalog(paths: &[&str]) -> Result<ProjectCatalog, String> {
    let input = ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages: vec![PackageInput {
            name: "geo".to_owned(),
            root: "geo".to_owned(),
            kind: PackageKind::Library,
            entries: Vec::new(),
            dependencies: BTreeMap::new(),
        }],
        files: paths
            .iter()
            .enumerate()
            .map(|(index, path)| FileInput {
                path: format!("geo/{path}"),
                source_id: u32::try_from(index).unwrap_or(0).saturating_add(1),
                text: String::new(),
            })
            .collect(),
    };
    ProjectCatalog::build(&input).map_err(|failure| format!("{failure:?}"))
}

fn edge(from: u32, target: u32, site: usize) -> ImportEdge {
    ImportEdge {
        from: ModuleId(from),
        target: ModuleId(target),
        site,
    }
}

#[test]
fn acyclic_edges_report_nothing() -> Result<(), String> {
    let catalog = catalog(&["a", "b", "c"])?;
    assert!(module_cycles(&catalog, &[edge(0, 1, 1), edge(1, 2, 1), edge(0, 2, 2)]).is_empty());
    Ok(())
}

#[test]
fn no_edges_report_nothing() -> Result<(), String> {
    assert!(module_cycles(&catalog(&["a"])?, &[]).is_empty());
    Ok(())
}

#[test]
fn a_self_import_is_a_cycle_of_one_edge() -> Result<(), String> {
    let cycles = module_cycles(&catalog(&["a"])?, &[edge(0, 0, 7)]);
    assert_eq!(cycles.len(), 1);
    assert_eq!(
        cycles.first().map(|cycle| cycle.edges.clone()),
        Some(vec![edge(0, 0, 7)])
    );
    Ok(())
}

#[test]
fn repeated_edges_keep_the_first_site() -> Result<(), String> {
    let edges = [edge(0, 1, 9), edge(0, 1, 3), edge(1, 0, 4)];
    let cycles = module_cycles(&catalog(&["a", "b"])?, &edges);
    let chain = cycles.first().map(|cycle| cycle.edges.clone());
    assert_eq!(chain, Some(vec![edge(0, 1, 3), edge(1, 0, 4)]));
    Ok(())
}

#[test]
fn edge_order_does_not_change_the_cycles() -> Result<(), String> {
    let catalog = catalog(&["a", "b", "c", "d"])?;
    let edges = [
        edge(0, 2, 1),
        edge(0, 1, 2),
        edge(1, 3, 1),
        edge(2, 3, 1),
        edge(3, 0, 1),
    ];
    let mut reversed = edges;
    reversed.reverse();
    let forward = module_cycles(&catalog, &edges);
    assert_eq!(forward, module_cycles(&catalog, &reversed));
    let path: Vec<u32> = forward
        .first()
        .map(|cycle| cycle.edges.iter().map(|step| step.from.0).collect())
        .unwrap_or_default();
    assert_eq!(path, [0, 1, 3]);
    Ok(())
}
