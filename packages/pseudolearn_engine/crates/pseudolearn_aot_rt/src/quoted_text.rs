use crate::context::AotRuntimeContext;
use crate::guard::run_entry;
use crate::trap::Trap;
use pseudolearn_abi::Handle;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_text_quote(
    context: *mut AotRuntimeContext,
    site: u32,
    handle: u32,
) -> u32 {
    run_entry(context, site, |entry| {
        let roots = entry.roots()?;
        pseudolearn_library::quote_text(&mut entry.engine.heap, Handle(handle), &roots)
            .map(|handle| u64::from(handle.0))
            .map_err(Trap::from)
    })
}
