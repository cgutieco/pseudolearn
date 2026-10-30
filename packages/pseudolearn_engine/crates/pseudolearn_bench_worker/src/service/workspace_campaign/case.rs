use crate::service::project_campaign::datasets::{Dataset, Edit, SourceFile};
use crate::service::workspace_campaign::edge;
use crate::service::workspace_campaign::loads::{Load, dataset};
use crate::service::workspace_campaign::scenario::Scenario;
use crate::service::workspace_campaign::wire;
use serde_json::Value;

pub const BARRIER_ID: u64 = 9000;
pub const SETTLE_ID: u64 = 9001;
const EDITED_MODULE: &str = "lib/m1";
const ENTRY_MODULE: &str = "app/main";
const DECLARATION: (u64, u64) = (0, 19);

pub struct Case {
    pub base_setup: Vec<Value>,
    pub step: Vec<Value>,
    pub cold_setup: Vec<Value>,
    pub cold_step: Vec<Value>,
}

fn text_of<'source>(source: &'source Dataset, path: &str) -> &'source str {
    source
        .files
        .iter()
        .find(|file| file.path == path)
        .map_or("", |file| file.text.as_str())
}

fn session(source: &Dataset, opened: &[&str]) -> Vec<Value> {
    let mut messages = vec![wire::initialize(1), wire::snapshot(source, 1)];
    messages.extend(
        opened
            .iter()
            .map(|path| wire::open_document(path, 1, text_of(source, path))),
    );
    messages
}

fn with_manifest_change(source: &Dataset) -> Dataset {
    let mut changed = Dataset {
        name: source.name.clone(),
        packages: source.packages.clone(),
        files: source
            .files
            .iter()
            .map(|file| SourceFile {
                path: file.path.clone(),
                text: file.text.clone(),
                profile: file.profile,
            })
            .collect(),
        entry: source.entry.clone(),
        expected_output: source.expected_output.clone(),
    };
    if let Some(dependencies) = changed
        .packages
        .first_mut()
        .and_then(|package| package.get_mut("dependencies"))
        .and_then(Value::as_object_mut)
    {
        dependencies.insert("lib_alias".to_owned(), Value::from("lib"));
    }
    changed
}

fn edit_case(base: &Dataset, edited: &Dataset) -> Case {
    let opened = [ENTRY_MODULE, EDITED_MODULE];
    Case {
        base_setup: session(base, &opened),
        step: vec![
            wire::change_document(EDITED_MODULE, 2, text_of(edited, EDITED_MODULE)),
            wire::workspace_symbols(BARRIER_ID),
        ],
        cold_setup: session(edited, &opened),
        cold_step: vec![wire::workspace_symbols(BARRIER_ID)],
    }
}

fn resync_case(base: &Dataset, edited: &Dataset, opened: &[&str]) -> Case {
    Case {
        base_setup: session(base, opened),
        step: vec![
            wire::snapshot(edited, 2),
            wire::workspace_symbols(BARRIER_ID),
        ],
        cold_setup: session(edited, opened),
        cold_step: vec![wire::workspace_symbols(BARRIER_ID)],
    }
}

fn rename_case(base: &Dataset) -> Case {
    let opened = [ENTRY_MODULE, EDITED_MODULE];
    let step = vec![wire::rename(
        BARRIER_ID,
        EDITED_MODULE,
        DECLARATION,
        "Renamed1",
    )];
    Case {
        base_setup: session(base, &opened),
        step: step.clone(),
        cold_setup: session(base, &opened),
        cold_step: step,
    }
}

fn stale_case(base: &Dataset) -> Case {
    let fresh = format!("{}\n", text_of(base, EDITED_MODULE));
    let stale = text_of(base, ENTRY_MODULE);
    let opened = [ENTRY_MODULE, EDITED_MODULE];
    let mut cold_setup = session(base, &[ENTRY_MODULE]);
    cold_setup.push(wire::open_document(EDITED_MODULE, 5, &fresh));
    Case {
        base_setup: session(base, &opened),
        step: vec![
            wire::change_document(EDITED_MODULE, 5, &fresh),
            wire::change_document(EDITED_MODULE, 3, stale),
            wire::workspace_symbols(BARRIER_ID),
        ],
        cold_setup,
        cold_step: vec![wire::workspace_symbols(BARRIER_ID)],
    }
}

fn static_case(source: &Dataset) -> Case {
    let paths: Vec<&str> = source.files.iter().map(|file| file.path.as_str()).collect();
    Case {
        base_setup: session(source, &paths),
        step: vec![wire::workspace_symbols(BARRIER_ID)],
        cold_setup: session(source, &paths),
        cold_step: vec![wire::workspace_symbols(BARRIER_ID)],
    }
}

pub fn build(load: &Load, scenario: Scenario) -> Case {
    match scenario {
        Scenario::BodyEdit => edit_case(&dataset(load, Edit::None), &dataset(load, Edit::Body)),
        Scenario::SignatureEdit => {
            edit_case(&dataset(load, Edit::None), &dataset(load, Edit::Signature))
        }
        Scenario::ManifestChange => {
            let base = dataset(load, Edit::None);
            resync_case(&base, &with_manifest_change(&base), &[ENTRY_MODULE])
        }
        Scenario::ClosedFileChange => resync_case(
            &dataset(load, Edit::None),
            &dataset(load, Edit::Body),
            &[ENTRY_MODULE],
        ),
        Scenario::Rename => rename_case(&dataset(load, Edit::None)),
        Scenario::StaleSource => stale_case(&dataset(load, Edit::None)),
        Scenario::EmptyProject => static_case(&edge::empty_project()),
        Scenario::ShortNames => static_case(&edge::short_names()),
        Scenario::UnicodeSource => static_case(&edge::unicode_source()),
    }
}
