use crate::dependency_graph::find_cycles;
use crate::module_catalog::Package;
use crate::project_error::{ProjectError, ProjectErrorCode};

pub(crate) fn check(packages: &[Package], errors: &mut Vec<ProjectError>) {
    let keys: Vec<&str> = packages
        .iter()
        .map(|package| package.name.as_str())
        .collect();
    let mut edges = Vec::new();
    for (from, package) in packages.iter().enumerate() {
        for target in package.dependencies.values() {
            if let Ok(target) = usize::try_from(target.0) {
                edges.push((from, target));
            }
        }
    }
    for cycle in find_cycles(&keys, &edges) {
        let chain: Vec<String> = cycle
            .iter()
            .filter_map(|index| keys.get(*index))
            .map(|name| (*name).to_owned())
            .collect();
        let start = chain.first().map(String::as_str);
        errors.push(
            ProjectError::new(ProjectErrorCode::PackageCycle, start).with_chain(chain.clone()),
        );
    }
}
