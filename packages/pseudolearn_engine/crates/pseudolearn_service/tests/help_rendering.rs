use pseudolearn_lexicon::Profile;
use pseudolearn_service::help_catalog::{
    ExampleProgram, FormLine, FormPiece, FormSegment, HelpCategory, HelpCommonError, HelpExample,
    HelpLocale, HelpPart, HelpSlot, cards,
};
use pseudolearn_service::help_content::HelpContent;
use pseudolearn_service::help_rendering::{
    HelpFormat, HelpRenderError, MAXIMUM_RENDERED_BYTES, escape_markdown, omitted_notice,
    render_help,
};

const HOSTILE_PARTS: [HelpPart; 1] = [HelpPart {
    identity: "algorithm",
    text: "<img src=x onerror=alert(1)><script>alert(1)</script>",
    spanish_lexeme: "Algoritmo",
    english_lexeme: "Algorithm",
}];

const HOSTILE_SLOTS: [HelpSlot; 1] = [HelpSlot {
    id: "name",
    label: "nombre",
    text: "[abrir](javascript:alert(1)) [datos](data:text/html;base64,AAAA)",
}];

const FORM: [FormLine; 3] = [
    FormLine {
        indent: 0,
        pieces: &[
            FormPiece {
                segment: FormSegment::Code {
                    identity: "algorithm",
                    text: "Algoritmo",
                },
                joined: false,
            },
            FormPiece {
                segment: FormSegment::Slot("name"),
                joined: false,
            },
        ],
    },
    FormLine {
        indent: 1,
        pieces: &[FormPiece {
            segment: FormSegment::Ellipsis,
            joined: false,
        }],
    },
    FormLine {
        indent: 0,
        pieces: &[FormPiece {
            segment: FormSegment::Code {
                identity: "semicolon",
                text: ";",
            },
            joined: true,
        }],
    },
];

const PROGRAM: ExampleProgram = ExampleProgram {
    spanish: "Algoritmo Saludo\n  Escribir \"```\";\nFinAlgoritmo\n",
    english: "Algorithm Greeting\n  Write \"```\";\nEndAlgorithm\n",
    output: Some("```\n"),
};

const EXAMPLES: [HelpExample; 1] = [HelpExample {
    specification: "LANG.SAMPLE",
    version: "1.0.0",
    case: "C1",
    kind: "executable",
    note: "file:///etc/passwd command:workbench.action.reload https://evil.invalid/x.png",
    program: PROGRAM,
}];

const ERRORS: [HelpCommonError; 1] = [HelpCommonError {
    text: "```\n# titulo\n```",
    program: None,
}];

fn hostile_content() -> HelpContent {
    HelpContent {
        card_id: "hostile",
        title: "**negrita** <b>x</b>",
        summary: "![imagen](https://evil.invalid/a.png) \u{202e}invertido\u{7}",
        description: Some("[a](command:evil)"),
        category: HelpCategory::Block,
        profile: Profile::Spanish,
        form: &FORM,
        parts: &HOSTILE_PARTS,
        slots: &HOSTILE_SLOTS,
        result: Some("`código` y <u>subrayado</u>"),
        rules: &["<i>regla</i>"],
        common_errors: &ERRORS,
        examples: &EXAMPLES,
    }
}

fn render(content: &HelpContent, format: HelpFormat) -> Result<String, String> {
    render_help(content, HelpLocale::Spanish, format).map_err(|error| format!("{error:?}"))
}

fn prose_only(rendered: &str) -> String {
    let mut prose = String::new();
    let mut inside_fence = false;
    for line in rendered.lines() {
        if line.starts_with("```") {
            inside_fence = !inside_fence;
        } else if !inside_fence {
            prose.push_str(line);
            prose.push('\n');
        }
    }
    prose
}

#[test]
fn prose_markup_is_escaped_so_no_tag_or_link_survives() -> Result<(), String> {
    let prose = prose_only(&render(&hostile_content(), HelpFormat::Markdown)?);
    for (index, glyph) in prose.char_indices() {
        if "<>[]()".contains(glyph) {
            assert_eq!(
                prose[..index].chars().last(),
                Some('\\'),
                "unescaped {glyph:?} at {index} in {prose}"
            );
        }
    }
    assert!(!prose.lines().any(|line| line.starts_with('#')));
    for scheme in ["javascript:", "data:", "file:", "command:", "https:", "://"] {
        assert!(!prose.contains(scheme), "{scheme} survived in {prose}");
    }
    Ok(())
}

