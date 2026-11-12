#![cfg(feature = "native")]

#[path = "native_access/absent.rs"]
mod absent;
#[path = "native_access/support.rs"]
mod support;

#[test]
fn each_terminal_array_failure_matches_vm_diagnostics() -> Result<(), String> {
    for kind in ["Entero", "Real", "Logico", "Caracter", "Cadena"] {
        support::compare(&format!(
            "Algoritmo P\nDimension values[2] Como {kind};\nEscribir values[1];\nFinAlgoritmo\n"
        ))?;
    }
    for index in [-1, 0, 2] {
        let length = if index == 0 { 0 } else { 2 };
        support::compare(&format!(
            "Algoritmo P\nDimension values[{length}] Como Entero;\nEscribir values[{index}];\nFinAlgoritmo\n"
        ))?;
        support::compare(&format!(
            "Algoritmo P\nDimension values[{length}] Como Entero;\nvalues[{index}] <- 42;\nFinAlgoritmo\n"
        ))?;
    }
    Ok(())
}

#[test]
fn each_terminal_field_failure_matches_vm_diagnostics() -> Result<(), String> {
    for kind in ["Entero", "Real", "Logico", "Caracter", "Cadena", "Node"] {
        let prefix = format!(
            "Clase Node\nPublico Definir value Como {kind};\nFinClase\nAlgoritmo P\nDefinir node Como Node <- Nuevo Node();\n"
        );
        let read = if kind == "Node" {
            "Definir target Como Node <- node.value;"
        } else {
            "Escribir node.value;"
        };
        support::compare(&format!("{prefix}{read}\nFinAlgoritmo\n"))?;
    }
    Ok(())
}

#[test]
fn partial_definition_and_managed_cells_remain_successful_under_forced_collection()
-> Result<(), String> {
    support::compare(
        "SubProceso Change(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nDimension values[130] Como Entero;\nvalues[65] <- 41;\nChange(values[65]);\nEscribir values[65];\nFinAlgoritmo\n",
    )?;
    support::compare(
        "Clase Node\nPublico Definir value Como Entero;\nFinClase\nSubProceso Change(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nDefinir node Como Node <- Nuevo Node();\nnode.value <- 41;\nChange(node.value);\nEscribir node.value;\nFinAlgoritmo\n",
    )
}

#[test]
fn array_parameters_preserve_aliasing_and_roots_through_recursive_allocations() -> Result<(), String>
{
    support::compare(
        "SubProceso Change(left[] Como Entero, right[] Como Entero, depth Como Entero)\nDimension garbage[2] Como Entero;\nSi depth > 0 Entonces\nChange(left,right,depth - 1);\nFinSi\nleft[0] <- left[0] + 1;\nright[0] <- right[0] + 1;\nFinSubProceso\nAlgoritmo P\nDimension values[1] Como Entero;\nvalues[0] <- 0;\nChange(values,values,5);\nEscribir values[0];\nFinAlgoritmo\n",
    )
}
