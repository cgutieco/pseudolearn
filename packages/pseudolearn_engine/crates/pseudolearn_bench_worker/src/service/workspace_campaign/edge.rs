use crate::service::project_campaign::datasets::{Dataset, SourceFile, package_wire};

fn file(path: &str, text: &str) -> SourceFile {
    SourceFile {
        path: path.to_owned(),
        text: text.to_owned(),
        profile: None,
    }
}

fn two_package(name: &str, main: &str, library: &str, module: &str) -> Dataset {
    Dataset {
        name: name.to_owned(),
        packages: vec![
            package_wire("app", "application", &["app/main"], &["lib"]),
            package_wire("lib", "library", &[], &[]),
        ],
        files: vec![
            file("app/main", main),
            file(&format!("lib/{module}"), library),
        ],
        entry: "app/main".to_owned(),
        expected_output: String::new(),
    }
}

pub fn empty_project() -> Dataset {
    Dataset {
        name: "empty-project".to_owned(),
        packages: Vec::new(),
        files: Vec::new(),
        entry: String::new(),
        expected_output: String::new(),
    }
}

pub fn short_names() -> Dataset {
    two_package(
        "short-names",
        "Importar lib.a.F;\nAlgoritmo P\nEscribir F(1);\nFinAlgoritmo\n",
        "Publico SubProceso F(n Como Entero) Como Entero\nRetornar n;\nFinSubProceso\n",
        "a",
    )
}

pub fn unicode_source() -> Dataset {
    two_package(
        "unicode-source",
        "Importar lib.u.Año;\nAlgoritmo P\nEscribir \"😀\";\nEscribir Año(1);\nFinAlgoritmo\n",
        "Publico SubProceso Año(n Como Entero) Como Entero\nRetornar n;\nFinSubProceso\n",
        "u",
    )
}
