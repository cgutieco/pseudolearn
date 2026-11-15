use super::{decode_scalar_value, format_kind_type, format_value_type};
use crate::VariableValue;
use pseudolearn_bytecode::ValueType;
use pseudolearn_runtime::ValueKind;

#[test]
fn value_type_formatting_covers_scalar_reference_and_container_types() {
    let types = [
        (ValueType::I64, "Entero"),
        (ValueType::F64, "Real"),
        (ValueType::Bool, "Logico"),
        (ValueType::Char, "Caracter"),
        (ValueType::Str, "Texto"),
        (ValueType::Object("Robot".to_owned()), "Robot"),
        (
            ValueType::Array {
                element: Box::new(ValueType::I64),
                dimension_rank: 2,
            },
            "Arreglo",
        ),
        (ValueType::Cell(Box::new(ValueType::I64)), "Celda"),
        (ValueType::Unit, "Nulo"),
    ];
    for (value_type, expected) in types {
        assert_eq!(format_value_type(&value_type), expected);
    }
}

#[test]
fn value_kind_formatting_covers_each_runtime_kind() {
    let kinds = [
        (ValueKind::Integer, "Entero"),
        (ValueKind::Real, "Real"),
        (ValueKind::Boolean, "Logico"),
        (ValueKind::Character, "Caracter"),
        (ValueKind::Reference, "Referencia"),
    ];
    for (kind, expected) in kinds {
        assert_eq!(format_kind_type(kind), expected);
    }
}

#[test]
fn scalar_decoding_preserves_values_and_rejects_reference_types() {
    assert_eq!(
        decode_scalar_value(&ValueType::I64, u64::from_ne_bytes((-21_i64).to_ne_bytes())),
        VariableValue::Integer(-21)
    );
    assert_eq!(
        decode_scalar_value(&ValueType::F64, 1.75_f64.to_bits()),
        VariableValue::Real(1.75)
    );
    assert_eq!(
        decode_scalar_value(&ValueType::Bool, 1),
        VariableValue::Boolean(true)
    );
    assert_eq!(
        decode_scalar_value(&ValueType::Bool, 0),
        VariableValue::Boolean(false)
    );
    assert_eq!(
        decode_scalar_value(&ValueType::Char, u64::from(u32::from('ñ'))),
        VariableValue::Character('ñ')
    );
    assert_eq!(
        decode_scalar_value(&ValueType::Str, 1),
        VariableValue::Undefined
    );
    assert_eq!(
        decode_scalar_value(&ValueType::Char, u64::from(0x11_0000_u32)),
        VariableValue::Character('?')
    );
}
