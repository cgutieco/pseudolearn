#[derive(Clone, Copy)]
pub struct BooleanLexemes<'text> {
    pub truth: &'text str,
    pub falsity: &'text str,
}

#[derive(Clone, Copy)]
pub enum PrimitiveValue<'text> {
    Integer(i64),
    Real(f64),
    Boolean(bool),
    Character(char),
    Text(&'text str),
}

pub fn format_value(value: PrimitiveValue<'_>, lexemes: BooleanLexemes<'_>) -> String {
    match value {
        PrimitiveValue::Integer(value) => value.to_string(),
        PrimitiveValue::Real(value) => {
            let mut text = value.to_string();
            if !text.contains('.') {
                text.push_str(".0");
            }
            text
        }
        PrimitiveValue::Boolean(value) => if value {
            lexemes.truth
        } else {
            lexemes.falsity
        }
        .to_owned(),
        PrimitiveValue::Character(value) => value.to_string(),
        PrimitiveValue::Text(value) => value.to_owned(),
    }
}
