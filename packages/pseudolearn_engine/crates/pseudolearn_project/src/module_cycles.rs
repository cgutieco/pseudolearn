use crate::dependency_graph::find_cycles;
use crate::module_catalog::ProjectCatalog;
use crate::project_model::ModuleId;
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ImportEdge {
    pub from: ModuleId,
    pub target: ModuleId,
    pub site: usize,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ModuleCycle {
    pub edges: Vec<ImportEdge>,
}

pub fn module_cycles(catalog: &ProjectCatalog, edges: &[ImportEdge]) -> Vec<ModuleCycle> {
    let keys: Vec<ModuleId> = catalog.modules().iter().map(|module| module.id).collect();
    let first_sites = first_sites(edges);
    let pairs: Vec<(usize, usize)> = first_sites
        .keys()
        .filter_map(|(from, target)| {
            Some((
                usize::try_from(from.0).ok()?,
                usize::try_from(target.0).ok()?,
            ))
        })
        .collect();
    find_cycles(&keys, &pairs)
        .into_iter()
        .map(|chain| ModuleCycle {
            edges: chain_edges(&keys, &chain, &first_sites),
        })
        .collect()
}

fn first_sites(edges: &[ImportEdge]) -> BTreeMap<(ModuleId, ModuleId), usize> {
    let mut sites: BTreeMap<(ModuleId, ModuleId), usize> = BTreeMap::new();
    for edge in edges {
        let slot = sites.entry((edge.from, edge.target)).or_insert(edge.site);
        *slot = (*slot).min(edge.site);
    }
    sites
}

fn chain_edges(
    keys: &[ModuleId],
    chain: &[usize],
    sites: &BTreeMap<(ModuleId, ModuleId), usize>,
) -> Vec<ImportEdge> {
    chain
        .windows(2)
        .filter_map(|pair| {
            let from = *keys.get(*pair.first()?)?;
            let target = *keys.get(*pair.get(1)?)?;
            let site = *sites.get(&(from, target))?;
            Some(ImportEdge { from, target, site })
        })
        .collect()
}
