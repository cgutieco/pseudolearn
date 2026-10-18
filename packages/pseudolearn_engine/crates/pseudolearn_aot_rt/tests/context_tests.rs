use pseudolearn_aot_rt::*;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::Cursor;

fn build(limits: AotLimits) -> AotSession {
    AotSession::new(
        AotConfig {
            limits,
            seed: 1,
            boolean_words: BooleanWords {
                truth: "true".to_owned(),
                falsity: "false".to_owned(),
            },
        },
        vec![FaultSite {
            lexeme: String::new(),
            code: DiagnosticCode::InternalFault,
            range: SourceRange::default(),
        }],
        AotStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(std::io::sink()),
        },
    )
}

#[test]
fn layout_offsets_are_the_contract_the_generated_code_reads() {
    assert_eq!(CONTEXT_HEAP_WORDS_OFFSET, 0);
    assert_eq!(CONTEXT_INSTRUCTION_REMAINING_OFFSET, 8);
    assert_eq!(CONTEXT_FRAME_DEPTH_OFFSET, 16);
    assert_eq!(CONTEXT_FRAME_LIMIT_OFFSET, 20);
    assert_eq!(CONTEXT_ROOT_TOP_OFFSET, 24);
    assert_eq!(CONTEXT_ROOT_CAPACITY_OFFSET, 28);
    assert_eq!(CONTEXT_ROOTS_OFFSET, 32);
    assert_eq!(CONTEXT_FAULT_SITE_OFFSET, 40);
    assert_eq!(CONTEXT_FAULT_STATUS_OFFSET, 44);
    assert_eq!(CONTEXT_RESULT_WORD_OFFSET, 48);
    assert_eq!(CONTEXT_CELLS_POINTER_OFFSET, 64);
    assert_eq!(CONTEXT_CELLS_LENGTH_OFFSET, 72);
    assert_eq!(CONTEXT_HEAP_USED_OFFSET, 80);
    assert_eq!(CONTEXT_HEAP_LIMIT_OFFSET, 88);
    assert_eq!(CONTEXT_HEAP_ORDINAL_OFFSET, 96);
    assert_eq!(CONTEXT_ROOM_CELLS_OFFSET, 104);
    assert_eq!(CONTEXT_ROOM_THRESHOLD_OFFSET, 112);
    assert_eq!(CONTEXT_FREE_SIZE_MASK_OFFSET, 120);
    assert_eq!(CONTEXT_PENDING_POINTER_OFFSET, 128);
    assert_eq!(CONTEXT_PENDING_LENGTH_OFFSET, 136);
    assert_eq!(CONTEXT_PENDING_CAPACITY_OFFSET, 144);
    assert_eq!(std::mem::size_of::<AotRuntimeContext>(), 152);
    assert_eq!(CELL_SLOT_WORD_OFFSET, 0);
    assert_eq!(CELL_SLOT_READABLE_OFFSET, 8);
    assert_eq!(CELL_SLOT_LOCAL_OFFSET, 16);
}

#[test]
fn defaults_start_without_statement_budget_and_with_one_thousand_frames() {
    let session = build(AotLimits::default());
    let context = session.context();
    assert_eq!(context.instruction_remaining, i64::MAX);
    assert_eq!(context.frame_limit, 1_000);
    assert_eq!(context.frame_depth, 0);
    assert_eq!(context.fault_status, STATUS_CONTINUE);
    assert!(!context.heap_words_pointer.is_null());
    assert!(!context.roots_pointer.is_null());
}

#[test]
fn explicit_budget_and_frames_are_published_in_the_context() {
    let limits = AotLimits {
        frames: 12,
        instruction_units: Some(500),
        ..AotLimits::default()
    };
    let session = build(limits);
    assert_eq!(session.context().instruction_remaining, 500);
    assert_eq!(session.context().frame_limit, 12);
}

#[test]
fn oversized_budget_saturates_instead_of_wrapping() {
    let limits = AotLimits {
        instruction_units: Some(u64::MAX),
        ..AotLimits::default()
    };
    assert_eq!(build(limits).context().instruction_remaining, i64::MAX);
}

#[test]
fn root_stack_rejects_pushes_beyond_capacity_and_pops_saturate() {
    let limits = AotLimits {
        root_capacity: 2,
        ..AotLimits::default()
    };
    let mut session = build(limits);
    assert!(session.push_root(5));
    assert!(session.push_root(6));
    assert!(!session.push_root(7));
    assert_eq!(session.context().root_top, 2);
    session.pop_roots(10);
    assert_eq!(session.context().root_top, 0);
}

#[test]
fn zero_root_capacity_rejects_every_push() {
    let limits = AotLimits {
        root_capacity: 0,
        ..AotLimits::default()
    };
    assert!(!build(limits).push_root(1));
}
