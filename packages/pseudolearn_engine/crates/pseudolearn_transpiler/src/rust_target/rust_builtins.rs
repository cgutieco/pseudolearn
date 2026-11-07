use super::RustEmitter;
use pseudolearn_semantic::{BuiltinKind, ExpressionId, Type};
use pseudolearn_source::Span;

impl RustEmitter<'_, '_> {
    pub(crate) fn builtin(
        &mut self,
        function: BuiltinKind,
        arguments: &[ExpressionId],
        span: Span,
    ) -> String {
        let texts = self.argument_texts(arguments);
        let first = texts.first().cloned().unwrap_or_default();
        let second = texts.get(1).cloned().unwrap_or_default();
        let third = texts.get(2).cloned().unwrap_or_default();
        match function {
            BuiltinKind::AbsoluteValue => format!("{first}.abs()"),
            BuiltinKind::ArcCosine => self.finite(format!("{first}.acos()")),
            BuiltinKind::ArcSine => self.finite(format!("{first}.asin()")),
            BuiltinKind::ArcTangent => format!("{first}.atan()"),
            BuiltinKind::ArcTangent2 => format!("{first}.atan2({second})"),
            BuiltinKind::Cosine => format!("{first}.cos()"),
            BuiltinKind::Sine => format!("{first}.sin()"),
            BuiltinKind::Tangent => self.finite(format!("{first}.tan()")),
            BuiltinKind::Exponential => self.finite(format!("{first}.exp()")),
            BuiltinKind::NaturalLogarithm => self.finite(format!("{first}.ln()")),
            BuiltinKind::Logarithm10 => self.finite(format!("{first}.log10()")),
            BuiltinKind::Logarithm2 => self.finite(format!("{first}.log2()")),
            BuiltinKind::SquareRoot => self.finite(format!("{first}.sqrt()")),
            BuiltinKind::Ceiling => self.helper_call("truncate", &format!("{first}.ceil()")),
            BuiltinKind::Floor => self.helper_call("truncate", &format!("{first}.floor()")),
            BuiltinKind::Round => self.helper_call("round_half_away", &first),
            BuiltinKind::Truncate => self.helper_call("truncate", &first),
            BuiltinKind::Maximum => format!("{first}.max({second})"),
            BuiltinKind::Minimum => format!("{first}.min({second})"),
            BuiltinKind::Random => self.helper_call("random", &first),
            BuiltinKind::RandomBetween => {
                self.helper_call("random_between", &format!("{first}, {second}"))
            }
            BuiltinKind::RandomUnit => self.helper_call("random_unit", ""),
            other => self.text_builtin(other, (first, second, third), (arguments, span)),
        }
    }

    pub(crate) fn text_builtin(
        &mut self,
        function: BuiltinKind,
        (first, second, third): (String, String, String),
        (arguments, span): (&[ExpressionId], Span),
    ) -> String {
        match function {
            BuiltinKind::Length => format!("{first}.chars().count() as i64"),
            BuiltinKind::CharacterAt => {
                self.helper_call("character_at", &format!("&{first}, {second}"))
            }
            BuiltinKind::CharacterCode => format!("{first} as i64"),
            BuiltinKind::CharacterFromCode => self.helper_call("character_from_code", &first),
            BuiltinKind::Concatenate => format!("format!(\"{{}}{{}}\", {first}, {second})"),
            BuiltinKind::Contains => format!(
                "{first}.contains({})",
                self.pattern(arguments.get(1), &second)
            ),
            BuiltinKind::StartsWith => format!(
                "{first}.starts_with({})",
                self.pattern(arguments.get(1), &second)
            ),
            BuiltinKind::EndsWith => format!(
                "{first}.ends_with({})",
                self.pattern(arguments.get(1), &second)
            ),
            BuiltinKind::PositionOf => {
                self.helper_call("text_position", &format!("&{first}, &{second}"))
            }
            _ => self.text_builtin_rest(function, (first, second, third), (arguments, span)),
        }
    }

    pub(crate) fn text_builtin_rest(
        &mut self,
        function: BuiltinKind,
        (first, second, third): (String, String, String),
        (arguments, span): (&[ExpressionId], Span),
    ) -> String {
        match function {
            BuiltinKind::Substring => {
                self.helper_call("substring", &format!("&{first}, {second}, {third}"))
            }
            BuiltinKind::ReplaceAll => {
                self.helper_call("replace_all", &format!("&{first}, &{second}, &{third}"))
            }
            BuiltinKind::Split => self.helper_call("split_text", &format!("&{first}, &{second}")),
            BuiltinKind::Join => format!("{first}.borrow().join({second}.as_str())"),
            BuiltinKind::Trim => {
                format!("{first}.trim_matches([' ', '\\t', '\\n', '\\r']).to_string()")
            }
            BuiltinKind::TextToInteger => self.helper_call("text_to_integer", &format!("&{first}")),
            BuiltinKind::TextToReal => self.helper_call("text_to_real", &format!("&{first}")),
            BuiltinKind::ToText => self.text_conversion(arguments.first().copied(), &first),
            BuiltinKind::Snapshot => self.helper_call("snapshot", &format!("&{first}")),
            BuiltinKind::ShallowCopy => self.shallow_copy(arguments.first().copied(), &first, span),
            _ => self.block(&format!("builtin:{}", function.as_str()), span),
        }
    }

    pub(crate) fn argument_texts(&mut self, arguments: &[ExpressionId]) -> Vec<String> {
        arguments
            .iter()
            .map(|argument| self.operand(*argument, 10))
            .collect()
    }

    pub(crate) fn pattern(&self, argument: Option<&ExpressionId>, text: &str) -> String {
        match argument.map(|argument| self.view.expression_type(*argument)) {
            Some(Type::Character) => text.to_owned(),
            _ => format!("{text}.as_str()"),
        }
    }

    pub(crate) fn finite(&mut self, text: String) -> String {
        self.helper_call("finite", &text)
    }

    pub(crate) fn helper_call(&mut self, name: &'static str, arguments: &str) -> String {
        self.require(name);
        format!("{name}({arguments})")
    }

    pub(crate) fn text_conversion(&mut self, argument: Option<ExpressionId>, text: &str) -> String {
        match argument.map(|argument| self.view.expression_type(argument)) {
            Some(Type::Real) => self.helper_call("real_text", text),
            Some(Type::Boolean) => {
                format!("{}.to_string()", self.helper_call("boolean_text", text))
            }
            _ => format!("{text}.to_string()"),
        }
    }

    pub(crate) fn shallow_copy(
        &mut self,
        argument: Option<ExpressionId>,
        text: &str,
        span: Span,
    ) -> String {
        match argument.map(|argument| self.view.expression_type(argument)) {
            Some(Type::Object(class)) if !self.is_polymorphic(class) => {
                self.uses.insert("rc");
                format!("Rc::new(RefCell::new({text}.borrow().clone()))")
            }
            _ => self.block("builtin:shallowCopy", span),
        }
    }
}
