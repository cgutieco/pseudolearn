use crate::service::help_campaign::digest::Digest;
use crate::service::project_campaign::modules::{ModuleSpec, module_text, path_of};
use crate::service::project_campaign::shapes::{Shape, constants};
use serde_json::{Value, json};

pub struct SourceFile {
    pub path: String,
    pub text: String,
    pub profile: Option<&'static str>,
}

pub struct Dataset {
    pub name: String,
    pub packages: Vec<Value>,
    pub files: Vec<SourceFile>,
    pub entry: String,
    pub expected_output: String,
}

#[derive(Clone, Copy, Eq, PartialEq)]
pub enum Edit {
    None,
    Body,
    Signature,
}

pub struct GraphPlan {
    pub shape: Shape,
    pub count: usize,
    pub lines_per_file: usize,
    pub edit: Edit,
}

impl Dataset {
    pub fn project(&self, revision: &str) -> Value {
        let files: Vec<Value> = self
            .files
            .iter()
            .enumerate()
            .map(|(position, file)| {
                let mut entry = json!({
                    "path": file.path,
                    "source_id": position.saturating_add(1),
                    "text": file.text,
                });
                if let (Some(profile), Some(fields)) = (file.profile, entry.as_object_mut()) {
                    fields.insert("profile".to_owned(), json!(profile));
                }
                entry
            })
            .collect();
        json!({
            "project_id": "1",
            "revision_id": revision,
            "packages": self.packages,
            "files": files,
        })
    }

    pub fn arguments(&self, revision: &str) -> Value {
        json!({"project": self.project(revision), "entry": self.entry, "strictness": "strict"})
    }

    pub fn line_count(&self) -> usize {
        self.files
            .iter()
            .map(|file| file.text.lines().count())
            .sum()
    }

    pub fn digest(&self, digest: &mut Digest) {
        digest.feed(self.name.as_bytes());
        for file in &self.files {
            digest.feed(file.path.as_bytes());
            digest.feed(file.text.as_bytes());
        }
    }
}

pub fn package_wire(name: &str, kind: &str, entries: &[&str], dependencies: &[&str]) -> Value {
    let aliases: serde_json::Map<String, Value> = dependencies
        .iter()
        .map(|dependency| ((*dependency).to_owned(), json!(dependency)))
        .collect();
    json!({
        "name": name, "root": name, "kind": kind,
        "entries": entries, "dependencies": aliases,
    })
}

pub fn graph(plan: &GraphPlan) -> Dataset {
    let salt = u64::try_from(plan.count).unwrap_or(0);
    let mut values = constants(plan.count, salt);
    if let (Edit::Body, Some(constant)) = (plan.edit, values.get_mut(1)) {
        *constant = constant.saturating_add(1);
    }
    let files = graph_files(plan, &values);
    Dataset {
        name: format!(
            "{}-{}-{}",
            plan.shape.name(),
            plan.count,
            plan.lines_per_file
        ),
        packages: graph_packages(plan.shape),
        files,
        entry: "app/main".to_owned(),
        expected_output: format!("{}\n", plan.shape.expected_total(&values)),
    }
}

fn graph_files(plan: &GraphPlan, values: &[u64]) -> Vec<SourceFile> {
    let padding = plan.lines_per_file.saturating_sub(3) / 3;
    (0..plan.count)
        .map(|index| {
            let renamed = plan.edit == Edit::Signature && index == 1;
            let spec = ModuleSpec {
                index,
                count: plan.count,
                shape: plan.shape,
                constant: values.get(index).copied().unwrap_or(1),
                parameter: if renamed { "value" } else { "n" },
                padding,
            };
            SourceFile {
                path: path_of(plan.shape, index),
                text: module_text(&spec),
                profile: None,
            }
        })
        .collect()
}

fn graph_packages(shape: Shape) -> Vec<Value> {
    if shape == Shape::Library {
        vec![
            package_wire("app", "application", &["app/main"], &["lib"]),
            package_wire("lib", "library", &[], &[]),
        ]
    } else {
        vec![package_wire("app", "application", &["app/main"], &[])]
    }
}
