use crate::service::project_campaign::shapes::Shape;

pub struct ModuleSpec {
    pub index: usize,
    pub count: usize,
    pub shape: Shape,
    pub constant: u64,
    pub parameter: &'static str,
    pub padding: usize,
}

pub fn path_of(shape: Shape, index: usize) -> String {
    let package = shape.package_of(index);
    if index == 0 {
        "app/main".to_owned()
    } else {
        format!("{package}/m{index}")
    }
}

fn import_line(shape: Shape, callee: usize) -> String {
    let package = shape.package_of(callee);
    format!("Importar {package}.m{callee}.F{callee};\n")
}

pub fn entry_text(spec: &ModuleSpec) -> String {
    let callees = spec.shape.callees(0, spec.count);
    let mut text: String = callees
        .iter()
        .map(|callee| import_line(spec.shape, *callee))
        .collect();
    text.push_str("Algoritmo Principal\nDefinir Mutable total Como Entero <- 0;\n");
    for callee in &callees {
        text.push_str(&format!("total <- total + F{callee}(0);\n"));
    }
    text.push_str(&format!(
        "Escribir total + {};\nFinAlgoritmo\n",
        spec.constant
    ));
    text
}

pub fn library_text(spec: &ModuleSpec) -> String {
    let callees = spec.shape.callees(spec.index, spec.count);
    let mut text: String = callees
        .iter()
        .map(|callee| import_line(spec.shape, *callee))
        .collect();
    let (index, parameter) = (spec.index, spec.parameter);
    let base = callees.first().map_or(parameter.to_owned(), |callee| {
        format!("F{callee}({parameter})")
    });
    text.push_str(&format!(
        "Publico SubProceso F{index}({parameter} Como Entero) Como Entero\nRetornar {base} + {};\nFinSubProceso\n",
        spec.constant
    ));
    for step in 0..spec.padding {
        text.push_str(&format!(
            "Publico SubProceso G{index}_{step}({parameter} Como Entero) Como Entero\nRetornar {parameter} + {step};\nFinSubProceso\n"
        ));
    }
    text
}

pub fn module_text(spec: &ModuleSpec) -> String {
    if spec.index == 0 {
        entry_text(spec)
    } else {
        library_text(spec)
    }
}
