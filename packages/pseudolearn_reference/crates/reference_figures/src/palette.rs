pub const SANS_FAMILY: &str = "IBMPlexSans";
pub const MONO_FAMILY: &str = "IBMPlexMono";

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ColorRole {
    Ink,
    Surface,
    StructuredAccent,
    ProceduralAccent,
    ObjectAccent,
    Number,
    Text,
    Logical,
    Success,
    Error,
    Muted,
    Slot,
    Type,
}

const ROLES: [(ColorRole, &str, &str); 13] = [
    (ColorRole::Ink, "tinta", "#FF0001"),
    (ColorRole::Surface, "superficie", "#FF0002"),
    (
        ColorRole::StructuredAccent,
        "acento-estructurado",
        "#FF0003",
    ),
    (
        ColorRole::ProceduralAccent,
        "acento-procedimental",
        "#FF0004",
    ),
    (ColorRole::ObjectAccent, "acento-objetos", "#FF0005"),
    (ColorRole::Number, "numero", "#FF0006"),
    (ColorRole::Text, "texto", "#FF0007"),
    (ColorRole::Logical, "logico", "#FF0008"),
    (ColorRole::Success, "exito", "#FF0009"),
    (ColorRole::Error, "error", "#FF000A"),
    (ColorRole::Muted, "atenuado", "#FF000B"),
    (ColorRole::Slot, "hueco", "#FF000C"),
    (ColorRole::Type, "tipo", "#FF000D"),
];

impl ColorRole {
    pub fn from_name(name: &str) -> Option<Self> {
        ROLES
            .iter()
            .find(|(_, role_name, _)| *role_name == name)
            .map(|(role, _, _)| *role)
    }

    pub fn sentinel(self) -> &'static str {
        ROLES
            .iter()
            .find(|(role, _, _)| *role == self)
            .map_or("#FF0001", |(_, _, sentinel)| sentinel)
    }

    pub fn name(self) -> &'static str {
        ROLES
            .iter()
            .find(|(role, _, _)| *role == self)
            .map_or("tinta", |(_, name, _)| name)
    }

    pub fn all() -> impl Iterator<Item = Self> {
        ROLES.iter().map(|(role, _, _)| *role)
    }
}

pub fn color_value(source: &str) -> Result<String, String> {
    if source == "none" {
        return Ok("none".to_owned());
    }
    source
        .strip_prefix('@')
        .and_then(ColorRole::from_name)
        .map(|role| role.sentinel().to_owned())
        .ok_or_else(|| format!("color `{source}` is not a role (use none or @role)"))
}

pub fn font_family(source: &str) -> Result<&'static str, String> {
    match source {
        "sans" => Ok(SANS_FAMILY),
        "mono" => Ok(MONO_FAMILY),
        other => Err(format!("font family `{other}` is not sans or mono")),
    }
}
