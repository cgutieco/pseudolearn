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
        let numeric = match arguments
            .first()
            .map(|argument| self.view.expression_type(*argument))
        {
            Some(Type::Integer) => "i64",
            _ => "f64",
        };
        if let Some(text) = self.numeric_builtin(function, (&first, &second), numeric) {
            return text;
        }
        match function {
            BuiltinKind::Round => self.helper_call("round_half_away", &first),
            BuiltinKind::Truncate => self.helper_call("truncate", &first),
            BuiltinKind::Random => self.helper_call("random", &first),
            BuiltinKind::RandomBetween => {
                self.require("random");
                format!("random_between({first}, {second})")
            }
            BuiltinKind::RandomUnit => {
                self.require("random");
                "random_unit()".to_owned()
            }
            other => self.text_builtin(other, (first, second, third), (arguments, span)),
        }
    }

    fn numeric_builtin(
        &mut self,
        function: BuiltinKind,
        (first, second): (&str, &str),
        numeric: &str,
    ) -> Option<String> {
        let real = |method: &str| numeric_method((first, numeric), method, "");
        Some(match function {
            BuiltinKind::AbsoluteValue => real("abs"),
            BuiltinKind::ArcCosine => self.finite(real("acos")),
            BuiltinKind::ArcSine => self.finite(real("asin")),
            BuiltinKind::ArcTangent => real("atan"),
            BuiltinKind::ArcTangent2 => numeric_method((first, numeric), "atan2", second),
            BuiltinKind::Cosine => real("cos"),
            BuiltinKind::Sine => real("sin"),
            BuiltinKind::Tangent => self.finite(real("tan")),
            BuiltinKind::Exponential => self.finite(real("exp")),
            BuiltinKind::NaturalLogarithm => self.finite(real("ln")),
            BuiltinKind::Logarithm10 => self.finite(real("log10")),
            BuiltinKind::Logarithm2 => self.finite(real("log2")),
            BuiltinKind::SquareRoot => self.finite(real("sqrt")),
            BuiltinKind::Ceiling => self.helper_call("truncate", &real("ceil")),
            BuiltinKind::Floor => self.helper_call("truncate", &real("floor")),
            BuiltinKind::Maximum if numeric == "f64" => {
                self.helper_call("real_maximum", &format!("{first}, {second}"))
            }
            BuiltinKind::Minimum if numeric == "f64" => {
                self.helper_call("real_minimum", &format!("{first}, {second}"))
            }
            BuiltinKind::Maximum => numeric_method((first, numeric), "max", second),
            BuiltinKind::Minimum => numeric_method((first, numeric), "min", second),
            _ => return None,
        })
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

fn numeric_method((receiver, numeric): (&str, &str), method: &str, rest: &str) -> String {
    let literal = receiver.starts_with(|character: char| {
        character.is_ascii_digit() || character == '(' || character == '-'
    });
    if !literal {
        return format!("{receiver}.{method}({rest})");
    }
    let inner = unwrapped(receiver);
    if rest.is_empty() {
        format!("{numeric}::{method}({inner})")
    } else {
        format!("{numeric}::{method}({inner}, {rest})")
    }
}

fn unwrapped(text: &str) -> &str {
    let Some(inner) = text
        .strip_prefix('(')
        .and_then(|rest| rest.strip_suffix(')'))
    else {
        return text;
    };
    let mut depth = 0_i32;
    for character in inner.chars() {
        depth = depth.saturating_add(match character {
            '(' => 1,
            ')' => -1,
            _ => 0,
        });
        if depth < 0 {
            return text;
        }
    }
    inner
}
