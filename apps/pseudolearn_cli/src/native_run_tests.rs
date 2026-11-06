use super::requested_exit;
use pseudolearn_api::NativeRunReport;

fn report(effects: Option<&[u8]>) -> NativeRunReport {
    NativeRunReport {
        effects: effects.map(<[u8]>::to_vec),
        ..NativeRunReport::default()
    }
}

#[test]
fn the_requested_code_is_read_from_the_effect_document() {
    assert_eq!(requested_exit(&report(Some(br#"{"exit_code":7}"#))), 7);
}

#[test]
fn a_document_without_a_code_requests_success() {
    assert_eq!(requested_exit(&report(Some(br#"{"host_calls":0}"#))), 0);
    assert_eq!(requested_exit(&report(None)), 0);
}

#[test]
fn an_unreadable_or_out_of_range_code_requests_success() {
    assert_eq!(requested_exit(&report(Some(b"not json"))), 0);
    assert_eq!(requested_exit(&report(Some(br#"{"exit_code":300}"#))), 0);
    assert_eq!(requested_exit(&report(Some(br#"{"exit_code":-1}"#))), 0);
}
