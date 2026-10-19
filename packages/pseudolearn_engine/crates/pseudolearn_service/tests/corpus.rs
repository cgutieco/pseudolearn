use pseudolearn_lexicon::Profile;
use pseudolearn_service::edit_probe::{SeededRandom, random_edit};
use pseudolearn_service::{
    DocumentSession, FormatOptions, format_checked, format_source, translate_source,
};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{TokenKind, parse_source};
use std::path::PathBuf;

struct Example {
    name: String,
    text: String,
    profile: Profile,
}

fn examples() -> Result<Vec<Example>, String> {
    let directory = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../../../apps/pseudolearn_app/assets/knowledge/examples");
    let mut found = Vec::new();
    for entry in std::fs::read_dir(&directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        let name = path
            .file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("")
            .to_owned();
        if !name.ends_with(".pseudo") {
            continue;
        }
        let profile = if name.ends_with("_en.pseudo") {
            Profile::English
        } else {
            Profile::Spanish
        };
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        found.push(Example {
            name,
            text,
            profile,
        });
    }
    found.sort_by(|left, right| left.name.cmp(&right.name));
    Ok(found)
}

fn options(profile: Profile) -> FormatOptions {
    FormatOptions {
        profile,
        strict: true,
        indent_size: 2,
    }
}

fn significant_kinds(text: &str, profile: Profile) -> Vec<TokenKind> {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    (0..tree.tokens.token_count())
        .filter_map(|index| tree.tokens.kind(index))
        .filter(|kind| {
            !kind.is_trivia() && *kind != TokenKind::Semicolon && *kind != TokenKind::EndOfFile
        })
        .collect()
}

fn comment_texts(text: &str, profile: Profile) -> Vec<String> {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    (0..tree.tokens.token_count())
        .filter(|index| tree.tokens.kind(*index) == Some(TokenKind::Comment))
        .filter_map(|index| tree.tokens.text(source.as_str(), index))
        .map(|comment| comment.split_whitespace().collect::<Vec<_>>().join(" "))
        .collect()
}

#[test]
fn corpus_has_the_reference_programs() -> Result<(), String> {
    let all = examples()?;
    assert_eq!(all.len(), 172);
    assert_eq!(
        all.iter()
            .filter(|example| example.profile == Profile::English)
            .count(),
        86
    );
    Ok(())
}

#[test]
fn every_program_formats_without_loss_and_idempotently() -> Result<(), String> {
    let mut failures = Vec::new();
    for example in examples()? {
        let settings = options(example.profile);
        let Some(first) = format_checked(&example.text, settings) else {
            failures.push(format!("{}: not formattable", example.name));
            continue;
        };
        let second = format_checked(&first, settings);
        if second.as_deref() != Some(first.as_str()) {
            failures.push(format!("{}: not idempotent", example.name));
        }
        if significant_kinds(&example.text, example.profile)
            != significant_kinds(&first, example.profile)
        {
            failures.push(format!("{}: token structure changed", example.name));
        }
        if comment_texts(&example.text, example.profile) != comment_texts(&first, example.profile) {
            failures.push(format!("{}: comments changed", example.name));
        }
    }
    assert!(failures.is_empty(), "{failures:#?}");
    Ok(())
}

#[test]
fn every_program_survives_double_translation_in_canonical_form() -> Result<(), String> {
    let mut failures = Vec::new();
    let mut collisions = 0usize;
    for example in examples()? {
        let Some(canonical) = format_checked(&example.text, options(example.profile)) else {
            failures.push(format!("{}: not formattable", example.name));
            continue;
        };
        let other = if example.profile == Profile::Spanish {
            Profile::English
        } else {
            Profile::Spanish
        };
        match translate_source(&canonical, other, true) {
            Ok(translated) => match translate_source(&translated, example.profile, true) {
                Ok(back) if back == canonical => {}
                Ok(_) => failures.push(format!("{}: round trip differs", example.name)),
                Err(error) => failures.push(format!("{}: {error:?}", example.name)),
            },
            Err(_) => collisions = collisions.saturating_add(1),
        }
    }
    assert!(failures.is_empty(), "{failures:#?}");
    assert_eq!(
        collisions, 2,
        "the only identifiers reserved in the other language are `y`"
    );
    Ok(())
}

#[test]
fn formatting_is_stable_on_randomly_damaged_programs() -> Result<(), String> {
    let mut random = SeededRandom::new(7);
    let mut checked = 0usize;
    for example in examples()?.into_iter().step_by(6) {
        let mut session = DocumentSession::new(example.text.clone(), example.profile, true);
        for _ in 0..6 {
            let edit = random_edit(session.text(), &mut random);
            session.apply_text_edits(&[edit]);
            let first = format_source(session.text(), options(example.profile));
            let second = format_source(&first, options(example.profile));
            assert_eq!(first, second, "{}", example.name);
            checked = checked.saturating_add(1);
        }
    }
    assert!(checked > 100);
    Ok(())
}

#[test]
fn translation_never_panics_on_randomly_damaged_programs() -> Result<(), String> {
    let mut random = SeededRandom::new(11);
    for example in examples()?.into_iter().step_by(6) {
        let mut session = DocumentSession::new(example.text.clone(), example.profile, true);
        for _ in 0..6 {
            let edit = random_edit(session.text(), &mut random);
            session.apply_text_edits(&[edit]);
            let _ = translate_source(session.text(), Profile::English, true);
            let _ = translate_source(session.text(), Profile::Spanish, true);
        }
    }
    Ok(())
}
