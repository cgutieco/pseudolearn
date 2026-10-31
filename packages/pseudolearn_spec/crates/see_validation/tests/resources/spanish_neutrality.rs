use see_validation::resources::spanish_neutrality::check;

#[test]
fn accepts_standard_spanish_without_voseo_or_regionalisms() {
    let phrases = [
        "El vínculo necesita un inicializador; añade <- expresión",
        "El vínculo es inmutable; usa Definir Mutable para reasignarlo",
        "Resultado de tipo Entero sin tratar: manéjalo con Segun, propágalo o descártalo",
        "Falta una rama: cubre las alternativas indicadas o añade De Otro Modo",
        "El documento cambió; repite la consulta",
        "Aquí está también el valor además de otros parámetros",
    ];
    for phrase in phrases {
        assert!(check(phrase).is_ok(), "{phrase}");
    }
}

#[test]
fn rejects_voseo_and_regional_expressions() {
    let violations = [
        ("El vínculo es inmutable; usá Definir Mutable", "usá"),
        ("El vínculo necesita un inicializador; añadí <- expresión", "añadí"),
        ("Falta una rama: cubrí las alternativas", "cubrí"),
        ("Resultado sin tratar: manejalo con Segun", "manejalo"),
        ("Resultado sin tratar: propagalo o descartalo", "propagalo"),
        ("Elegí otro nombre", "elegí"),
        ("El documento cambió; repetí la consulta", "repetí"),
        ("Mirá acá el resultado", "acá"),
    ];
    for (phrase, expected_token) in violations {
        let failure = check(phrase);
        assert!(failure.is_err(), "{phrase}");
        assert!(
            failure
                .err()
                .is_some_and(|message| message.contains(expected_token)),
            "{phrase}"
        );
    }
}
