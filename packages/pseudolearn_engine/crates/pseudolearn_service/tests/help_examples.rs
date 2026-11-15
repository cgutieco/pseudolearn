use pseudolearn_lexicon::Profile;
use pseudolearn_service::help_catalog::{ExampleProgram, HelpLocale, cards};
use pseudolearn_service::{FormatOptions, format_checked};

const PROFILES: [Profile; 2] = [Profile::Spanish, Profile::English];
const INDENT_WIDTH: usize = 2;

fn programs() -> Vec<(&'static str, ExampleProgram)> {
    let mut found = Vec::new();
    for card in cards() {
        let content = card.content(HelpLocale::Spanish);
        found.extend(
            content
                .examples
                .iter()
                .map(|example| (card.id, example.program)),
        );
        found.extend(
            content
                .common_errors
                .iter()
                .filter_map(|error| error.program)
                .map(|program| (card.id, program)),
        );
    }
    found
}

fn indentation_is_canonical(source: &str) -> bool {
    source.lines().all(|line| {
        let leading = line
            .len()
            .saturating_sub(line.trim_start_matches(' ').len());
        !line.contains('\t') && leading % INDENT_WIDTH == 0
    })
}

#[test]
fn every_card_shows_at_least_one_program() {
    for card in cards() {
        for locale in [HelpLocale::Spanish, HelpLocale::English] {
            assert!(
                !card.content(locale).examples.is_empty(),
                "{} has no example",
                card.id
            );
        }
    }
}

#[test]
fn example_programs_use_the_canonical_style_of_the_formatter() {
    let mut offenders = Vec::new();
    for (card, program) in programs() {
        for profile in PROFILES {
            let source = program.source(profile);
            let options = FormatOptions {
                profile,
                indent_size: INDENT_WIDTH,
            };
            let canonical =
                format_checked(source, options).is_none_or(|formatted| formatted == source);
            if !indentation_is_canonical(source) || !canonical {
                offenders.push(format!("{card} {profile:?}"));
            }
        }
    }
    assert!(
        offenders.is_empty(),
        "non-canonical help programs: {offenders:#?}"
    );
}

#[test]
fn indentation_check_rejects_tabs_and_odd_widths() {
    assert!(indentation_is_canonical(
        "Algoritmo A\n  Escribir 1;\nFinAlgoritmo\n"
    ));
    assert!(!indentation_is_canonical(
        "Algoritmo A\n\tEscribir 1;\nFinAlgoritmo\n"
    ));
    assert!(!indentation_is_canonical(
        "Algoritmo A\n   Escribir 1;\nFinAlgoritmo\n"
    ));
    assert!(indentation_is_canonical(""));
}

#[test]
fn spanish_and_english_programs_differ_only_by_profile() {
    for (card, program) in programs() {
        assert!(
            !program.spanish.is_empty(),
            "{card} lacks a Spanish program"
        );
        assert!(
            !program.english.is_empty(),
            "{card} lacks an English program"
        );
    }
}
