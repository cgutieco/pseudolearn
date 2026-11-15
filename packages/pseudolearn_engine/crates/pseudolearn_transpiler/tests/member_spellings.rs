#[path = "support/translation.rs"]
mod support;

use pseudolearn_transpiler::TargetLanguage;
use support::code;

const TWIN_FIELDS: &str = "Clase Par\nDefinir fooBar Como Entero;\nDefinir foo_bar Como Entero;\nFinClase\nAlgoritmo P\nDefinir p Como Par <- Nuevo Par();\np.fooBar <- 1;\np.foo_bar <- 2;\nEscribir p.fooBar, p.foo_bar;\nFinAlgoritmo\n";

#[test]
fn fields_with_the_same_spelling_stay_distinct() -> Result<(), String> {
    let rust = code(TWIN_FIELDS, TargetLanguage::Rust)?;
    assert!(rust.contains("foo_bar: i64,") && rust.contains("foo_bar_2: i64,"));
    assert!(rust.contains(".foo_bar = 1") && rust.contains(".foo_bar_2 = 2"));
    let python = code(TWIN_FIELDS, TargetLanguage::Python)?;
    assert!(python.contains("self.foo_bar = ") && python.contains("self.foo_bar_2 = "));
    assert!(python.contains("p.foo_bar = 1") && python.contains("p.foo_bar_2 = 2"));
    Ok(())
}

#[test]
fn an_inherited_field_and_a_new_field_with_the_same_spelling_stay_distinct() -> Result<(), String> {
    let program = "Clase Base\nDefinir fooBar Como Entero;\nFinClase\nClase Hija Hereda De Base\nDefinir foo_bar Como Entero;\nFinClase\nAlgoritmo P\nDefinir h Como Hija <- Nuevo Hija();\nh.fooBar <- 1;\nh.foo_bar <- 2;\nEscribir h.fooBar, h.foo_bar;\nFinAlgoritmo\n";
    let python = code(program, TargetLanguage::Python)?;
    assert!(python.contains("h.foo_bar = 1") && python.contains("h.foo_bar_2 = 2"));
    let rust = code(program, TargetLanguage::Rust)?;
    assert!(rust.contains("foo_bar: i64,") && rust.contains("foo_bar_2: i64,"));
    Ok(())
}

#[test]
fn classes_with_the_same_spelling_stay_distinct() -> Result<(), String> {
    let program = "Clase MiItem\nDefinir v Como Entero;\nFinClase\nClase Mi_Item\nDefinir w Como Entero;\nFinClase\nAlgoritmo P\nDefinir a Como MiItem <- Nuevo MiItem();\nDefinir b Como Mi_Item <- Nuevo Mi_Item();\nEscribir a.v, b.w;\nFinAlgoritmo\n";
    let rust = code(program, TargetLanguage::Rust)?;
    assert!(rust.contains("struct MiItem {") && rust.contains("struct MiItem2 {"));
    let python = code(program, TargetLanguage::Python)?;
    assert!(python.contains("class MiItem:") && python.contains("class MiItem2:"));
    Ok(())
}

#[test]
fn a_class_spelled_like_a_record_yields_the_name() -> Result<(), String> {
    let program = "Registro Punto\nDefinir x Como Entero;\nFinRegistro\nClase punto\nDefinir w Como Entero;\nFinClase\nAlgoritmo P\nDefinir c Como punto <- Nuevo punto();\nEscribir c.w;\nFinAlgoritmo\n";
    let rust = code(program, TargetLanguage::Rust)?;
    assert!(rust.contains("struct Punto2 {"), "{rust}");
    let python = code(program, TargetLanguage::Python)?;
    assert!(python.contains("class Punto2:"), "{python}");
    Ok(())
}

#[test]
fn a_function_spelled_like_a_suffixed_local_is_renamed() -> Result<(), String> {
    let program = "Funcion r <- total_2(x Como Entero)\nDefinir r Como Entero;\nr <- x + 100;\nFinFuncion\nAlgoritmo P\nDefinir total Como Entero <- 1;\nDefinir Total Como Entero <- 2;\nEscribir total, Total, total_2(3);\nFinAlgoritmo\n";
    for target in [TargetLanguage::Rust, TargetLanguage::Python] {
        let text = code(program, target)?;
        assert!(text.contains("total_2_routine(3)"), "{text}");
    }
    Ok(())
}

#[test]
fn unique_names_keep_their_plain_spelling() -> Result<(), String> {
    let program = "Clase Caja\nDefinir v Como Entero;\nFinClase\nFuncion r <- doble(x Como Entero)\nDefinir r Como Entero;\nr <- x * 2;\nFinFuncion\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nc.v <- doble(2);\nEscribir c.v;\nFinAlgoritmo\n";
    let rust = code(program, TargetLanguage::Rust)?;
    assert!(rust.contains("struct Caja {") && rust.contains("v: i64,"));
    assert!(rust.contains("doble(2)") && !rust.contains("_routine") && !rust.contains("Caja2"));
    let python = code(program, TargetLanguage::Python)?;
    assert!(python.contains("class Caja:") && python.contains("self.v = "));
    Ok(())
}
