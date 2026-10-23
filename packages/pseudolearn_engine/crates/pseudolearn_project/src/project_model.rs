use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct PackageId(pub u32);

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct ModuleId(pub u32);

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PackageKind {
    Application,
    Library,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct PackageInput {
    pub name: String,
    pub root: String,
    pub kind: PackageKind,
    pub entries: Vec<String>,
    pub dependencies: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct FileInput {
    pub path: String,
    pub source_id: u32,
    pub text: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ProjectInput {
    pub project_id: u64,
    pub revision_id: u64,
    pub packages: Vec<PackageInput>,
    pub files: Vec<FileInput>,
}
