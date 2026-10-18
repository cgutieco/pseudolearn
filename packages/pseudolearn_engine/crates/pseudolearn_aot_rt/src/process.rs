use crate::class_layout::ClassDescriptor;
use crate::config::{AotConfig, AotStreams};
use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_LIMIT};
use crate::metadata::ExecutableMetadata;
use crate::process_report::fault_report;
use crate::session::AotSession;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::{BufRead, Write};

pub const EXIT_COMPLETED: i32 = 0;
pub const EXIT_FAILED: i32 = 3;
pub const EXIT_LIMIT: i32 = 4;
pub const EXIT_INTERNAL: i32 = 5;

pub type EntryFunction = extern "C" fn(*mut AotRuntimeContext);

pub struct ProcessStreams {
    pub input: Box<dyn BufRead>,
    pub output: Box<dyn Write>,
    pub errors: Box<dyn Write>,
}

pub fn run_executable(
    metadata: ExecutableMetadata,
    entry: EntryFunction,
    streams: ProcessStreams,
) -> i32 {
    let ExecutableMetadata {
        settings,
        sites,
        classes,
    } = metadata;
    let config = AotConfig {
        limits: settings.limits,
        seed: settings.seed,
        boolean_words: settings.boolean_words.clone(),
    };
    let mut errors = streams.errors;
    let program_streams = AotStreams {
        input: streams.input,
        output: streams.output,
    };
    let mut session = AotSession::new(config, sites, program_streams);
    if !register_classes(&mut session, &classes) {
        return EXIT_INTERNAL;
    }
    entry(session.context_pointer());
    let _flushed = session.engine_mut().flush_output();
    let code = exit_code(&session);
    if code != EXIT_COMPLETED {
        if let Some(record) = session.engine().fault() {
            let _written = errors.write_all(fault_report(record, &settings).as_bytes());
        }
        let _flushed = errors.flush();
    }
    code
}

fn register_classes(session: &mut AotSession, classes: &[ClassDescriptor]) -> bool {
    classes.iter().enumerate().all(|(index, class)| {
        u32::try_from(index).ok().is_some_and(|identifier| {
            session
                .engine_mut()
                .register_class(identifier, class)
                .is_ok()
        })
    })
}

fn exit_code(session: &AotSession) -> i32 {
    let status = session.context().fault_status;
    if status == STATUS_CONTINUE {
        return EXIT_COMPLETED;
    }
    let Some(record) = session.engine().fault() else {
        return EXIT_INTERNAL;
    };
    if status == STATUS_LIMIT {
        EXIT_LIMIT
    } else if record.code == Some(DiagnosticCode::InternalFault) {
        EXIT_INTERNAL
    } else {
        EXIT_FAILED
    }
}
