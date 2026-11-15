use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::{Handle, arena_length, text_content};
use std::io::Cursor;

fn session() -> AotSession {
    AotSession::new(
        AotConfig {
            limits: AotLimits::default(),
            seed: 7,
            boolean_words: BooleanWords {
                truth: "verdadero".to_owned(),
                falsity: "falso".to_owned(),
            },
        },
        Vec::new(),
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(std::io::sink()),
        },
    )
}

fn evaluate(session: &mut AotSession, bytes: &[u8]) -> Option<u64> {
    let status = rt_aot_text_literal(session.context_pointer(), 0, bytes.as_ptr(), bytes.len());
    (status == STATUS_CONTINUE).then(|| session.context().result_word)
}

fn content_of(session: &AotSession, word: u64) -> Option<String> {
    let handle = Handle(u32::try_from(word).ok()?);
    text_content(session.engine().heap(), handle)
        .ok()
        .map(str::to_owned)
}

#[test]
fn repeated_evaluations_of_a_literal_share_one_text() {
    let mut session = session();
    let first = evaluate(&mut session, "héllo".as_bytes());
    let arena = arena_length(session.engine().heap());
    for _ in 0..10_000 {
        assert_eq!(evaluate(&mut session, "héllo".as_bytes()), first);
    }
    assert_eq!(arena_length(session.engine().heap()), arena);
    assert_eq!(
        first.and_then(|word| content_of(&session, word)),
        Some("héllo".to_owned())
    );
}

#[test]
fn distinct_literals_keep_distinct_texts_including_the_empty_one() {
    let mut session = session();
    let empty = evaluate(&mut session, b"");
    let other = evaluate(&mut session, b"a");
    assert_ne!(empty, other);
    assert_eq!(evaluate(&mut session, b""), empty);
    assert_eq!(
        empty.and_then(|word| content_of(&session, word)),
        Some(String::new())
    );
    assert_eq!(
        other.and_then(|word| content_of(&session, word)),
        Some("a".to_owned())
    );
}

#[test]
fn a_shared_literal_survives_a_collection() {
    let mut session = session();
    let first = evaluate(&mut session, b"kept");
    session.engine_mut().force_collection();
    assert!(evaluate(&mut session, b"other").is_some());
    assert_eq!(evaluate(&mut session, b"kept"), first);
    assert_eq!(
        first.and_then(|word| content_of(&session, word)),
        Some("kept".to_owned())
    );
}

#[test]
fn invalid_utf8_is_rejected_on_every_evaluation() {
    for _ in 0..2 {
        let mut session = session();
        assert_eq!(evaluate(&mut session, &[0xff, 0xfe]), None);
        assert_eq!(
            session.engine().fault().and_then(|record| record.code),
            Some(DiagnosticCode::InternalFault)
        );
    }
    let mut session = session();
    assert_eq!(evaluate(&mut session, &[0xff, 0xfe]), None);
    assert_eq!(evaluate(&mut session, &[0xff, 0xfe]), None);
}
