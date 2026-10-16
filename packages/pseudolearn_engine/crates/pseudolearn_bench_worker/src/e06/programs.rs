use pseudolearn_vm::{LoadedProgram, RunOptions, TwinMode, load};

pub struct CompiledCase {
    pub name: String,
    pub program: LoadedProgram,
    pub inputs: Vec<String>,
}

pub fn compile_case(name: &str, source: &str, inputs: Vec<String>) -> Result<CompiledCase, String> {
    let module = pseudolearn_api::compile_source_to_module(source, "es", "strict")
        .map_err(|diagnostics| format!("{name}: {diagnostics:?}"))?;
    let bytecode = pseudolearn_bytecode::compile_module(&module)
        .map_err(|error| format!("{name}: {error:?}"))?;
    let program = load(&bytecode).map_err(|trap| format!("{name}: {}", trap.code))?;
    Ok(CompiledCase {
        name: name.to_owned(),
        program,
        inputs,
    })
}

pub fn awfy_compiled() -> Result<Vec<CompiledCase>, String> {
    crate::corpus::awfy_cases()?
        .into_iter()
        .map(|case| compile_case(&case.name, &case.source, case.inputs))
        .collect()
}

pub fn options(mode: TwinMode, inputs: &[String]) -> RunOptions {
    RunOptions {
        twin_mode: mode,
        inputs: inputs.to_vec(),
        depth: 400_000,
        ..RunOptions::default()
    }
}

pub const DEPTH_SOURCE: &str = "SubProceso Descender(n Como Entero) Como Entero
Si n = 0 Entonces
Retornar 0;
FinSi
Retornar 1 + Descender(n - 1);
FinSubProceso
Algoritmo Profundidad
Definir n Como Entero;
Leer n;
Escribir Descender(n);
FinAlgoritmo
";

pub const LOOP_SOURCE: &str = "Algoritmo Ciclo
Dimension celdas[1024] Como Entero;
Definir i, vueltas Como Entero;
Leer vueltas;
Para i <- 0 Hasta 1023 Con Paso 1 Hacer
celdas[i] <- 0;
FinPara
Para i <- 1 Hasta vueltas Con Paso 1 Hacer
celdas[i mod 1024] <- celdas[i mod 1024] + i;
FinPara
Escribir celdas[7];
FinAlgoritmo
";

pub fn depth_case(depth: usize) -> Result<CompiledCase, String> {
    compile_case(
        &format!("depth-{depth}"),
        DEPTH_SOURCE,
        vec![depth.to_string()],
    )
}

pub fn storage_case(levels: usize) -> Result<CompiledCase, String> {
    let storage = crate::corpus::awfy_cases()?
        .into_iter()
        .find(|case| case.name == "storage")
        .ok_or("Missing storage workload")?;
    compile_case(
        &format!("storage-{levels}"),
        &storage.source,
        vec![levels.to_string()],
    )
}
