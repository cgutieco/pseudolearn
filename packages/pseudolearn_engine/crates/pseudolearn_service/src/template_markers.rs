use pseudolearn_lexicon::Profile;

pub struct Markers {
    pub expression: &'static str,
    pub value: &'static str,
    pub condition: &'static str,
    pub index: &'static str,
    pub limit: &'static str,
    pub name: &'static str,
    pub parameter: &'static str,
    pub class_name: &'static str,
    pub field: &'static str,
}

pub fn markers(profile: Profile) -> Markers {
    match profile {
        Profile::Spanish => Markers {
            expression: "expresion",
            value: "valor",
            condition: "condicion",
            index: "indice",
            limit: "limite",
            name: "nombre",
            parameter: "parametro",
            class_name: "Nombre",
            field: "campo",
        },
        Profile::English => Markers {
            expression: "expression",
            value: "value",
            condition: "condition",
            index: "index",
            limit: "limit",
            name: "name",
            parameter: "parameter",
            class_name: "Name",
            field: "field",
        },
    }
}
