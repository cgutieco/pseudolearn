use crate::effect_channel::EffectChannel;
use crate::effect_document::{EffectInput, EffectOutput};
use crate::guard::borrow_slice;
use crate::metadata_codec::decode_metadata;
use crate::process::{
    EXIT_INTERNAL, EXIT_REPLAY, EntryFunction, ProcessLaunch, ProcessStreams,
    run_executable_with_tasks,
};
use crate::process_options::ProcessOptions;
use crate::task_state::TaskDispatcher;
use std::io::{BufReader, BufWriter};

#[unsafe(no_mangle)]
pub extern "C" fn pseudolearn_aot_main(
    entry: EntryFunction,
    metadata: *const u8,
    count: usize,
    dispatcher: Option<TaskDispatcher>,
) -> i32 {
    let Some(bytes) = borrow_slice(metadata, count) else {
        return EXIT_INTERNAL;
    };
    let Some(decoded) = decode_metadata(bytes) else {
        return EXIT_INTERNAL;
    };
    let arguments: Vec<String> = std::env::args().skip(1).collect();
    let (options, seed, channel) = match prepare(&arguments) {
        Ok(prepared) => prepared,
        Err(code) => return code,
    };
    let launch = ProcessLaunch {
        entry,
        dispatcher,
        seed,
    };
    let (code, channel) = run_executable_with_tasks(
        decoded,
        launch,
        ProcessStreams {
            input: Box::new(BufReader::new(std::io::stdin())),
            output: Box::new(BufWriter::new(std::io::stdout())),
            errors: Box::new(std::io::stderr()),
        },
        channel,
    );
    if !write_output(&options, &EffectOutput::from_channel(&channel)) {
        return EXIT_INTERNAL;
    }
    if code == crate::process::EXIT_COMPLETED && options.effects_out.is_none() {
        return i32::from(channel.requested_exit());
    }
    code
}

#[unsafe(no_mangle)]
pub extern "C" fn pseudolearn_aot_exit(code: i32) -> ! {
    std::process::exit(code)
}

fn prepare(arguments: &[String]) -> Result<(ProcessOptions, i64, EffectChannel), i32> {
    let options = ProcessOptions::parse(arguments).map_err(|error| {
        eprintln!("{error:?}");
        EXIT_INTERNAL
    })?;
    let seed = options
        .seed
        .or_else(|| pseudolearn_host::entropy_seed().ok())
        .ok_or(EXIT_INTERNAL)?;
    match open_channel(&options) {
        Ok(channel) => Ok((options, seed, channel)),
        Err(code) => {
            let _written = write_output(&options, &EffectOutput::rejected(code));
            Err(EXIT_REPLAY)
        }
    }
}

fn open_channel(options: &ProcessOptions) -> Result<EffectChannel, String> {
    let Some(path) = options.effects_in.as_deref() else {
        return Ok(EffectChannel::with_arguments(
            options.program_arguments.clone(),
        ));
    };
    let bytes = std::fs::read(path).map_err(|_| "effects_unreadable".to_owned())?;
    EffectInput::parse(&bytes)
        .ok_or_else(|| "effects_malformed".to_owned())?
        .into_channel(options.program_arguments.clone())
}

fn write_output(options: &ProcessOptions, output: &EffectOutput) -> bool {
    let Some(path) = options.effects_out.as_deref() else {
        return true;
    };
    output
        .render()
        .is_some_and(|bytes| std::fs::write(path, bytes).is_ok())
}
