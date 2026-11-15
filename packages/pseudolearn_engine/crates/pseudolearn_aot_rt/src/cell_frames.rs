use crate::context::AotRuntimeContext;
use crate::guard::run_entry;
use crate::trap::Trap;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_mark(context: *mut AotRuntimeContext, site: u32) -> u32 {
    run_entry(context, site, |entry| {
        u64::try_from(entry.engine.cells.len()).map_err(|_| Trap::named("internalFault"))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_cell_release(
    context: *mut AotRuntimeContext,
    site: u32,
    base: u32,
) -> u32 {
    run_entry(context, site, |entry| {
        let base = usize::try_from(base).map_err(|_| Trap::named("internalFault"))?;
        if base > entry.engine.cells.len() {
            return Err(Trap::named("internalFault"));
        }
        entry.engine.cells.truncate(base);
        Ok(0)
    })
}
