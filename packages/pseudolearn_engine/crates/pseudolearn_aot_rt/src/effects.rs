use crate::context::AotRuntimeContext;
use crate::guard::{Entry, run_entry};
use crate::trap::Trap;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_effect_call(
    context: *mut AotRuntimeContext,
    site: u32,
    capability: u64,
    operation: u32,
) -> u32 {
    run_entry(context, site, |entry| perform_effect(entry, capability, operation))
}

fn perform_effect(_entry: &mut Entry<'_>, _capability: u64, _operation: u32) -> Result<u64, Trap> {
    Ok(0)
}
