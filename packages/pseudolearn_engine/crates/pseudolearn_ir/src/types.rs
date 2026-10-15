#![forbid(unsafe_code)]

#[derive(Clone, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum IrType {
    I64,
    F64,
    Bool,
    Char,
    Str,
    Unit,
    Array {
        element: Box<IrType>,
        dimension_rank: u32,
    },
    Object(String),
    Cell(Box<IrType>),
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ValueClass {
    Scalar,
    Reference,
    Unit,
}

impl IrType {
    pub fn value_class(&self) -> ValueClass {
        match self {
            Self::I64 | Self::F64 | Self::Bool | Self::Char => ValueClass::Scalar,
            Self::Str | Self::Array { .. } | Self::Object(_) | Self::Cell(_) => {
                ValueClass::Reference
            }
            Self::Unit => ValueClass::Unit,
        }
    }

    pub fn format_type(&self) -> String {
        match self {
            Self::I64 => "i64".to_owned(),
            Self::F64 => "f64".to_owned(),
            Self::Bool => "bool".to_owned(),
            Self::Char => "char".to_owned(),
            Self::Str => "str".to_owned(),
            Self::Unit => "unit".to_owned(),
            Self::Array {
                element,
                dimension_rank,
            } => {
                format!("array<{}, {}>", element.format_type(), dimension_rank)
            }
            Self::Object(class_name) => format!("obj<{class_name}>"),
            Self::Cell(inner_type) => format!("cell<{}>", inner_type.format_type()),
        }
    }

    pub fn parse_type(input: &str) -> Option<Self> {
        let trimmed = input.trim();
        match trimmed {
            "i64" => Some(Self::I64),
            "f64" => Some(Self::F64),
            "bool" => Some(Self::Bool),
            "char" => Some(Self::Char),
            "str" => Some(Self::Str),
            "unit" => Some(Self::Unit),
            _ => parse_complex_type(trimmed),
        }
    }
}

impl std::fmt::Display for IrType {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(formatter, "{}", self.format_type())
    }
}

fn parse_complex_type(input: &str) -> Option<IrType> {
    if let Some(rest) = input.strip_prefix("cell<")
        && let Some(inner) = rest.strip_suffix('>')
    {
        let parsed_inner = IrType::parse_type(inner)?;
        return Some(IrType::Cell(Box::new(parsed_inner)));
    }
    if let Some(rest) = input.strip_prefix("obj<")
        && let Some(class_name) = rest.strip_suffix('>')
    {
        return Some(IrType::Object(class_name.trim().to_owned()));
    }
    if let Some(rest) = input.strip_prefix("array<")
        && let Some(inner) = rest.strip_suffix('>')
        && let Some((element_str, rank_str)) = inner.rsplit_once(',')
    {
        let parsed_element = IrType::parse_type(element_str.trim())?;
        let parsed_rank = rank_str.trim().parse::<u32>().ok()?;
        return Some(IrType::Array {
            element: Box::new(parsed_element),
            dimension_rank: parsed_rank,
        });
    }
    None
}
