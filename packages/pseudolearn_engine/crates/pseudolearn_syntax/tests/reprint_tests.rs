use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{parse_source, reprint_lossless};

fn verify_lossless_roundtrip(text: &str, profile: Profile) {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    let output = reprint_lossless(&source, &tree.tokens);
    assert_eq!(output, text);
}

fn extract_program_from_block(block: &serde_json::Value) -> Option<String> {
    if block.get("kind").and_then(serde_json::Value::as_str) != Some("caso") {
        return None;
    }
    block
        .get("fields")
        .and_then(|fields| fields.get("programa"))
        .and_then(serde_json::Value::as_str)
        .map(ToOwned::to_owned)
}

fn load_corpus_programs() -> Vec<String> {
    let export_path = concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/../../../pseudolearn_spec/specifications/export.json"
    );
    let content = match std::fs::read_to_string(export_path) {
        Ok(read_content) => read_content,
        Err(_) => return Vec::new(),
    };
    let parsed: serde_json::Value = match serde_json::from_str(&content) {
        Ok(parsed_json) => parsed_json,
        Err(_) => return Vec::new(),
    };
    let mut collected = Vec::new();
    let specifications = parsed
        .get("specifications")
        .and_then(serde_json::Value::as_array);
    for specification in specifications.into_iter().flatten() {
        let blocks = specification
            .get("blocks")
            .and_then(serde_json::Value::as_array);
        for block in blocks.into_iter().flatten() {
            if let Some(program_string) = extract_program_from_block(block) {
                collected.push(program_string);
            }
        }
    }
    collected
}

#[test]
fn verifies_lossless_reprint_property_one_on_corpus() {
    let programs = load_corpus_programs();
    assert!(!programs.is_empty());
    for program in &programs {
        verify_lossless_roundtrip(program, Profile::Spanish);
        verify_lossless_roundtrip(program, Profile::English);

        let with_bom = format!("\u{FEFF}{program}");
        verify_lossless_roundtrip(&with_bom, Profile::Spanish);

        let with_crlf = program.replace('\n', "\r\n");
        verify_lossless_roundtrip(&with_crlf, Profile::Spanish);

        let with_unclosed_string = format!("{program}\nEscribir \"cadena sin fin\n");
        verify_lossless_roundtrip(&with_unclosed_string, Profile::Spanish);

        let with_unrecognized = format!("{program}\nEscribir @@@ $$$ ###;\n");
        verify_lossless_roundtrip(&with_unrecognized, Profile::Spanish);
    }
}

#[test]
fn verifies_lossless_reprint_property_two_edges_and_random() {
    verify_lossless_roundtrip("", Profile::Spanish);
    verify_lossless_roundtrip("   \t  \r\n \n   ", Profile::Spanish);
    verify_lossless_roundtrip("// comment only\n/* block */\n", Profile::Spanish);
    verify_lossless_roundtrip("@#$%^&*", Profile::Spanish);

    let mut state: u64 = 0x1234_5678_9ABC_DEF0;
    for sample_index in 0..20 {
        let mut random_text = String::new();
        let target_size = 50 + (sample_index * 200);
        while random_text.len() < target_size {
            state = state.wrapping_mul(6364136223846793005).wrapping_add(1);
            let byte_choice = u8::try_from((state >> 32) & 0xFF).unwrap_or(0);
            let character = match byte_choice % 10 {
                0 => ' ',
                1 => '\n',
                2 => '\t',
                3 => 'a',
                4 => '1',
                5 => '+',
                6 => '"',
                7 => ';',
                8 => 'ñ',
                _ => '$',
            };
            random_text.push(character);
        }
        verify_lossless_roundtrip(&random_text, Profile::Spanish);
    }
}
