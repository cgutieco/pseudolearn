use crate::dap_variables::display_value;
use serde_json::json;

#[test]
fn channel_values_show_identity_queue_and_state() {
    let open = json!({"canal":{"identidad":3,"capacidad":2,"abierto":true,"en_cola":1}});
    let closed = json!({"canal":{"identidad":3,"capacidad":2,"abierto":false,"en_cola":0}});
    assert_eq!(display_value(&open, None), "canal(3) 1/2 abierto");
    assert_eq!(display_value(&closed, None), "canal(3) 0/2 cerrado");
}

#[test]
fn malformed_channel_values_fall_back_to_their_json() {
    let partial = json!({"canal":{"identidad":3}});
    assert_eq!(display_value(&partial, None), r#"{"identidad":3}"#);
}

#[test]
fn scalar_null_undefined_and_reference_values_keep_their_display() {
    assert_eq!(display_value(&json!({"valor":"7"}), None), "7");
    assert_eq!(display_value(&json!({"nulo":true}), None), "nulo");
    assert_eq!(display_value(&json!({"sin_valor":true}), None), "sin_valor");
    assert_eq!(display_value(&json!({"ref":9}), Some(9)), "referencia(9)");
    assert_eq!(display_value(&json!({}), None), "{}");
}
