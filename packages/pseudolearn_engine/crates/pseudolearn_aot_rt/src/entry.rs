use crate::guard::borrow_slice;
use crate::metadata_codec::decode_metadata;
use crate::process::{EXIT_INTERNAL, EntryFunction, ProcessStreams, run_executable};
use std::io::{BufReader, BufWriter};

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
    run_executable(
        decoded,
        entry,
        ProcessStreams {
            input: Box::new(BufReader::new(std::io::stdin())),
            output: Box::new(BufWriter::new(std::io::stdout())),
            errors: Box::new(std::io::stderr()),
        },
    )
}
