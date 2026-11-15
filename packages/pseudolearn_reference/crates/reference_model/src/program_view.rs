use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct SubprogramView {
    pub name: String,
    pub arity: usize,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct MemberView {
    pub class: String,
    pub name: String,
    pub visibility: String,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ProgramView {
    pub constructs: BTreeMap<String, usize>,
    pub subprograms: Vec<SubprogramView>,
    pub members: Vec<MemberView>,
}

impl ProgramView {
    pub fn occurrences(&self, construct: &str) -> usize {
        self.constructs.get(construct).copied().unwrap_or_default()
    }
}
