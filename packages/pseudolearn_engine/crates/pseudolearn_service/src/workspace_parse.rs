use crate::unit_partition::{UnitFingerprint, partition_units};
use crate::workspace_index::portable_key;
use crate::workspace_model::{ParsedUnitCache, WorkspaceIndex};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{Module, ModuleId, ProjectCatalog};
use pseudolearn_semantic::ResolvedUnitProfile;
use pseudolearn_source::{SourceText, Span, source_id};
use pseudolearn_syntax::{SyntaxTree, parse_module_source};
use std::collections::BTreeMap;
use std::sync::Arc;

pub(crate) struct ParsedWorkspace {
    pub trees: Vec<Arc<SyntaxTree>>,
    pub profiles: Vec<Profile>,
    pub diagnostics: Vec<Diagnostic>,
    pub units: BTreeMap<String, Vec<UnitFingerprint>>,
    pub cache: BTreeMap<String, ParsedUnitCache>,
    pub modules: BTreeMap<ModuleId, String>,
}

struct ParseContext<'context> {
    catalog: &'context ProjectCatalog,
    profiles: &'context BTreeMap<String, ResolvedUnitProfile>,
    options: &'context crate::workspace_model::WorkspaceOptions,
    previous: Option<&'context WorkspaceIndex>,
}

struct ParseReuseKey<'source> {
    path: &'source str,
    source_id: u32,
    text: &'source str,
    profile: Profile,
    strict: bool,
}

pub(crate) fn parse_catalog(
    catalog: &ProjectCatalog,
    profiles: &BTreeMap<String, ResolvedUnitProfile>,
    options: &crate::workspace_model::WorkspaceOptions,
    previous: Option<&WorkspaceIndex>,
) -> ParsedWorkspace {
    let context = ParseContext {
        catalog,
        profiles,
        options,
        previous,
    };
    let mut parsed = ParsedWorkspace {
        trees: Vec::new(),
        profiles: Vec::new(),
        diagnostics: Vec::new(),
        units: BTreeMap::new(),
        cache: BTreeMap::new(),
        modules: BTreeMap::new(),
    };
    for module in catalog.modules() {
        append_catalog_module(&context, module, &mut parsed);
    }
    parsed
}

fn append_catalog_module(
    context: &ParseContext<'_>,
    module: &Module,
    parsed_workspace: &mut ParsedWorkspace,
) {
    let Some(source) = context.catalog.source(module.id) else {
        return;
    };
    let path = portable_key(&module.path);
    let resolved = context.profiles.get(&path);
    let profile = resolved.map_or(Profile::default(), |value| value.profile);
    let source_id = source_id(source).value();
    let key = ParseReuseKey {
        path: &path,
        source_id,
        text: source.as_str(),
        profile,
        strict: context.options.strict,
    };
    let parsed = context
        .previous
        .and_then(|previous| reusable_parse(previous, key))
        .unwrap_or_else(|| parse_unit(source, profile, context.options.strict));
    let mut syntax = parsed.diagnostics.clone();
    if let Some(mismatch) = resolved.and_then(|value| value.mismatch.clone()) {
        syntax.push(profile_mismatch(source, mismatch));
    }
    parsed_workspace.diagnostics.append(&mut syntax);
    parsed_workspace
        .units
        .insert(path.clone(), parsed.units.clone());
    parsed_workspace
        .modules
        .insert(module.id, module.path.clone());
    parsed_workspace.profiles.push(profile);
    parsed_workspace.trees.push(parsed.tree.clone());
    parsed_workspace.cache.insert(path, parsed);
}

fn parse_unit(source: &SourceText, profile: Profile, strict: bool) -> ParsedUnitCache {
    let terminator = strict.then_some(DiagnosticCode::MissingStatementTerminator);
    let (tree, diagnostics) = parse_module_source(source, profile, terminator);
    ParsedUnitCache {
        source_id: source_id(source).value(),
        profile,
        strict,
        units: partition_units(&tree, source),
        tree: Arc::new(tree),
        diagnostics,
    }
}

fn reusable_parse(previous: &WorkspaceIndex, key: ParseReuseKey<'_>) -> Option<ParsedUnitCache> {
    let file = previous.files.get(key.path)?;
    if file.source_id != key.source_id || file.text != key.text {
        return None;
    }
    let parsed = previous.parsed_units.get(key.path)?;
    (parsed.source_id == key.source_id
        && parsed.profile == key.profile
        && parsed.strict == key.strict)
        .then(|| parsed.clone())
}

fn profile_mismatch(source: &SourceText, lexeme: String) -> Diagnostic {
    Diagnostic::new(
        DiagnosticCode::ProfileMismatch,
        Span::in_source(source_id(source), 0, 0),
    )
    .with_argument("lexeme", &lexeme)
}
