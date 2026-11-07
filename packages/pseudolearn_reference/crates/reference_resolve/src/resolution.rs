use crate::{AliasTable, CategoryTable, LanguagePack, SectionIndex};
use reference_corpus::Corpus;
use reference_model::{
    CodeEngine, ExampleCheck, Profile, ProgramSource, PublishedSection, RuleId, Violation,
};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default)]
pub struct SpanishReuse {
    pub programs: BTreeMap<String, ProgramSource>,
    pub forms: Vec<String>,
}

pub struct Resolution<'resolution> {
    pub engine: &'resolution dyn CodeEngine,
    pub corpus: &'resolution Corpus,
    pub categories: &'resolution CategoryTable,
    pub aliases: &'resolution AliasTable,
    pub pack: &'resolution LanguagePack,
    pub figures: &'resolution BTreeMap<String, String>,
    pub index: &'resolution SectionIndex,
    pub language: Profile,
    pub profile: Profile,
}

#[derive(Clone, Debug)]
pub struct ResolvedSection {
    pub section: PublishedSection,
    pub examples: Vec<ExampleCheck>,
    pub violations: Vec<Violation>,
}

pub struct Collector<'collector> {
    pub location: String,
    pub section_number: String,
    pub reuse: &'collector SpanishReuse,
    pub violations: Vec<Violation>,
    pub examples: Vec<ExampleCheck>,
    pub figures: usize,
    pub headings: usize,
    pub forms: usize,
    pub programs: BTreeMap<String, String>,
}

impl Collector<'_> {
    pub fn report(&mut self, rule: RuleId, detail: impl Into<String>) {
        self.violations
            .push(Violation::new(rule, self.location.clone(), detail));
    }

    pub fn next_figure(&mut self) -> String {
        self.figures = self.figures.saturating_add(1);
        format!("{}-{}", self.section_number, self.figures)
    }

    pub fn next_heading(&mut self) -> String {
        self.headings = self.headings.saturating_add(1);
        format!("{}.{}", self.section_number, self.headings)
    }
}
