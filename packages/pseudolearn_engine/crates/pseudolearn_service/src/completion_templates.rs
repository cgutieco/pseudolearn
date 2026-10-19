use pseudolearn_lexicon::Profile;

pub fn get_template(construction: &str, profile: Profile) -> Option<String> {
    match profile {
        Profile::Spanish => spanish_template(construction),
        Profile::English => english_template(construction),
    }
}

pub fn bilingual_keyword_hint(
    word: &str,
    profile: Profile,
) -> Option<(&'static str, &'static str)> {
    let pairs = [
        ("mientras", "while", "Mientras", "while"),
        ("si", "if", "Si", "if"),
        ("para", "for", "Para", "for"),
        ("escribir", "print", "Escribir", "print"),
        ("leer", "read", "Leer", "read"),
        ("definir", "define", "Definir", "define"),
    ];
    let lower = word.to_lowercase();
    for &(es_key, en_key, es_label, en_label) in &pairs {
        if profile == Profile::Spanish && en_key.starts_with(&lower) {
            return Some((es_label, en_label));
        }
        if profile == Profile::English && es_key.starts_with(&lower) {
            return Some((en_label, es_label));
        }
    }
    None
}

fn spanish_template(construction: &str) -> Option<String> {
    match construction {
        "switch" | "segun" => Some(String::from(
            "Segun expresion Hacer\n  Caso valor:\n    \n  De Otro Modo:\n    \nFinSegun",
        )),
        "if" | "si" => Some(String::from("Si condicion Entonces\n  \nSino\n  \nFinSi")),
        "while" | "mientras" => Some(String::from("Mientras condicion Hacer\n  \nFinMientras")),
        "for" | "para" => Some(String::from(
            "Para variable <- 1 Hasta limite Con Paso 1 Hacer\n  \nFinPara",
        )),
        "repeat" | "repetir" => Some(String::from("Repetir\n  \nHasta Que condicion")),
        "function" | "funcion" => Some(String::from(
            "Funcion resultado <- Nombre(argumentos)\n  \nFinFuncion",
        )),
        "subroutine" | "subproceso" => Some(String::from(
            "SubProceso Nombre(argumentos)\n  \nFinSubProceso",
        )),
        "class" | "clase" => Some(String::from("Clase Nombre\n  \nFinClase")),
        "algorithm" | "algoritmo" => Some(String::from("Algoritmo Nombre\n  \nFinAlgoritmo")),
        _ => None,
    }
}

fn english_template(construction: &str) -> Option<String> {
    match construction {
        "switch" | "segun" => Some(String::from(
            "Switch expression Do\n  Case value:\n    \n  Otherwise:\n    \nEndSwitch",
        )),
        "if" | "si" => Some(String::from("If condition Then\n  \nElse\n  \nEndIf")),
        "while" | "mientras" => Some(String::from("While condition Do\n  \nEndWhile")),
        "for" | "para" => Some(String::from(
            "For variable <- 1 To limit Step 1 Do\n  \nEndFor",
        )),
        "repeat" | "repetir" => Some(String::from("Repeat\n  \nUntil condition")),
        "function" | "funcion" => Some(String::from(
            "Function result <- Name(arguments)\n  \nEndFunction",
        )),
        "subroutine" | "subproceso" => Some(String::from(
            "SubProcedure Name(arguments)\n  \nEndSubProcedure",
        )),
        "class" | "clase" => Some(String::from("Class Name\n  \nEndClass")),
        "algorithm" | "algoritmo" => Some(String::from("Algorithm Name\n  \nEndAlgorithm")),
        _ => None,
    }
}
