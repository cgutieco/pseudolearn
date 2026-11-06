use crate::context::AotRuntimeContext;
use crate::guard::run_entry;
use crate::trap::Trap;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_random_real(context: *mut AotRuntimeContext, site: u32) -> u32 {
    run_entry(context, site, |entry| {
        Ok(entry.engine.random.next_real().to_bits())
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_random_below(
    context: *mut AotRuntimeContext,
    site: u32,
    bound: i64,
) -> u32 {
    run_entry(context, site, |entry| {
        let value = u64::try_from(bound)
            .ok()
            .and_then(|bound| entry.engine.random.next_below(bound))
            .and_then(|value| i64::try_from(value).ok())
            .ok_or_else(|| Trap::named("invalidRandomBound"))?;
        Ok(u64::from_ne_bytes(value.to_ne_bytes()))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_random_between(
    context: *mut AotRuntimeContext,
    site: u32,
    low: i64,
    high: i64,
) -> u32 {
    run_entry(context, site, |entry| {
        let value = entry
            .engine
            .random
            .next_between(low, high)
            .ok_or_else(|| Trap::named("invalidRandomRange"))?;
        Ok(u64::from_ne_bytes(value.to_ne_bytes()))
    })
}
