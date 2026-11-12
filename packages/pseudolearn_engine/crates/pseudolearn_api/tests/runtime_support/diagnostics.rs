use serde_json::Value;

pub(super) fn verify(expected: &Value, trap: &pseudolearn_vm::VmTrap) -> Result<(), String> {
    let code = pseudolearn_diagnostics::DiagnosticCode::from_name(trap.code)
        .ok_or("Unknown runtime diagnostic")?;
    if code.argument_specs().len() != trap.arguments.len()
        || code.argument_specs().iter().any(|(name, kind)| {
            trap.arguments
                .get(name)
                .is_none_or(|argument| !kind.accepts(argument.kind()))
        })
    {
        return Err(format!("Invalid typed diagnostic arguments: {trap:?}"));
    }
    for diagnostic in expected
        .get("diagnosticos")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
    {
        if let Some(span) = diagnostic.get("tramo") {
            let actual = trap.span.ok_or("Missing trap span")?;
            let values = [
                actual.start_line,
                actual.start_column,
                actual.end_line,
                actual.end_column,
            ];
            for (value, path) in
                values
                    .into_iter()
                    .zip(["/start/line", "/start/column", "/end/line", "/end/column"])
            {
                if span.pointer(path).and_then(Value::as_u64) != Some(u64::from(value)) {
                    return Err(format!("Wrong trap span: {trap:?}, expected {span}"));
                }
            }
        }
        for (name, value) in diagnostic
            .get("argumentos")
            .and_then(Value::as_object)
            .into_iter()
            .flatten()
        {
            if trap
                .arguments
                .get(name.as_str())
                .is_none_or(|argument| argument.wire() != *value)
            {
                return Err(format!("Wrong diagnostic argument {name}: {trap:?}"));
            }
        }
    }
    Ok(())
}
