use crate::spelling::keyword_spelling;
use crate::template_markers::{Markers, markers};
use crate::template_model::{Segment, StopRole, Template, stop, text};
use pseudolearn_lexicon::{KeywordKind, Profile};

type Word<'word> = &'word dyn Fn(KeywordKind) -> String;

pub fn build_template(construction: &str, profile: Profile) -> Option<Template> {
    let word = |kind| keyword_spelling(kind, profile);
    let marker = markers(profile);
    let segments = match construction {
        "switch" | "segun" => switch_segments(&word, &marker),
        "if" | "si" => if_segments(&word, &marker),
        "while" | "mientras" => while_segments(&word, &marker),
        "for" | "para" => for_segments(&word, &marker),
        "repeat" | "repetir" => repeat_segments(&word, &marker),
        "function" | "funcion" => function_segments(&word, &marker),
        "subroutine" | "subproceso" => subroutine_segments(&word, &marker),
        "class" | "clase" => class_segments(&word, &marker),
        "algorithm" | "algoritmo" => algorithm_segments(&word, &marker),
        _ => return None,
    };
    Some(Template { segments })
}

fn body(depth: usize) -> Vec<Segment> {
    vec![Segment::NewLine, Segment::Indent(depth)]
}

fn closing(word: Word<'_>, kind: KeywordKind) -> Vec<Segment> {
    vec![Segment::NewLine, text(word(kind))]
}

fn switch_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = vec![
        text(format!("{} ", word(KeywordKind::SwitchKeyword))),
        stop(1, StopRole::Expression, marker.expression),
        text(format!(" {}", word(KeywordKind::DoKeyword))),
    ];
    segments.extend(body(1));
    segments.push(stop(2, StopRole::Expression, marker.value));
    segments.push(text(":"));
    segments.extend(body(2));
    segments.push(Segment::Final);
    segments.extend(body(1));
    segments.push(text(format!("{}:", word(KeywordKind::DefaultCase))));
    segments.extend(body(2));
    segments.extend(closing(word, KeywordKind::EndSwitch));
    segments
}

fn if_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = vec![
        text(format!("{} ", word(KeywordKind::IfKeyword))),
        stop(1, StopRole::Expression, marker.condition),
        text(format!(" {}", word(KeywordKind::Then))),
    ];
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::ElseKeyword));
    segments.extend(body(1));
    segments.extend(closing(word, KeywordKind::EndIf));
    segments
}

fn while_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = vec![
        text(format!("{} ", word(KeywordKind::WhileKeyword))),
        stop(1, StopRole::Expression, marker.condition),
        text(format!(" {}", word(KeywordKind::DoKeyword))),
    ];
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::EndWhile));
    segments
}

fn for_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = vec![
        text(format!("{} ", word(KeywordKind::ForKeyword))),
        stop(1, StopRole::NewIdentifier, marker.index),
        text(format!(" <- 1 {} ", word(KeywordKind::To))),
        stop(2, StopRole::Expression, marker.limit),
        text(format!(
            " {} 1 {}",
            word(KeywordKind::Step),
            word(KeywordKind::DoKeyword)
        )),
    ];
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::EndFor));
    segments
}

fn repeat_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = vec![text(word(KeywordKind::Repeat))];
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.push(Segment::NewLine);
    segments.push(text(format!("{} ", word(KeywordKind::Until))));
    segments.push(stop(1, StopRole::Expression, marker.condition));
    segments
}

fn unit_header(word: Word<'_>, marker: &Markers, opener: KeywordKind) -> Vec<Segment> {
    vec![
        text(format!("{} ", word(opener))),
        stop(1, StopRole::NewIdentifier, marker.name),
    ]
}

fn callable_header(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = unit_header(word, marker, KeywordKind::Subroutine);
    segments.push(text("("));
    segments.push(stop(2, StopRole::NewIdentifier, marker.parameter));
    segments.push(text(")"));
    segments
}

fn function_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = callable_header(word, marker);
    segments.push(text(format!(
        " {} {}",
        word(KeywordKind::TypeConnector),
        word(KeywordKind::IntegerType)
    )));
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::EndSubroutine));
    segments
}

fn subroutine_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = callable_header(word, marker);
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::EndSubroutine));
    segments
}

fn class_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = vec![
        text(format!("{} ", word(KeywordKind::ClassKeyword))),
        stop(1, StopRole::NewIdentifier, marker.class_name),
    ];
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::EndClass));
    segments
}

fn algorithm_segments(word: Word<'_>, marker: &Markers) -> Vec<Segment> {
    let mut segments = unit_header(word, marker, KeywordKind::Algorithm);
    segments.extend(body(1));
    segments.push(Segment::Final);
    segments.extend(closing(word, KeywordKind::EndAlgorithm));
    segments
}
