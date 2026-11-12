use crate::hir::{HirLocal, Passing};
use crate::identities::{FunctionId, TypeId};
use crate::local_indexes::LocalScopes;
use pseudolearn_source::Span;

fn local(scope: u32) -> HirLocal {
    HirLocal {
        name: "value".to_owned(),
        type_id: TypeId(0),
        passing: Passing::Value,
        span: Span::default(),
        scope: FunctionId(scope),
        parameter: false,
        reassignable: true,
    }
}

#[test]
fn lists_the_locals_of_one_scope_in_declaration_order() {
    let mut scopes = LocalScopes::default();
    let locals = vec![local(0), local(1), local(0)];
    assert_eq!(scopes.owned_by(&locals, FunctionId(0)), &[0, 2]);
    assert_eq!(scopes.owned_by(&locals, FunctionId(1)), &[1]);
    assert!(scopes.owned_by(&locals, FunctionId(7)).is_empty());
}

#[test]
fn indexes_locals_appended_after_a_previous_query() {
    let mut scopes = LocalScopes::default();
    let mut locals = vec![local(0)];
    assert_eq!(scopes.owned_by(&locals, FunctionId(0)), &[0]);
    locals.push(local(0));
    assert_eq!(scopes.owned_by(&locals, FunctionId(0)), &[0, 1]);
}

#[test]
fn forgets_truncated_locals_before_new_ones_reuse_their_indexes() {
    let mut scopes = LocalScopes::default();
    let mut locals = vec![local(0), local(1), local(1)];
    assert_eq!(scopes.owned_by(&locals, FunctionId(1)), &[1, 2]);
    locals.truncate(1);
    scopes.forget_from(1);
    locals.extend([local(2), local(2), local(2)]);
    assert!(scopes.owned_by(&locals, FunctionId(1)).is_empty());
    assert_eq!(scopes.owned_by(&locals, FunctionId(2)), &[1, 2, 3]);
}

#[test]
fn empty_tables_have_no_locals() {
    let mut scopes = LocalScopes::default();
    assert!(scopes.owned_by(&[], FunctionId(0)).is_empty());
    scopes.forget_from(0);
}
