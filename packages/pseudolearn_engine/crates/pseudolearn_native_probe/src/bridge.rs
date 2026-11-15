use crate::measurement::{Configuration, measure};
use pseudolearn_aot_rt::EntryFunction;

#[unsafe(no_mangle)]
pub extern "C" fn pseudolearn_native_pair(
    entry: EntryFunction,
    configuration: *const u8,
    count: usize,
) -> i32 {
    match execute(entry, configuration, count) {
        Ok(document) => {
            println!("{document}");
            0
        }
        Err(error) => {
            eprintln!("{error}");
            1
        }
    }
}

fn configuration_bytes<'input>(pointer: *const u8, count: usize) -> Option<&'input [u8]> {
    if pointer.is_null() || count == 0 {
        None
    } else {
        Some(unsafe { std::slice::from_raw_parts(pointer, count) })
    }
}

fn execute(entry: EntryFunction, pointer: *const u8, count: usize) -> Result<String, String> {
    let bytes = configuration_bytes(pointer, count).ok_or("Missing configuration")?;
    let configuration: Configuration =
        serde_json::from_slice(bytes).map_err(|error| error.to_string())?;
    let pairs = measure(entry, &configuration)?;
    serde_json::to_string(&pairs).map_err(|error| error.to_string())
}
