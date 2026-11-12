use pseudolearn_aot_rt::*;
use std::io::{Cursor, Write};
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

impl Sink {
    fn text(&self) -> String {
        self.0
            .lock()
            .map(|buffer| String::from_utf8_lossy(&buffer).into_owned())
            .unwrap_or_default()
    }
}

const FIRST_SCOPE: u64 = 0;
const FIRST_TASK: u64 = 1;
const SECOND_TASK: u64 = 2;
const THIRD_TASK: u64 = 3;
const AGGREGATE: u32 = 1;

fn metadata(tasks: u64) -> ExecutableMetadata {
    ExecutableMetadata {
        settings: ExecutableSettings {
            source_name: "p.pseudo".to_owned(),
            locale: "en".to_owned(),
            forced_collection: false,
            limits: AotLimits {
                tasks,
                ..AotLimits::default()
            },
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

struct Outcome {
    code: i32,
    output: String,
    errors: String,
}

fn run(tasks: u64, entry: EntryFunction, dispatcher: TaskDispatcher) -> Outcome {
    let output = Sink::default();
    let errors = Sink::default();
    let (code, _channel) = run_executable_with_tasks(
        metadata(tasks),
        ProcessLaunch {
            entry,
            dispatcher: Some(dispatcher),
            seed: 0,
        },
        ProcessStreams {
            input: Box::new(Cursor::new(Vec::new())),
            output: Box::new(output.clone()),
            errors: Box::new(errors.clone()),
        },
        EffectChannel::standalone(),
    );
    Outcome {
        code,
        output: output.text(),
        errors: errors.text(),
    }
}

fn spawn_function(context: *mut AotRuntimeContext, function: u64) -> u32 {
    let packet = [function, 0];
    rt_aot_task_spawn(context, 0, FIRST_SCOPE, packet.as_ptr())
}

fn write_number(context: *mut AotRuntimeContext, function: u32) {
    rt_aot_write(context, 0, u64::from(function), KIND_INTEGER | NEWLINE_FLAG);
}

fn open_and_spawn(context: *mut AotRuntimeContext, functions: &[u64]) -> bool {
    rt_aot_task_scope_open(context, 0) == 0
        && functions
            .iter()
            .all(|function| spawn_function(context, *function) == 0)
}

extern "C" fn three_writers(context: *mut AotRuntimeContext) {
    if open_and_spawn(context, &[1, 2, 3]) && rt_aot_task_scope_join(context, 0, FIRST_SCOPE) == 0 {
        rt_aot_write(context, 0, 0, KIND_INTEGER | NEWLINE_FLAG);
    }
}

extern "C" fn write_own_number(
    context: *mut AotRuntimeContext,
    function: u32,
    _values: *const u64,
) {
    write_number(context, function);
}

#[test]
fn ready_tasks_start_in_spawn_order_and_the_join_waits_for_all() {
    let outcome = run(16, three_writers, write_own_number);
    assert_eq!(outcome.output, "1\n2\n3\n0\n");
    assert_eq!(outcome.code, EXIT_COMPLETED);
    assert_eq!(outcome.errors, "");
}

extern "C" fn two_waiters_and_a_writer(context: *mut AotRuntimeContext) {
    if open_and_spawn(context, &[1, 2, 3]) {
        rt_aot_task_scope_join(context, 0, FIRST_SCOPE);
    }
}

extern "C" fn wait_for_the_third(
    context: *mut AotRuntimeContext,
    function: u32,
    _values: *const u64,
) {
    if function == 3 || rt_aot_task_await(context, 0, THIRD_TASK, AGGREGATE) == 0 {
        write_number(context, function);
    }
}

#[test]
fn every_waiter_wakes_in_the_order_it_started_waiting() {
    let outcome = run(16, two_waiters_and_a_writer, wait_for_the_third);
    assert_eq!(outcome.output, "3\n1\n2\n");
    assert_eq!(outcome.code, EXIT_COMPLETED);
}

extern "C" fn two_mutual_waiters(context: *mut AotRuntimeContext) {
    if open_and_spawn(context, &[1, 2]) && rt_aot_task_scope_join(context, 0, FIRST_SCOPE) == 0 {
        rt_aot_write(context, 0, 9, KIND_INTEGER | NEWLINE_FLAG);
    }
}

extern "C" fn wait_for_each_other(
    context: *mut AotRuntimeContext,
    function: u32,
    _values: *const u64,
) {
    let other = if function == 1 {
        SECOND_TASK
    } else {
        FIRST_TASK
    };
    write_number(context, function);
    if rt_aot_task_await(context, 0, other, AGGREGATE) == 0 {
        rt_aot_write(context, 0, 8, KIND_INTEGER | NEWLINE_FLAG);
    }
}

#[test]
fn tasks_that_wait_for_each_other_end_in_a_task_deadlock() {
    let outcome = run(16, two_mutual_waiters, wait_for_each_other);
    assert_eq!(outcome.output, "1\n2\n");
    assert_eq!(outcome.code, EXIT_FAILED);
    assert_eq!(outcome.errors, "taskDeadlock\n");
}

#[test]
fn spawning_beyond_the_task_limit_stops_the_program() {
    let outcome = run(2, three_writers, write_own_number);
    assert_eq!(outcome.output, "");
    assert_ne!(outcome.code, EXIT_COMPLETED);
    assert_eq!(outcome.errors, "taskLimitExceeded\n");
}

#[test]
fn a_limit_that_fits_every_live_task_completes() {
    let outcome = run(4, three_writers, write_own_number);
    assert_eq!(outcome.output, "1\n2\n3\n0\n");
    assert_eq!(outcome.code, EXIT_COMPLETED);
}

extern "C" fn yield_without_mass(context: *mut AotRuntimeContext) {
    if open_and_spawn(context, &[1]) && rt_aot_task_yield(context, 0) == 0 {
        rt_aot_write(context, 0, 0, KIND_INTEGER | NEWLINE_FLAG);
        rt_aot_task_scope_join(context, 0, FIRST_SCOPE);
    }
}

#[test]
fn a_yield_check_below_the_quantum_keeps_the_running_task() {
    let outcome = run(16, yield_without_mass, write_own_number);
    assert_eq!(outcome.output, "0\n1\n");
    assert_eq!(outcome.code, EXIT_COMPLETED);
}

extern "C" fn scope_without_tasks(context: *mut AotRuntimeContext) {
    if open_and_spawn(context, &[]) && rt_aot_task_scope_join(context, 0, FIRST_SCOPE) == 0 {
        rt_aot_write(context, 0, 5, KIND_INTEGER | NEWLINE_FLAG);
    }
}

#[test]
fn an_empty_scope_joins_immediately() {
    let outcome = run(16, scope_without_tasks, write_own_number);
    assert_eq!(outcome.output, "5\n");
    assert_eq!(outcome.code, EXIT_COMPLETED);
}

extern "C" fn join_of_an_unknown_scope(context: *mut AotRuntimeContext) {
    if rt_aot_task_scope_join(context, 0, 41) == 0 {
        rt_aot_write(context, 0, 5, KIND_INTEGER | NEWLINE_FLAG);
    }
}

#[test]
fn joining_a_scope_that_was_never_opened_is_an_internal_fault() {
    let outcome = run(16, join_of_an_unknown_scope, write_own_number);
    assert_eq!(outcome.code, EXIT_INTERNAL);
}
