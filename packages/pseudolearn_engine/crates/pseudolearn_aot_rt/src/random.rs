use crate::context::AotRuntimeContext;
use crate::guard::run_entry;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_random_real(context: *mut AotRuntimeContext, site: u32) -> u32 {
    run_entry(context, site, |entry| {
        Ok(entry.engine.random.next_real().to_bits())
    })
}
