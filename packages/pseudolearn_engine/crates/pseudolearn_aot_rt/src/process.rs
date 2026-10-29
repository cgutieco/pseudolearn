use crate::class_layout::ClassDescriptor;
use crate::config::{AotConfig, AotStreams};
use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_LIMIT};
use crate::effect_channel::EffectChannel;
use crate::metadata::{ExecutableMetadata, ExecutableSettings};
use crate::process_report::diagnostic_report;
use crate::session::AotSession;
use pseudolearn_diagnostics::DiagnosticCode;
use std::io::{BufRead, Write};

pub const EXIT_COMPLETED: i32 = 0;
pub const EXIT_FAILED: i32 = 3;
pub const EXIT_LIMIT: i32 = 4;
pub const EXIT_INTERNAL: i32 = 5;
pub const EXIT_REPLAY: i32 = 6;

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
    run_executable_with_effects(metadata, entry, streams, EffectChannel::standalone()).0
}

pub fn run_executable_with_effects(
    metadata: ExecutableMetadata,
    entry: EntryFunction,
    streams: ProcessStreams,
    effects: EffectChannel,
) -> (i32, EffectChannel) {
    let ExecutableMetadata {
        settings,
        sites,
        classes,
    } = metadata;
    let mut errors = streams.errors;
    let mut session = open_session(&settings, sites, (streams.input, streams.output));
    session.engine_mut().use_effects(effects);
    if !register_classes(&mut session, &classes) {
        return (EXIT_INTERNAL, take_effects(&mut session, false));
    }
    entry(session.context_pointer());
    if !crate::session::settle_session(&mut session) {
        return (EXIT_INTERNAL, take_effects(&mut session, false));
    }
    let _flushed = session.engine_mut().flush_output();
    let code = exit_code(&session);
    report_diagnostics(&session, &settings, &mut errors);
    let channel = take_effects(&mut session, code == EXIT_COMPLETED);
    let code = if channel.failure().is_some() {
        EXIT_REPLAY
    } else {
        code
    };
    (code, channel)
}

fn open_session(
    settings: &ExecutableSettings,
    sites: Vec<crate::fault::FaultSite>,
    (input, output): (Box<dyn BufRead>, Box<dyn Write>),
) -> AotSession {
    let config = AotConfig {
        limits: settings.limits,
        seed: settings.seed,
        boolean_words: settings.boolean_words.clone(),
    };
    let mut session = AotSession::new(config, sites, AotStreams { input, output });
    session
        .engine_mut()
        .use_site_boolean_words(settings.site_boolean_words.clone());
    if settings.forced_collection {
        session.engine_mut().force_collection();
    }
    session
}

fn take_effects(session: &mut AotSession, completed: bool) -> EffectChannel {
    let mut channel = std::mem::replace(
        session.engine_mut().effects_mut(),
        EffectChannel::standalone(),
    );
    if completed {
        channel.finish();
    } else {
        channel.abort();
    }
    pseudolearn_runtime::HostEffectProvider::close_all(&mut channel.provider);
    channel
}

fn report_diagnostics(
    session: &AotSession,
    settings: &ExecutableSettings,
    errors: &mut Box<dyn Write>,
) {
    let engine = session.engine();
    for record in engine.notices().iter().chain(engine.fault()) {
        let _written = errors.write_all(diagnostic_report(record, settings).as_bytes());
    }
    let _flushed = errors.flush();
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
