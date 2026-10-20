use pseudolearn_lexicon::Profile;
use pseudolearn_service::insertion::line_indent;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::template_model::{Segment, StopRole, Template, stop, text};
use pseudolearn_service::template_render::render_snippet;
use pseudolearn_service::{
    DocumentSession, apply_change, build_insertion, template_constructions, template_outline,
    template_stops_valid,
};

fn accept(marked: &str, label: &str, profile: Profile) -> Result<(String, (usize, usize)), String> {
    let (clean, position) = split_cursor(marked);
    let session = DocumentSession::new(clean.clone(), profile, true);
    let result = session.queries().complete_with_edit(position);
    let entry = result
        .entries
        .iter()
        .find(|entry| entry.label == label)
        .ok_or_else(|| format!("{label} not offered"))?;
    let insertion = build_insertion(entry, &result.text_edit, &clean, profile);
    Ok((apply_change(&clean, &insertion.edit), insertion.selection))
}

#[test]
fn every_construction_declares_stops_on_identifiers_in_both_profiles() {
    for construction in template_constructions() {
        for profile in [Profile::Spanish, Profile::English] {
            assert!(
                template_stops_valid(construction, profile),
                "{construction} {profile:?}"
            );
        }
    }
}

#[test]
fn unknown_constructions_have_no_outline_and_invalid_stops() {
    assert_eq!(template_outline("missing", Profile::Spanish), None);
    assert!(!template_stops_valid("missing", Profile::English));
}

#[test]
fn outline_orders_stops_by_index_and_ends_with_a_final_stop() -> Result<(), String> {
    let outline = template_outline("for", Profile::English).ok_or("missing outline")?;
    let indices: Vec<u8> = outline.stops.iter().map(|found| found.index).collect();
    assert_eq!(indices, vec![1, 2]);
    assert!(outline.snippet.contains("$0"));
    assert!(outline.snippet.starts_with("For ${1:index}"));
    Ok(())
}

#[test]
fn snippet_escapes_reserved_characters() {
    let template = Template {
        segments: vec![
            text("a$b}c\\"),
            stop(1, StopRole::Expression, "x"),
            Segment::Final,
        ],
    };
    assert_eq!(render_snippet(&template, "  "), "a\\$b\\}c\\\\${1:x}$0");
}

#[test]
fn snippet_without_final_segment_ends_with_the_final_stop() {
    let template = Template {
        segments: vec![text("abc")],
    };
    assert_eq!(render_snippet(&template, "  "), "abc$0");
}

#[test]
fn templates_are_reindented_with_the_destination_line() -> Result<(), String> {
    let marked = "Algoritmo Principal\n  Mie|\nFinAlgoritmo\n";
    let (text, selection) = accept(marked, "Mientras", Profile::Spanish)?;
    assert_eq!(
        text,
        "Algoritmo Principal\n  Mientras condicion Hacer\n    \n  FinMientras\nFinAlgoritmo\n"
    );
    assert_eq!(&text[selection.0..selection.1], "condicion");
    Ok(())
}

#[test]
fn nested_templates_use_the_enclosing_indentation() -> Result<(), String> {
    let marked = "Algoritmo A\n  Si 1 = 1 Entonces\n    Par|\n  FinSi\nFinAlgoritmo\n";
    let (text, _) = accept(marked, "Para", Profile::Spanish)?;
    assert!(
        text.contains("    Para indice <- 1 Hasta limite Con Paso 1 Hacer\n      \n    FinPara\n")
    );
    Ok(())
}

#[test]
fn calls_carry_one_stop_per_parameter() -> Result<(), String> {
    let marked = "SubProceso Sumar(a Por Valor, b Por Valor)\nFinSubProceso\nAlgoritmo P\n  Sum|\nFinAlgoritmo\n";
    let (text, selection) = accept(marked, "Sumar", Profile::Spanish)?;
    assert!(text.contains("  Sumar(a, b)\n"));
    assert_eq!(&text[selection.0..selection.1], "a");
    Ok(())
}

#[test]
fn calls_without_parameters_leave_the_caret_after_the_parentheses() -> Result<(), String> {
    let marked = "SubProceso Avisar()\nFinSubProceso\nAlgoritmo P\n  Avi|\nFinAlgoritmo\n";
    let (text, selection) = accept(marked, "Avisar", Profile::Spanish)?;
    assert!(text.contains("  Avisar()\n"));
    assert_eq!(selection.0, selection.1);
    assert_eq!(&text[..selection.0].chars().last(), &Some(')'));
    Ok(())
}

#[test]
fn plain_candidates_leave_the_caret_after_the_inserted_text() -> Result<(), String> {
    let (text, selection) = accept(
        "Algoritmo P\n  Esc|\nFinAlgoritmo\n",
        "Escribir",
        Profile::Spanish,
    )?;
    assert!(text.contains("  Escribir\n"));
    assert_eq!(selection.0, selection.1);
    Ok(())
}

#[test]
fn line_indent_handles_boundaries() {
    assert_eq!(line_indent("", 0), "");
    assert_eq!(line_indent("    x", 5), "    ");
    assert_eq!(line_indent("a\n   \nb", 4), "   ");
    assert_eq!(line_indent("abc", 99), "");
}
