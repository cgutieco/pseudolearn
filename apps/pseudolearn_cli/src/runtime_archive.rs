pub static RUNTIME_ARCHIVE: &[u8] =
    include_bytes!(concat!(env!("OUT_DIR"), "/libpseudolearn_runtime_aot.a"));
