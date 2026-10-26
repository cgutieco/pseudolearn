pub const ROUNDS: u32 = 2000;
pub const COMBINATIONS: [u32; 3] = [1, 10, 60];
pub const MAXIMUM_INSTANCES: u32 = 64;

pub struct Workload {
    pub name: String,
    pub candidate: String,
    pub control: String,
}

pub fn generics() -> Vec<Workload> {
    COMBINATIONS.iter().map(|count| generic(*count)).collect()
}

pub fn closures() -> Vec<Workload> {
    vec![closure_call(), closure_create()]
}

pub fn inactive_effects() -> Vec<Workload> {
    vec![pure_algorithmic_loop()]
}

fn pure_algorithmic_loop() -> Workload {
    let source = format!(
        "Funcion calcular(n Como Entero) Como Entero\nDefinir Mutable acc Como Entero <- 0;\nDefinir Mutable i Como Entero <- 0;\nMientras i < n Hacer\nacc <- acc + (i * 2);\ni <- i + 1;\nFinMientras\nRetornar acc;\nFinFuncion\nAlgoritmo Principal\nDefinir res Como Entero <- calcular({ROUNDS});\nEscribir res;\nFinAlgoritmo\n"
    );
    Workload {
        name: "inactive-overhead".to_owned(),
        candidate: source.clone(),
        control: source,
    }
}

pub fn expansive_generic_source() -> String {
    "Registro Caja<T>\nDefinir v Como T;\nFinRegistro\nSubProceso crecer<T>(valor Como T)\ncrecer(Caja(valor));\nFinSubProceso\nAlgoritmo P\ncrecer(1);\nFinAlgoritmo\n"
        .to_owned()
}

fn record_declarations(count: u32) -> String {
    (1..=count)
        .map(|index| format!("Registro R{index}\nDefinir v Como Entero;\nFinRegistro\n"))
        .collect()
}

fn loop_body(count: u32, call: impl Fn(u32) -> String) -> String {
    (1..=count)
        .map(|index| {
            format!(
                "Definir valor{index} Como R{index} <- {};\ntotal <- total + valor{index}.v;\n",
                call(index)
            )
        })
        .collect()
}

fn main_program(count: u32, call: impl Fn(u32) -> String) -> String {
    format!(
        "Algoritmo P\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable i Como Entero <- 0;\nMientras i < {ROUNDS} Hacer\n{}i <- i + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n",
        loop_body(count, call)
    )
}

fn generic(count: u32) -> Workload {
    let candidate = format!(
        "{}SubProceso visitar<T>(x Como T) Como T\nRetornar x;\nFinSubProceso\n{}",
        record_declarations(count),
        main_program(count, |index| format!("visitar(R{index}(i))"))
    );
    let control_functions: String = (1..=count)
        .map(|index| {
            format!("SubProceso visitar{index}(x Como R{index}) Como R{index}\nRetornar x;\nFinSubProceso\n")
        })
        .collect();
    let control = format!(
        "{}{control_functions}{}",
        record_declarations(count),
        main_program(count, |index| format!("visitar{index}(R{index}(i))"))
    );
    Workload {
        name: format!("generic-{count}"),
        candidate,
        control,
    }
}

fn closure_call() -> Workload {
    let candidate = format!(
        "SubProceso fabricar(base Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- base;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo P\nDefinir callback Como SubProceso() Como Entero <- fabricar(3);\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable i Como Entero <- 0;\nMientras i < {ROUNDS} Hacer\ntotal <- total + callback();\ni <- i + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n"
    );
    let control = format!(
        "SubProceso directo(captured Como Entero) Como Entero\nRetornar captured;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable i Como Entero <- 0;\nMientras i < {ROUNDS} Hacer\ntotal <- total + directo(3);\ni <- i + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n"
    );
    Workload {
        name: "closure-call".to_owned(),
        candidate,
        control,
    }
}

fn closure_create() -> Workload {
    let candidate = format!(
        "SubProceso fabricar(base Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- base;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable i Como Entero <- 0;\nMientras i < {ROUNDS} Hacer\nDefinir callback Como SubProceso() Como Entero <- fabricar(i);\ntotal <- total + callback();\ni <- i + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n"
    );
    let control = format!(
        "SubProceso directo(captured Como Entero) Como Entero\nRetornar captured;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable total Como Entero <- 0;\nDefinir Mutable i Como Entero <- 0;\nMientras i < {ROUNDS} Hacer\ntotal <- total + directo(i);\ni <- i + 1;\nFinMientras\nEscribir total;\nFinAlgoritmo\n"
    );
    Workload {
        name: "closure-create".to_owned(),
        candidate,
        control,
    }
}
