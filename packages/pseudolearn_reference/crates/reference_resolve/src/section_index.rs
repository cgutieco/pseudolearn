use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct IndexedSection {
    pub number: String,
    pub title: String,
    pub terms: Vec<String>,
    pub diagnostics: Vec<String>,
}

#[derive(Clone, Debug, Default)]
pub struct SectionIndex {
    pub sections: BTreeMap<String, IndexedSection>,
}

impl SectionIndex {
    pub fn get(&self, identity: &str) -> Option<&IndexedSection> {
        self.sections.get(identity)
    }

    pub fn section_for_diagnostic(&self, code: &str) -> Option<(&String, &IndexedSection)> {
        self.sections
            .iter()
            .find(|(_, section)| section.diagnostics.iter().any(|listed| listed == code))
    }
}
