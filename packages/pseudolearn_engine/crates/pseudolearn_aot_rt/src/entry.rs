use crate::effect_channel::EffectChannel;
use crate::effect_document::{EffectInput, EffectOutput};
use crate::guard::borrow_slice;
use crate::metadata::ExecutableMetadata;
use crate::metadata_codec::decode_metadata;
use crate::process::{
    EXIT_INTERNAL, EXIT_REPLAY, EntryFunction, ProcessLaunch, ProcessStreams,
    run_executable_with_tasks,
};
use crate::process_options::ProcessOptions;
use crate::task_state::TaskDispatcher;
use std::io::{BufReader, BufWriter, Write};

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
    let arguments = match process_arguments() {
        Ok(arguments) => arguments,
        Err(message) => {
            report(&message);
            return EXIT_INTERNAL;
        }
    };
    let (options, seed, channel) = match prepare(&arguments) {
        Ok(prepared) => prepared,
        Err(code) => return code,
    };
    let launch = ProcessLaunch {
        entry,
        dispatcher,
        seed,
    };
    let (code, channel) = run_with_standard_streams(decoded, launch, channel);
    if !write_output(&options, &EffectOutput::from_channel(&channel)) {
        return EXIT_INTERNAL;
    }
    if code == crate::process::EXIT_COMPLETED && options.effects_out.is_none() {
        return i32::from(channel.requested_exit());
    }
    code
}

fn run_with_standard_streams(
    metadata: ExecutableMetadata,
    launch: ProcessLaunch,
    channel: EffectChannel,
) -> (i32, EffectChannel) {
    run_executable_with_tasks(
        metadata,
        launch,
        ProcessStreams {
            input: Box::new(BufReader::new(std::io::stdin())),
            output: Box::new(BufWriter::new(std::io::stdout())),
            errors: Box::new(std::io::stderr()),
        },
        channel,
    )
}

#[unsafe(no_mangle)]
pub extern "C" fn pseudolearn_aot_exit(code: i32) -> ! {
    std::process::exit(code)
}

fn prepare(arguments: &[String]) -> Result<(ProcessOptions, i64, EffectChannel), i32> {
    let options = ProcessOptions::parse(arguments).map_err(|error| {
        report(&error.to_string());
        reject_invalid_options(arguments);
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

fn process_arguments() -> Result<Vec<String>, String> {
    std::env::args_os()
        .skip(1)
        .map(|argument| {
            argument
                .into_string()
                .map_err(|_| "process argument is not valid UTF-8".to_owned())
        })
        .collect()
}

fn report(message: &str) {
    let _ignored = writeln!(std::io::stderr(), "{message}");
}

fn reject_invalid_options(arguments: &[String]) {
    let Some(path) = ProcessOptions::requested_effects_out(arguments) else {
        return;
    };
    let options = ProcessOptions {
        effects_out: Some(path),
        ..ProcessOptions::default()
    };
    let _written = write_output(
        &options,
        &EffectOutput::rejected("options_invalid".to_owned()),
    );
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
