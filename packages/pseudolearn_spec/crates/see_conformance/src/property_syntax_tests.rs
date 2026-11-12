use crate::property_syntax::propagates_errors;

#[test]
fn propagation_is_detected_in_any_profile_and_letter_case() {
    for program in [
        "Definir r Como Reloj <- Propagar SolicitarReloj();",
        "Define clock As Clock <- Propagate requestClock();",
        "define clock as clock <- propagate requestClock();",
        "DEFINIR R COMO RELOJ <- PROPAGAR SOLICITARRELOJ();",
    ] {
        assert!(propagates_errors(program), "{program}");
    }
}

#[test]
fn programs_without_propagation_are_kept() {
    for program in ["", "Escribir 1;", "Write \"propag\";"] {
        assert!(!propagates_errors(program), "{program}");
    }
}
