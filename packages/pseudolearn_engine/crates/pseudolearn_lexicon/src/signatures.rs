use crate::keywords::BuiltinKind;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct BuiltinSignature {
    pub parameter_types: &'static [&'static str],
    pub return_type: &'static str,
}

impl BuiltinSignature {
    pub const fn new(parameter_types: &'static [&'static str], return_type: &'static str) -> Self {
        Self {
            parameter_types,
            return_type,
        }
    }

    pub fn arity(&self) -> usize {
        self.parameter_types.len()
    }
}

pub fn signature_for_builtin(kind: BuiltinKind) -> BuiltinSignature {
    match kind {
        BuiltinKind::AbsoluteValue => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::ArcTangent => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::CharacterAt => BuiltinSignature::new(&["string", "integer"], "character"),
        BuiltinKind::CharacterCode => BuiltinSignature::new(&["character"], "integer"),
        BuiltinKind::CharacterFromCode => BuiltinSignature::new(&["integer"], "character"),
        BuiltinKind::Cosine => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::Exponential => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::Length => BuiltinSignature::new(&["string"], "integer"),
        BuiltinKind::NaturalLogarithm => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::Random => BuiltinSignature::new(&[], "real"),
        BuiltinKind::Round => BuiltinSignature::new(&["real"], "integer"),
        BuiltinKind::ShallowCopy => BuiltinSignature::new(&["anyClass"], "sameAsFirstArgument"),
        BuiltinKind::Sine => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::SquareRoot => BuiltinSignature::new(&["numeric"], "real"),
        BuiltinKind::TextToInteger => BuiltinSignature::new(&["string"], "integer"),
        BuiltinKind::TextToReal => BuiltinSignature::new(&["string"], "real"),
        BuiltinKind::ToText => BuiltinSignature::new(&["anyPrimitive"], "string"),
        BuiltinKind::Truncate => BuiltinSignature::new(&["real"], "integer"),
    }
}
