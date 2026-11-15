#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum ProjectErrorCode {
    DependencyNotFound,
    EmptyWorkspace,
    EntryDuplicated,
    EntryNotFound,
    EntryNotSelected,
    ModuleInMultipleRoots,
    ModuleOutsideRoots,
    NoEntryInLibrary,
    PackageCycle,
}

impl ProjectErrorCode {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::DependencyNotFound => "dependencyNotFound",
            Self::EmptyWorkspace => "emptyWorkspace",
            Self::EntryDuplicated => "entryDuplicated",
            Self::EntryNotFound => "entryNotFound",
            Self::EntryNotSelected => "entryNotSelected",
            Self::ModuleInMultipleRoots => "moduleInMultipleRoots",
            Self::ModuleOutsideRoots => "moduleOutsideRoots",
            Self::NoEntryInLibrary => "noEntryInLibrary",
            Self::PackageCycle => "packageCycle",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ProjectError {
    pub code: ProjectErrorCode,
    pub path: Option<String>,
    pub chain: Vec<String>,
}

impl ProjectError {
    pub fn new(code: ProjectErrorCode, path: Option<&str>) -> Self {
        Self {
            code,
            path: path.map(str::to_owned),
            chain: Vec::new(),
        }
    }

    pub fn with_chain(mut self, chain: Vec<String>) -> Self {
        self.chain = chain;
        self
    }

    pub(crate) fn sort(errors: &mut [Self]) {
        errors.sort_by(|left, right| {
            left.code
                .as_str()
                .cmp(right.code.as_str())
                .then_with(|| left.path.cmp(&right.path))
        });
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct MalformedProject(pub String);
