use crate::effect_channel::EffectChannel;
use crate::effect_document::{EffectInput, EffectOutput};
use crate::guard::borrow_slice;
use crate::metadata_codec::decode_metadata;
use crate::process::{
    EXIT_INTERNAL, EXIT_REPLAY, EntryFunction, ProcessStreams, run_executable_with_effects,
};
use std::io::{BufReader, BufWriter};

const EFFECTS_IN_FLAG: &str = "--effects-in";
const EFFECTS_OUT_FLAG: &str = "--effects-out";

#[unsafe(no_mangle)]
pub extern "C" fn pseudolearn_aot_main(
    entry: EntryFunction,
    metadata: *const u8,
    count: usize,
) -> i32 {
    let Some(bytes) = borrow_slice(metadata, count) else {
        return EXIT_INTERNAL;
    };
    let Some(decoded) = decode_metadata(bytes) else {
        return EXIT_INTERNAL;
    };
    let arguments: Vec<String> = std::env::args().collect();
    let channel = match open_channel(&arguments) {
        Ok(channel) => channel,
        Err(code) => {
            let _written = write_output(&arguments, &EffectOutput::rejected(code));
            return EXIT_REPLAY;
        }
    };
    let (code, channel) = run_executable_with_effects(
        decoded,
        entry,
        ProcessStreams {
            input: Box::new(BufReader::new(std::io::stdin())),
            output: Box::new(BufWriter::new(std::io::stdout())),
            errors: Box::new(std::io::stderr()),
        },
        channel,
    );
    if !write_output(&arguments, &EffectOutput::from_channel(&channel)) {
        return EXIT_INTERNAL;
    }
    code
}

fn flag_value<'arguments>(arguments: &'arguments [String], flag: &str) -> Option<&'arguments str> {
    arguments
        .iter()
        .position(|argument| argument == flag)
        .and_then(|index| index.checked_add(1))
        .and_then(|index| arguments.get(index))
        .map(String::as_str)
}

fn open_channel(arguments: &[String]) -> Result<EffectChannel, String> {
    let Some(path) = flag_value(arguments, EFFECTS_IN_FLAG) else {
        return Ok(EffectChannel::standalone());
    };
    let bytes = std::fs::read(path).map_err(|_| "effects_unreadable".to_owned())?;
    EffectInput::parse(&bytes)
        .ok_or_else(|| "effects_malformed".to_owned())?
        .into_channel()
}

fn write_output(arguments: &[String], output: &EffectOutput) -> bool {
    let Some(path) = flag_value(arguments, EFFECTS_OUT_FLAG) else {
        return true;
    };
    output
        .render()
        .is_some_and(|bytes| std::fs::write(path, bytes).is_ok())
}
