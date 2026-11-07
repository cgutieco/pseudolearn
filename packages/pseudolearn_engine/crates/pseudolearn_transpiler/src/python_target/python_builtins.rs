use super::PythonEmitter;
use pseudolearn_semantic::{BuiltinKind, ExpressionId, Type};
use pseudolearn_source::Span;

impl PythonEmitter<'_, '_> {
    pub(crate) fn builtin(
        &mut self,
        function: BuiltinKind,
        arguments: &[ExpressionId],
        span: Span,
    ) -> String {
        let texts = arguments
            .iter()
            .map(|argument| self.expression(*argument))
            .collect::<Vec<_>>();
        let first = texts.first().cloned().unwrap_or_default();
        let joined = texts.join(", ");
        let math = |name: &str| format!("math.{name}({joined})");
        match function {
            BuiltinKind::AbsoluteValue => format!("abs({first})"),
            BuiltinKind::ArcCosine => self.checked(&math("acos")),
            BuiltinKind::ArcSine => self.checked(&math("asin")),
            BuiltinKind::ArcTangent => self.checked(&math("atan")),
            BuiltinKind::ArcTangent2 => self.checked(&math("atan2")),
            BuiltinKind::Cosine => self.checked(&math("cos")),
            BuiltinKind::Sine => self.checked(&math("sin")),
            BuiltinKind::Tangent => self.checked(&math("tan")),
            BuiltinKind::Exponential => self.checked(&math("exp")),
            BuiltinKind::NaturalLogarithm => self.checked(&math("log")),
            BuiltinKind::Logarithm10 => self.checked(&math("log10")),
            BuiltinKind::Logarithm2 => self.checked(&math("log2")),
            BuiltinKind::SquareRoot => self.checked(&math("sqrt")),
            BuiltinKind::Ceiling => self.call_helper("ceiling", &joined),
            BuiltinKind::Floor => self.call_helper("floor", &joined),
            BuiltinKind::Round => self.call_helper("round_half_away", &joined),
            BuiltinKind::Truncate => self.call_helper("truncate", &joined),
            BuiltinKind::Maximum => format!("max({joined})"),
            BuiltinKind::Minimum => format!("min({joined})"),
            BuiltinKind::Random => self.call_helper("random", &joined),
            BuiltinKind::RandomBetween => self.call_helper("random_between", &joined),
            BuiltinKind::RandomUnit => self.call_helper("random_unit", ""),
            other => self.text_builtin(other, &texts, (arguments, span)),
        }
    }

    pub(crate) fn text_builtin(
        &mut self,
        function: BuiltinKind,
        texts: &[String],
        (arguments, span): (&[ExpressionId], Span),
    ) -> String {
        let first = texts.first().cloned().unwrap_or_default();
        let joined = texts.join(", ");
        match function {
            BuiltinKind::Length => format!("len({first})"),
            BuiltinKind::CharacterAt => self.call_helper("character_at", &joined),
            BuiltinKind::CharacterCode => format!("ord({first})"),
            BuiltinKind::CharacterFromCode => self.call_helper("character_from_code", &joined),
            BuiltinKind::Concatenate => texts.join(" + "),
            BuiltinKind::Contains => {
                format!("{} in {first}", texts.get(1).cloned().unwrap_or_default())
            }
            BuiltinKind::StartsWith => format!(
                "{first}.startswith({})",
                texts.get(1).cloned().unwrap_or_default()
            ),
            BuiltinKind::EndsWith => format!(
                "{first}.endswith({})",
                texts.get(1).cloned().unwrap_or_default()
            ),
            BuiltinKind::PositionOf => self.call_helper("text_position", &joined),
            _ => self.text_builtin_rest(function, texts, (arguments, span)),
        }
    }

    pub(crate) fn text_builtin_rest(
        &mut self,
        function: BuiltinKind,
        texts: &[String],
        (arguments, span): (&[ExpressionId], Span),
    ) -> String {
        let first = texts.first().cloned().unwrap_or_default();
        let joined = texts.join(", ");
        match function {
            BuiltinKind::Substring => self.call_helper("substring", &joined),
            BuiltinKind::ReplaceAll => self.call_helper("replace_all", &joined),
            BuiltinKind::Split => self.call_helper("split_text", &joined),
            BuiltinKind::Join => format!(
                "{}.join({first})",
                texts.get(1).cloned().unwrap_or_default()
            ),
            BuiltinKind::Trim => format!("{first}.strip(\" \\t\\n\\r\")"),
            BuiltinKind::TextToInteger => self.call_helper("text_to_integer", &joined),
            BuiltinKind::TextToReal => self.call_helper("text_to_real", &joined),
            BuiltinKind::ToText => self.text_conversion(arguments.first().copied(), &first),
            BuiltinKind::ShallowCopy => {
                self.require("copy");
                format!("copy.copy({first})")
            }
            BuiltinKind::Snapshot => {
                self.require("copy");
                format!("copy.deepcopy({first})")
            }
            _ => self.block(&format!("builtin:{}", function.as_str()), span),
        }
    }

    pub(crate) fn checked(&mut self, call: &str) -> String {
        self.require("math");
        self.call_helper("finite", call)
    }

    pub(crate) fn call_helper(&mut self, name: &'static str, arguments: &str) -> String {
        self.require(name);
        format!("{name}({arguments})")
    }

    pub(crate) fn text_conversion(&mut self, argument: Option<ExpressionId>, text: &str) -> String {
        match argument.map(|argument| self.view.expression_type(argument)) {
            Some(Type::Real) => self.call_helper("real_text", text),
            Some(Type::Boolean) => self.call_helper("boolean_text", text),
            _ => format!("str({text})"),
        }
    }
}
