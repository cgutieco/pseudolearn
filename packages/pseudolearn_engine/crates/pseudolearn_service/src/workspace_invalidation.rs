use crate::unit_partition::compare_partitions;
use crate::workspace_model::{WorkspaceIndex, WorkspaceInvalidation};
use pseudolearn_project::{ImportEdge, ModuleId};
use std::collections::{BTreeMap, BTreeSet};

pub(crate) fn compare_workspace(
    previous: Option<&WorkspaceIndex>,
    current: &WorkspaceIndex,
) -> WorkspaceInvalidation {
    let Some(previous) = previous else {
        let paths: BTreeSet<String> = current.files.keys().cloned().collect();
        return invalidation(paths.clone(), paths.clone(), paths);
    };
    let mut changed = BTreeSet::new();
    let mut signatures = BTreeSet::new();
    compare_files(previous, current, &mut changed, &mut signatures);
    compare_package_options(previous, current, &mut changed, &mut signatures);
    let invalidated = dependent_closure(previous, current, &signatures, changed.clone());
    invalidation(changed, signatures, invalidated)
}

fn compare_files(
    previous: &WorkspaceIndex,
    current: &WorkspaceIndex,
    changed: &mut BTreeSet<String>,
    signatures: &mut BTreeSet<String>,
) {
    let paths: BTreeSet<String> = previous
        .files
        .keys()
        .chain(current.files.keys())
        .cloned()
        .collect();
    for path in paths {
        let old_file = previous.files.get(&path);
        let new_file = current.files.get(&path);
        let profile_changed = previous.profiles.get(&path) != current.profiles.get(&path);
        let file_changed = old_file != new_file;
        if file_changed || profile_changed {
            changed.insert(path.clone());
        }
        if signature_changed(previous, current, &path) {
            signatures.insert(path);
        }
    }
}

fn signature_changed(previous: &WorkspaceIndex, current: &WorkspaceIndex, path: &str) -> bool {
    let old_file = previous.files.get(path);
    let new_file = current.files.get(path);
    if old_file.is_none()
        || new_file.is_none()
        || previous.profiles.get(path) != current.profiles.get(path)
    {
        return true;
    }
    if old_file == new_file {
        return false;
    }
    let old_units = previous.units.get(path).map(Vec::as_slice).unwrap_or(&[]);
    let new_units = current.units.get(path).map(Vec::as_slice).unwrap_or(&[]);
    compare_partitions(old_units, new_units).signature_invalidated
}

fn compare_package_options(
    previous: &WorkspaceIndex,
    current: &WorkspaceIndex,
    changed: &mut BTreeSet<String>,
    signatures: &mut BTreeSet<String>,
) {
    let packages_changed = previous.packages != current.packages;
    let options = &previous.options;
    let next_options = &current.options;
    let structure_changed = packages_changed
        || options.configurations != next_options.configurations
        || options.entry != next_options.entry;
    let resolution_changed = options.dependency_inputs != next_options.dependency_inputs;
    let structure_changed = structure_changed || resolution_changed;
    let analysis_changed = structure_changed
        || options.strict != next_options.strict
        || options.requested_profile != next_options.requested_profile;
    if !analysis_changed {
        return;
    }
    changed.extend(current.files.keys().cloned());
    if structure_changed {
        signatures.extend(current.files.keys().cloned());
    }
}

fn dependent_closure(
    previous: &WorkspaceIndex,
    current: &WorkspaceIndex,
    signatures: &BTreeSet<String>,
    mut invalidated: BTreeSet<String>,
) -> BTreeSet<String> {
    let reverse = reverse_dependencies(previous, current);
    let mut frontier: Vec<String> = signatures.iter().cloned().collect();
    while let Some(target) = frontier.pop() {
        for importer in reverse.get(&target).into_iter().flatten() {
            if invalidated.insert(importer.clone()) {
                frontier.push(importer.clone());
            }
        }
    }
    invalidated
}

fn reverse_dependencies(
    previous: &WorkspaceIndex,
    current: &WorkspaceIndex,
) -> BTreeMap<String, BTreeSet<String>> {
    let mut reverse = BTreeMap::<String, BTreeSet<String>>::new();
    for edge in &previous.imports {
        add_dependency(edge, &previous.modules, &mut reverse);
    }
    for edge in &current.imports {
        add_dependency(edge, &current.modules, &mut reverse);
    }
    reverse
}

fn add_dependency(
    edge: &ImportEdge,
    module_paths: &BTreeMap<ModuleId, String>,
    reverse: &mut BTreeMap<String, BTreeSet<String>>,
) {
    let Some(target) = module_paths.get(&edge.target) else {
        return;
    };
    let Some(importer) = module_paths.get(&edge.from) else {
        return;
    };
    reverse
        .entry(target.clone())
        .or_default()
        .insert(importer.clone());
}

fn invalidation(
    changed: BTreeSet<String>,
    signatures: BTreeSet<String>,
    invalidated: BTreeSet<String>,
) -> WorkspaceInvalidation {
    WorkspaceInvalidation {
        changed_modules: changed.into_iter().collect(),
        signature_changed_modules: signatures.into_iter().collect(),
        invalidated_modules: invalidated.into_iter().collect(),
    }
}
