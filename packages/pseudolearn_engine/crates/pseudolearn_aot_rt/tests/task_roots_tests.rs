use pseudolearn_aot_rt::*;
use std::io::{Cursor, Write};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};

#[derive(Clone, Default)]
struct Sink(Arc<Mutex<Vec<u8>>>);

impl Write for Sink {
    fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
        if let Ok(mut buffer) = self.0.lock() {
            buffer.extend_from_slice(bytes);
        }
        Ok(bytes.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

const FIRST_SCOPE: u64 = 0;
const SCALAR: u64 = 0;
const REFERENCE: u64 = 1;

static SHARED_TEXT: AtomicU64 = AtomicU64::new(0);
static SHARED_CHANNEL: AtomicU64 = AtomicU64::new(0);

fn metadata() -> ExecutableMetadata {
    ExecutableMetadata {
        settings: ExecutableSettings {
            source_name: "p.pseudo".to_owned(),
            locale: "en".to_owned(),
            forced_collection: true,
            limits: AotLimits::default(),
            boolean_words: BooleanWords {
                truth: "true".to_owned(),
                falsity: "false".to_owned(),
            },
            site_boolean_words: Vec::new(),
            error_template: "{code}\n".to_owned(),
            warning_template: "{code}\n".to_owned(),
            information_template: "{code}\n".to_owned(),
            exhausted_template: "exhausted\n".to_owned(),
            source_names: Vec::new(),
        },
        sites: vec![FaultSite {
            lexeme: String::new(),
            code: DiagnosticCode::InternalFault,
            range: SourceRange {
                source_id: 0,
                start_line: 1,
                start_column: 1,
                end_line: 1,
                end_column: 2,
            },
        }],
        classes: Vec::new(),
    }
}

fn run(entry: EntryFunction, dispatcher: TaskDispatcher) -> (i32, String) {
    let output = Sink::default();
    let (code, _channel) = run_executable_with_tasks(
        metadata(),
        ProcessLaunch {
            entry,
            dispatcher: Some(dispatcher),
            seed: 0,
        },
        ProcessStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(output.clone()),
            errors: Box::new(Sink::default()),
        },
        EffectChannel::standalone(),
    );
    let text = output
        .0
        .lock()
        .map(|buffer| String::from_utf8_lossy(&buffer).into_owned())
        .unwrap_or_default();
    (code, text)
}

fn literal(context: *mut AotRuntimeContext, text: &str) -> Option<u64> {
    (rt_aot_text_literal(context, 0, text.as_ptr(), text.len()) == 0)
        .then(|| entry_result(context))
        .flatten()
}

fn fresh_text(context: *mut AotRuntimeContext, (left, right): (&str, &str)) -> Option<u64> {
    let left = literal(context, left)?;
    let right = literal(context, right)?;
    (rt_aot_text_concat(context, 0, left, right) == 0)
        .then(|| entry_result(context))
        .flatten()
}

fn collect_garbage(context: *mut AotRuntimeContext, rounds: usize) -> bool {
    (0..rounds).all(|_| fresh_text(context, ("gar", "bage")).is_some())
}

fn write_text(context: *mut AotRuntimeContext, handle: u64) -> u32 {
    rt_aot_write(context, 0, handle, KIND_REFERENCE | NEWLINE_FLAG)
}

fn spawn(context: *mut AotRuntimeContext, function: u64, reference: Option<u64>) -> bool {
    let packet: Vec<u64> = match reference {
        Some(handle) => vec![function, 1, REFERENCE, handle],
        None => vec![function, 0],
    };
    rt_aot_task_spawn(context, 0, FIRST_SCOPE, packet.as_ptr()) == 0
}

extern "C" fn spawn_with_the_only_reference(context: *mut AotRuntimeContext) {
    let Some(kept) = fresh_text(context, ("ke", "pt")) else {
        return;
    };
    SHARED_TEXT.store(kept, Ordering::SeqCst);
    if rt_aot_task_scope_open(context, 0) == 0
        && spawn(context, 1, Some(kept))
        && collect_garbage(context, 4)
    {
        rt_aot_task_scope_join(context, 0, FIRST_SCOPE);
    }
}

extern "C" fn write_the_shared_text(
    context: *mut AotRuntimeContext,
    _function: u32,
    _values: *const u64,
) {
    if collect_garbage(context, 2) {
        write_text(context, SHARED_TEXT.load(Ordering::SeqCst));
    }
}

#[test]
fn a_text_held_only_by_a_pending_task_survives_forced_collections() {
    let (code, output) = run(spawn_with_the_only_reference, write_the_shared_text);
    assert_eq!(output, "kept\n");
    assert_eq!(code, EXIT_COMPLETED);
}

extern "C" fn drop_the_only_reference(context: *mut AotRuntimeContext) {
    let Some(lost) = fresh_text(context, ("lo", "st")) else {
        return;
    };
    if collect_garbage(context, 4) {
        write_text(context, lost);
    }
}

#[test]
fn a_text_no_task_holds_is_reclaimed_by_a_forced_collection() {
    let (_code, output) = run(drop_the_only_reference, write_the_shared_text);
    assert_ne!(output, "lost\n");
}

extern "C" fn producer_and_consumer(context: *mut AotRuntimeContext) {
    let create = [2, SCALAR, SCALAR, 1, 1];
    if rt_aot_task_channel(context, 0, CHANNEL_NEW, create.as_ptr()) != 0 {
        return;
    }
    let Some(channel) = entry_result(context) else {
        return;
    };
    SHARED_CHANNEL.store(channel, Ordering::SeqCst);
    if rt_aot_task_scope_open(context, 0) == 0
        && spawn(context, 1, Some(channel))
        && spawn(context, 2, Some(channel))
    {
        rt_aot_task_scope_join(context, 0, FIRST_SCOPE);
    }
}

fn produce(context: *mut AotRuntimeContext, channel: u64) {
    let Some(message) = fresh_text(context, ("mes", "sage")) else {
        return;
    };
    let send = [2, REFERENCE, REFERENCE, channel, message];
    if rt_aot_task_channel(context, 0, CHANNEL_SEND, send.as_ptr()) == 0 {
        collect_garbage(context, 4);
    }
}

fn consume(context: *mut AotRuntimeContext, channel: u64) {
    let receive = [1, REFERENCE, channel];
    if collect_garbage(context, 2)
        && rt_aot_task_channel(context, 0, CHANNEL_RECEIVE, receive.as_ptr()) == 0
        && rt_aot_task_value_load(context, 0, 0) == 0
        && let Some(message) = entry_result(context)
    {
        write_text(context, message);
    }
}

extern "C" fn channel_roles(context: *mut AotRuntimeContext, function: u32, _values: *const u64) {
    let channel = SHARED_CHANNEL.load(Ordering::SeqCst);
    if function == 1 {
        produce(context, channel);
    } else {
        consume(context, channel);
    }
}

#[test]
fn a_message_waiting_in_a_channel_survives_forced_collections() {
    let (code, output) = run(producer_and_consumer, channel_roles);
    assert_eq!(output, "message\n");
    assert_eq!(code, EXIT_COMPLETED);
}

extern "C" fn await_a_completed_writer(context: *mut AotRuntimeContext) {
    let Some(kept) = fresh_text(context, ("af", "ter")) else {
        return;
    };
    SHARED_TEXT.store(kept, Ordering::SeqCst);
    if rt_aot_task_scope_open(context, 0) == 0
        && spawn(context, 1, Some(kept))
        && rt_aot_task_await(context, 0, 1, 1) == 0
        && collect_garbage(context, 3)
        && rt_aot_task_scope_join(context, 0, FIRST_SCOPE) == 0
    {
        rt_aot_write(context, 0, 7, KIND_INTEGER | NEWLINE_FLAG);
    }
}

#[test]
fn collections_after_a_task_completes_keep_the_program_running() {
    let (code, output) = run(await_a_completed_writer, write_the_shared_text);
    assert_eq!(output, "after\n7\n");
    assert_eq!(code, EXIT_COMPLETED);
}
