const FORBIDDEN_WORDS: [&str; 46] = [
    "acá",
    "agregá",
    "ahorita",
    "avisá",
    "añadí",
    "añadid",
    "bacán",
    "buscá",
    "cambiá",
    "cambialo",
    "che",
    "chévere",
    "corregí",
    "cubrí",
    "dale",
    "declará",
    "definí",
    "dejá",
    "dejalo",
    "descartalo",
    "elegí",
    "escribí",
    "escribilo",
    "fijate",
    "guardá",
    "habéis",
    "hacé",
    "manejalo",
    "mostrá",
    "podés",
    "poné",
    "ponelo",
    "propagalo",
    "querés",
    "quitá",
    "repetí",
    "revisá",
    "sos",
    "tené",
    "tenés",
    "tomá",
    "usá",
    "usad",
    "vos",
    "vosotras",
    "vosotros",
];

pub fn check(text: &str) -> Result<(), String> {
    for segment in text.split(|character: char| !character.is_alphabetic()) {
        if segment.is_empty() {
            continue;
        }
        let normalized = segment.to_lowercase();
        if FORBIDDEN_WORDS.contains(&normalized.as_str()) {
            return Err(format!(
                "SEE-SPANISH-NEUTRALITY: forbidden regional word '{normalized}'"
            ));
        }
    }
    Ok(())
}
