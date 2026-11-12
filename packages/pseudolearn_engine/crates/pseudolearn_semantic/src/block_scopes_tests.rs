use crate::block_scopes::{BindingTarget, BlockScopes};
use crate::identities::LocalId;

#[test]
fn restores_shadowed_bindings_and_records_expired_names() {
    let mut scopes = BlockScopes::default();
    scopes.enter();
    scopes.insert("value".to_owned(), BindingTarget::Local(LocalId(0)));
    scopes.enter();
    assert_eq!(scopes.current("value"), None);
    scopes.insert("value".to_owned(), BindingTarget::Local(LocalId(1)));
    assert_eq!(scopes.find("value"), Some(BindingTarget::Local(LocalId(1))));
    assert_eq!(scopes.leave(), vec![BindingTarget::Local(LocalId(1))]);
    assert_eq!(scopes.find("value"), Some(BindingTarget::Local(LocalId(0))));
    scopes.leave();
    assert_eq!(scopes.find("value"), None);
    assert_eq!(
        scopes.expired("value"),
        Some(BindingTarget::Local(LocalId(0)))
    );
}

#[test]
fn handles_empty_and_deep_scopes_without_leaking_siblings() {
    let mut scopes = BlockScopes::default();
    assert!(scopes.leave().is_empty());
    for _ in 0..256 {
        scopes.enter();
    }
    scopes.insert("x".to_owned(), BindingTarget::Constant(0));
    assert_eq!(scopes.current("x"), Some(BindingTarget::Constant(0)));
    scopes.leave();
    scopes.enter();
    assert_eq!(scopes.find("x"), None);
    assert_eq!(scopes.expired("missing"), None);
    for _ in 0..256 {
        scopes.leave();
    }
    assert!(scopes.leave().is_empty());
}