#[test]
fn code_fences_are_longer_than_any_backtick_run_in_the_program() -> Result<(), String> {
    let rendered = render(&hostile_content(), HelpFormat::Markdown)?;
    assert!(rendered.contains("````\nAlgoritmo Saludo\n  Escribir \"```\";\nFinAlgoritmo\n````"));
    assert!(rendered.contains("````\n```\n````"));
    Ok(())
}

#[test]
fn form_shows_slots_indentation_ellipsis_and_joined_pieces() -> Result<(), String> {
    let rendered = render(&hostile_content(), HelpFormat::Markdown)?;
    assert!(rendered.contains("```\nAlgoritmo «nombre»\n  ...\n;\n```"));
    Ok(())
}

#[test]
fn parts_follow_the_form_and_name_words_by_their_profile_lexeme() -> Result<(), String> {
    let english = HelpContent {
        profile: Profile::English,
        ..hostile_content()
    };
    let plain = render(&english, HelpFormat::PlainText)?;
    let word = plain.find("- Algorithm:").ok_or("missing word part")?;
    let slot = plain.find("- «nombre»:").ok_or("missing slot part")?;
    assert!(word < slot);
    assert!(plain.contains("    Algorithm Greeting\n      Write"));
    Ok(())
}

#[test]
fn control_and_bidirectional_characters_are_removed_in_both_formats() -> Result<(), String> {
    for format in [HelpFormat::Markdown, HelpFormat::PlainText] {
        let rendered = render(&hostile_content(), format)?;
        assert!(!rendered.contains('\u{202e}'));
        assert!(!rendered.contains('\u{7}'));
        assert!(rendered.contains("invertido"));
    }
    Ok(())
}

#[test]
fn plain_text_keeps_the_words_without_adding_markup() -> Result<(), String> {
    let benign = HelpContent {
        title: "Titulo",
        ..hostile_content()
    };
    let plain = render(&benign, HelpFormat::PlainText)?;
    assert!(!plain.contains("**"));
    assert!(plain.starts_with("Titulo\n\nBloque"));
    assert!(plain.contains("Resultado"));
    Ok(())
}

#[test]
fn empty_sections_are_left_out() -> Result<(), String> {
    let minimal = HelpContent {
        result: None,
        rules: &[],
        common_errors: &[],
        ..hostile_content()
    };
    let plain = render(&minimal, HelpFormat::PlainText)?;
    for label in ["Devuelve", "Reglas", "Errores comunes"] {
        assert!(!plain.contains(label), "{label} rendered while empty");
    }
    Ok(())
}

#[test]
fn oversized_content_is_a_typed_error_not_a_truncation() {
    let long: &'static str = Box::leak("x".repeat(MAXIMUM_RENDERED_BYTES).into_boxed_str());
    let content = HelpContent {
        summary: long,
        ..hostile_content()
    };
    for format in [HelpFormat::Markdown, HelpFormat::PlainText] {
        assert_eq!(
            render_help(&content, HelpLocale::English, format),
            Err(HelpRenderError::TooLarge {
                limit: MAXIMUM_RENDERED_BYTES
            })
        );
    }
}

#[test]
fn every_real_card_renders_within_the_limit_in_every_language_and_profile() -> Result<(), String> {
    for card in cards() {
        for (locale, profile) in [
            (HelpLocale::Spanish, Profile::Spanish),
            (HelpLocale::Spanish, Profile::English),
            (HelpLocale::English, Profile::English),
            (HelpLocale::English, Profile::Spanish),
        ] {
            let content = card.content(locale);
            let help = HelpContent {
                card_id: card.id,
                title: content.title,
                summary: content.summary,
                description: None,
                category: card.category,
                profile,
                form: card.form(profile),
                parts: content.parts,
                slots: content.slots,
                result: content.result,
                rules: content.rules,
                common_errors: content.common_errors,
                examples: content.examples,
            };
            for format in [HelpFormat::Markdown, HelpFormat::PlainText] {
                render_help(&help, locale, format)
                    .map_err(|error| format!("{} {error:?}", card.id))?;
            }
        }
    }
    Ok(())
}

#[test]
fn escaping_is_idempotent_free_of_new_control_characters() {
    let escaped = escape_markdown("a_b *c* [d](e) :/@");
    assert_eq!(escaped, "a\\_b \\*c\\* \\[d\\]\\(e\\) \\:\\/\\@");
    assert!(!omitted_notice(HelpLocale::Spanish).is_empty());
    assert!(!omitted_notice(HelpLocale::English).is_empty());
}
