#[test]
fn payload_constant_requires_every_descendant_to_share_the_layout() -> Result<(), String> {
    let mut module = pseudolearn_ir::parse_module("module P es\nclass Base { first: i64 }\nclass Derived : Base { second: i64 }\nclass Leaf : Derived { third: i64 }\nclass Other { value: i64 }\n").map_err(|error| error.to_string())?;
    let uniform = super::ClassTable::build(&module).map_err(|error| error.to_string())?;
    assert_eq!(uniform.static_payload("Base"), Some(3));
    if let Some(leaf) = module.classes.iter_mut().find(|class| class.name == "Leaf") {
        leaf.dense_integers = true;
    }
    let mixed = super::ClassTable::build(&module).map_err(|error| error.to_string())?;
    assert_eq!(mixed.static_payload("Base"), None);
    assert_eq!(mixed.static_payload("Derived"), None);
    assert_eq!(mixed.static_payload("Leaf"), Some(2));
    assert_eq!(mixed.static_payload("Other"), Some(3));
    assert_eq!(mixed.static_payload("Missing"), None);
    Ok(())
}
