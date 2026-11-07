use crate::book::Book;
use crate::workspace::Workspace;
use reference_model::{Profile, PublishedSection, SourceDocument, Violation};
use reference_verify::{
    CoverageInput, CoverageReport, check_anatomy, check_anchors, check_examples, check_inline_code,
    check_internal_ids, check_links, check_lock, check_parity, measure_coverage,
};

pub fn verify(workspace: &Workspace, book: &Book) -> (Vec<Violation>, CoverageReport) {
    let mut violations = workspace.format_violations.clone();
    for edition in &book.editions {
        violations.extend(edition.violations.iter().cloned());
        violations.extend(check_examples(&edition.examples));
        violations.extend(check_internal_ids(&edition.sections));
        violations.extend(check_links(&edition.sections));
    }
    let spanish = documents(workspace, Profile::Spanish);
    let english = documents(workspace, Profile::English);
    violations.extend(check_anchors(spanish, &workspace.corpus));
    violations.extend(check_lock(spanish, &workspace.corpus, &workspace.lock));
    violations.extend(spanish.iter().flat_map(check_anatomy));
    violations.extend(check_parity(spanish, english));
    for (language, documents) in [(Profile::Spanish, spanish), (Profile::English, english)] {
        violations.extend(
            documents
                .iter()
                .flat_map(|document| check_inline_code(document, &workspace.corpus, language)),
        );
    }
    let (report, missing) = measure_coverage(&CoverageInput {
        documents: spanish,
        sections: reference_sections(book),
        corpus: &workspace.corpus,
        exclusions: &workspace.exclusions,
    });
    violations.extend(missing);
    violations.sort();
    violations.dedup();
    (violations, report)
}

pub fn documents(workspace: &Workspace, language: Profile) -> &[SourceDocument] {
    workspace
        .languages
        .get(&language)
        .map_or(&[], |content| content.documents.as_slice())
}

fn reference_sections(book: &Book) -> &[PublishedSection] {
    book.editions
        .iter()
        .find(|edition| edition.language == Profile::Spanish && edition.profile == Profile::Spanish)
        .map_or(&[], |edition| edition.sections.as_slice())
}
