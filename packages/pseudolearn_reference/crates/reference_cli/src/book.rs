use crate::workspace::{Language, Workspace};
use reference_export::{Bundle, BundleInput, SectionMeta, build_bundle};
use reference_model::{
    CodeEngine, ExampleCheck, Profile, PublishedSection, SourceBlock, SourceDocument, Violation,
};
use reference_resolve::{IndexedSection, Resolution, SectionIndex, SpanishReuse, resolve_section};
use std::collections::BTreeMap;

pub struct Edition {
    pub language: Profile,
    pub profile: Profile,
    pub sections: Vec<PublishedSection>,
    pub examples: Vec<ExampleCheck>,
    pub violations: Vec<Violation>,
}

pub struct Book {
    pub editions: Vec<Edition>,
    pub bundles: BTreeMap<String, Bundle>,
    pub route_editions: Vec<crate::route_book::RouteEdition>,
    pub route_bundles: BTreeMap<String, Bundle>,
}

pub fn compile(workspace: &Workspace, engine: &dyn CodeEngine) -> Result<Book, String> {
    let empty = Vec::new();
    let spanish = workspace
        .languages
        .get(&Profile::Spanish)
        .map_or(&empty, |language| &language.documents);
    let reuse: BTreeMap<String, SpanishReuse> = spanish
        .iter()
        .map(|document| (document.header.id.clone(), reuse_of(&document.blocks)))
        .collect();
    let links = crate::links::link_maps(workspace);
    let mut book = Book {
        editions: Vec::new(),
        bundles: BTreeMap::new(),
        route_editions: Vec::new(),
        route_bundles: BTreeMap::new(),
    };
    for (language, content) in &workspace.languages {
        let index = section_index(&content.documents);
        for profile in Profile::all() {
            let resolution = Resolution {
                engine,
                corpus: &workspace.corpus,
                categories: &workspace.categories,
                pack: &content.pack,
                figures: &workspace.figures,
                index: &index,
                language: *language,
                profile,
            };
            add_edition(&mut book, (workspace, &resolution, content), &reuse, &links)?;
        }
    }
    crate::route_book::compile_route(&mut book, workspace, engine)?;
    Ok(book)
}

fn add_edition(
    book: &mut Book,
    (workspace, resolution, content): (&Workspace, &Resolution<'_>, &Language),
    reuse: &BTreeMap<String, SpanishReuse>,
    links: &BTreeMap<String, BTreeMap<String, String>>,
) -> Result<(), String> {
    let edition = edition(resolution, content, reuse);
    let fingerprint = resolution.engine.fingerprint();
    let bundle = bundle(workspace, &fingerprint, (content, &edition), links)?;
    let key = format!("{}/{}", edition.language.code(), edition.profile.code());
    book.bundles.insert(key, bundle);
    book.editions.push(edition);
    Ok(())
}

fn edition(
    resolution: &Resolution<'_>,
    content: &Language,
    reuse: &BTreeMap<String, SpanishReuse>,
) -> Edition {
    let fallback = SpanishReuse::default();
    let mut edition = Edition {
        language: resolution.language,
        profile: resolution.profile,
        sections: Vec::new(),
        examples: Vec::new(),
        violations: Vec::new(),
    };
    for document in &content.documents {
        let reused = reuse.get(&document.header.id).unwrap_or(&fallback);
        let resolved = resolve_section(resolution, document, reused);
        edition.sections.push(resolved.section);
        edition.examples.extend(resolved.examples);
        edition.violations.extend(resolved.violations);
    }
    edition
}

fn bundle(
    workspace: &Workspace,
    engine: &str,
    (content, edition): (&Language, &Edition),
    links: &BTreeMap<String, BTreeMap<String, String>>,
) -> Result<Bundle, String> {
    let metas: Vec<SectionMeta> = content
        .documents
        .iter()
        .map(|document| SectionMeta {
            id: document.header.id.clone(),
            terms: document.header.terms.clone(),
            card_titles: document
                .header
                .cards
                .iter()
                .filter_map(|card| workspace.corpus.cards.get(card))
                .map(|card| match edition.language {
                    Profile::Spanish => card.spanish_title.clone(),
                    Profile::English => card.english_title.clone(),
                })
                .collect(),
            diagnostics: document.header.diagnostics.clone(),
        })
        .collect();
    build_bundle(&BundleInput {
        language: edition.language.code(),
        profile: edition.profile.code(),
        corpus: &workspace.corpus.digest,
        engine,
        parts: &content.parts,
        sections: &edition.sections,
        metas: &metas,
        links,
    })
}

pub fn section_index(documents: &[SourceDocument]) -> SectionIndex {
    SectionIndex {
        sections: documents
            .iter()
            .map(|document| {
                let entry = IndexedSection {
                    number: document.header.number.clone(),
                    title: document.header.title.replace('`', ""),
                    terms: document.header.terms.clone(),
                    diagnostics: document.header.diagnostics.clone(),
                };
                (document.header.id.clone(), entry)
            })
            .collect(),
    }
}

fn reuse_of(blocks: &[SourceBlock]) -> SpanishReuse {
    let mut reuse = SpanishReuse::default();
    collect_reuse(blocks, &mut reuse);
    reuse
}

pub fn flattened(blocks: &[SourceBlock]) -> Vec<&SourceBlock> {
    let mut found = Vec::new();
    for block in blocks {
        found.push(block);
        if let SourceBlock::Callout { blocks, .. } = block {
            found.extend(flattened(blocks));
        }
    }
    found
}

fn collect_reuse(blocks: &[SourceBlock], reuse: &mut SpanishReuse) {
    for block in blocks {
        match block {
            SourceBlock::Program(program) => {
                reuse.programs.insert(program.id.clone(), program.clone());
            }
            SourceBlock::Form(text) => reuse.forms.push(text.clone()),
            SourceBlock::Callout { blocks, .. } => collect_reuse(blocks, reuse),
            _ => {}
        }
    }
}
