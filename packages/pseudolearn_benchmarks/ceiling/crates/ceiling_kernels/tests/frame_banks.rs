use ceiling_kernels::frame_banks::FrameBanks;
use ceiling_kernels::machine::{Handle, Trap};

#[test]
fn returns_restore_suspended_arguments() -> Result<(), Trap> {
    let mut banks = FrameBanks::default();
    banks.enter(&[42], &[Handle(7)])?;
    banks.enter(&[9], &[Handle(3)])?;
    banks.leave();
    assert_eq!(banks.word(0), 42);
    assert_eq!(banks.handle(0), Handle(7));
    banks.reset();
    let mut outcome = Ok(());
    for _ in 0..20000 {
        outcome = banks.enter(&[], &[]);
        if outcome.is_err() {
            break;
        }
    }
    assert_eq!(outcome, Err(Trap::DepthLimit));
    Ok(())
}
