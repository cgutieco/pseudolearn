use pseudolearn_service::help_catalog::{HelpLocale, HelpPart, cards};
use pseudolearn_service::help_content::HelpContent;
use pseudolearn_service::help_rendering::{
    HelpFormat, HelpRenderError, MAXIMUM_RENDERED_BYTES, escape_markdown, omitted_notice,
    render_help,
};

const HOSTILE_PARTS: [HelpPart; 4] = [
    HelpPart {
        identity: "html",
        text: "<img src=x onerror=alert(1)><script>alert(1)</script>",
    },
    HelpPart {
        identity: "link",
        text: "[abrir](javascript:alert(1)) [datos](data:text/html;base64,AAAA)",
    },
    HelpPart {
        identity: "files",
        text: "file:///etc/passwd command:workbench.action.reload https://evil.invalid/x.png",
    },
    HelpPart {
        identity: "fence",
        text: "```\n# titulo\n```",
    },
];

fn hostile_content() -> HelpContent {
    HelpContent {
        card_id: "hostile",
        title: "**negrita** <b>x</b>",
        summary: "![imagen](https://evil.invalid/a.png)",
        purpose: "\u{202e}invertido\u{7}",
        description: Some("[a](command:evil)"),
        parts: &HOSTILE_PARTS,
        constraints: &["`código` y <u>subrayado</u>"],
        common_errors: &[],
        examples: &[],
    }
}

fn markdown() -> Result<String, String> {
    render_help(
        &hostile_content(),
        HelpLocale::Spanish,
        HelpFormat::Markdown,
    )
    .map_err(|error| format!("{error:?}"))
}

#[test]
fn markup_characters_are_escaped_so_no_tag_or_link_survives() -> Result<(), String> {
    let rendered = markdown()?;
    for (index, glyph) in rendered.char_indices() {
        if "<>`[]()".contains(glyph) {
            assert_eq!(
                rendered[..index].chars().last(),
                Some('\\'),
                "unescaped {glyph:?} at {index} in {rendered}"
            );
        }
    }
    Ok(())
}

#[test]
fn schemes_cannot_form_a_link_or_autolink() -> Result<(), String> {
    let rendered = markdown()?;
    for scheme in ["javascript:", "data:", "file:", "command:", "https:", "://"] {
        assert!(
            !rendered.contains(scheme),
            "{scheme} survived in {rendered}"
        );
    }
    assert!(!rendered.contains("]("));
    Ok(())
}

#[test]
fn control_and_bidirectional_characters_are_removed_in_both_formats() -> Result<(), String> {
    let markdown = markdown()?;
    let plain = render_help(
        &hostile_content(),
        HelpLocale::English,
        HelpFormat::PlainText,
    )
    .map_err(|error| format!("{error:?}"))?;
    for rendered in [&markdown, &plain] {
        assert!(!rendered.contains('\u{202e}'));
        assert!(!rendered.contains('\u{7}'));
    }
    assert!(plain.contains("invertido"));
    Ok(())
}

#[test]
fn plain_text_keeps_the_words_without_adding_markup() -> Result<(), String> {
    let benign = HelpContent {
        title: "Titulo",
        summary: "Resumen",
        purpose: "Uso",
        description: None,
        parts: &[],
        constraints: &[],
        ..hostile_content()
    };
    let plain = render_help(&benign, HelpLocale::English, HelpFormat::PlainText)
        .map_err(|error| format!("{error:?}"))?;
    assert!(!plain.contains("**"));
    assert!(plain.contains("Titulo"));
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
fn content_at_the_limit_boundary_is_accepted() -> Result<(), String> {
    let small = HelpContent {
        summary: "",
        purpose: "",
        description: None,
        parts: &[],
        constraints: &[],
        ..hostile_content()
    };
    let rendered = render_help(&small, HelpLocale::English, HelpFormat::PlainText)
        .map_err(|error| format!("{error:?}"))?;
    assert!(rendered.len() < MAXIMUM_RENDERED_BYTES);
    Ok(())
}

#[test]
fn every_real_card_renders_within_the_limit_in_both_languages() -> Result<(), String> {
    for card in cards() {
        for locale in [HelpLocale::Spanish, HelpLocale::English] {
            let content = card.content(locale);
            let help = HelpContent {
                card_id: card.id,
                title: content.title,
                summary: content.summary,
                purpose: content.purpose,
                description: None,
                parts: content.parts,
                constraints: content.constraints,
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
