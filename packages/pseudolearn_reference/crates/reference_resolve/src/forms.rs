use crate::Resolution;
use crate::spelling::fragment_tokens;
use reference_model::{FormSegment, Profile};

pub fn form_lines(
    resolution: &Resolution<'_>,
    form: &str,
    written_in: Profile,
) -> Vec<Vec<FormSegment>> {
    form.lines()
        .map(|line| form_line(resolution, line, written_in))
        .collect()
}

fn form_line(resolution: &Resolution<'_>, line: &str, written_in: Profile) -> Vec<FormSegment> {
    let mut segments = Vec::new();
    let mut code = String::new();
    let mut slot: Option<String> = None;
    for character in line.chars() {
        match (character, slot.as_mut()) {
            ('»', Some(_)) => {
                if let Some(text) = slot.take() {
                    segments.push(FormSegment::Slot { text });
                }
            }
            (_, Some(text)) => text.push(character),
            ('«', None) => {
                flush_code(resolution, (&mut code, written_in), &mut segments);
                slot = Some(String::new());
            }
            ('⟦' | '⟧', None) => {
                flush_code(resolution, (&mut code, written_in), &mut segments);
                segments.push(FormSegment::Optional {
                    text: character.to_string(),
                });
            }
            (_, None) => code.push(character),
        }
    }
    flush_code(resolution, (&mut code, written_in), &mut segments);
    segments
}

fn flush_code(
    resolution: &Resolution<'_>,
    (code, written_in): (&mut String, Profile),
    segments: &mut Vec<FormSegment>,
) {
    if code.is_empty() {
        return;
    }
    let text = std::mem::take(code);
    for token in fragment_tokens(resolution, &text, written_in) {
        segments.push(FormSegment::Token { token });
    }
}
