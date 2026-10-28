use crate::pg_tasks_agendas::{Agenda, Expected, SplitMix64};
use serde_json::json;

const CAPACITIES: [u64; 4] = [1, 2, 8, 64];

fn agenda(seed: u64, family: u64, program: String, expected: Expected) -> Agenda {
    Agenda {
        seed,
        family,
        program,
        host: None,
        gc_stress: false,
        expected,
    }
}

fn completed(output: String) -> Expected {
    Expected {
        output,
        termination: "completed",
    }
}

pub fn build(seed: u64, family: u64, random: &mut SplitMix64) -> Agenda {
    match family {
        0 => fan_out(seed, random),
        1 => producer_consumer(seed, random),
        2 => sibling_failure(seed, random),
        3 => starvation(seed, random),
        4 => ready_selection(seed, random),
        5 => injected_deadlock(seed, random),
        6 => concurrent_effects(seed, random),
        _ => snapshot_under_collection(seed, random),
    }
}

fn fan_out(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(1, 1000);
    let spawns = "Lanzar Work();\n".repeat(usize::try_from(tasks).unwrap_or(0));
    let program = format!(
        "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\n{spawns}FinTareas\nEscribir \"end\";\nFinAlgoritmo\n"
    );
    let output = format!("{}end\n", "w\n".repeat(usize::try_from(tasks).unwrap_or(0)));
    agenda(seed, 0, program, completed(output))
}

fn producer_consumer(seed: u64, random: &mut SplitMix64) -> Agenda {
    let capacity = CAPACITIES
        .get(usize::try_from(random.below(4)).unwrap_or(0))
        .copied()
        .unwrap_or(1);
    let items = random.between(1, 200);
    let program = format!(
        "SubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir Mutable index Como Entero <- 0;\nPara index <- 1 Hasta {items} Con Paso 1 Hacer\nAguardar stream.Enviar(index);\nFinPara\nstream.Cerrar();\nFinSubProceso\nSubProceso Suspendible Consume(stream Como Canal<Entero>)\nDefinir Mutable total Como Entero <- 0;\nRepetir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): total <- total + value;\nNada: Salir;\nFinSegun\nHasta Que Falso\nEscribir total;\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal({capacity});\nTareas\nLanzar Produce(stream);\nLanzar Consume(stream);\nFinTareas\nFinAlgoritmo\n"
    );
    let total: u64 = (1..=items).sum();
    agenda(seed, 1, program, completed(format!("{total}\n")))
}

fn sibling_failure(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(2, 20);
    let failing = random.between(1, tasks);
    let spawns: String = (1..=tasks)
        .map(|index| {
            if index == failing {
                format!("Lanzar Fail(\"e{failing}\");\n")
            } else {
                "Lanzar Idle(stream);\n".to_owned()
            }
        })
        .collect();
    let program = format!(
        "SubProceso Suspendible Idle(stream Como Canal<Entero>)\nDefinir Mutable total Como Entero <- 0;\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): total <- total + value;\nNada: total <- 0;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail(code Como Cadena) Como Resultado<Entero, Cadena>\nRetornar Error(code);\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas problem\n{spawns}FinTareas\nSegun problem Hacer\nNada: Escribir \"ok\";\nAlgo(report): Escribir report.Primero;\nEscribir report.Canceladas;\nFinSegun\nFinAlgoritmo\n"
    );
    let cancelled = tasks.saturating_sub(1);
    agenda(
        seed,
        2,
        program,
        completed(format!("e{failing}\n{cancelled}\n")),
    )
}

fn starvation(seed: u64, random: &mut SplitMix64) -> Agenda {
    let rounds = random.between(1500, 4500);
    let program = format!(
        "SubProceso Suspendible Spin(marker Como Cadena, stream Como Canal<Entero>)\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < {rounds} Hacer\ncounter <- counter + 1;\nFinMientras\nEscribir marker;\nAguardar stream.Enviar(1);\nFinSubProceso\nSubProceso Suspendible Waiter(stream Como Canal<Entero>)\nDefinir Mutable total Como Entero <- 0;\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): total <- total + value;\nNada: total <- 0;\nFinSegun\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): total <- total + value;\nNada: total <- 0;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(2);\nTareas\nLanzar Waiter(stream);\nLanzar Spin(\"alpha\", stream);\nLanzar Spin(\"beta\", stream);\nFinTareas\nFinAlgoritmo\n"
    );
    agenda(seed, 3, program, completed("alpha\nbeta\n".to_owned()))
}

fn ready_selection(seed: u64, random: &mut SplitMix64) -> Agenda {
    let branches = random.between(2, 4);
    let first_ready = random.below(branches);
    let channels: String = (1..=branches)
        .map(|index| format!("Definir c{index} Como Canal<Entero> <- Canal(1);\n"))
        .collect();
    let sends: String = (first_ready.saturating_add(1)..=branches)
        .map(|index| format!("Aguardar c{index}.Enviar({index});\n"))
        .collect();
    let arms: String = (1..=branches)
        .map(|index| {
            format!("Recibir r{index} Desde c{index}:\nSegun r{index} Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\n")
        })
        .collect();
    let program =
        format!("Algoritmo Main\n{channels}{sends}Elegir\n{arms}FinElegir\nFinAlgoritmo\n");
    let winner = first_ready.saturating_add(1);
    agenda(seed, 4, program, completed(format!("{winner}\n")))
}

fn injected_deadlock(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(1, 5);
    let spawns = "Lanzar Stuck(stream);\n".repeat(usize::try_from(tasks).unwrap_or(1));
    let program = format!(
        "SubProceso Suspendible Stuck(stream Como Canal<Entero>)\nDefinir Mutable total Como Entero <- 0;\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): total <- total + value;\nNada: total <- 0;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\n{spawns}FinTareas\nFinAlgoritmo\n"
    );
    agenda(
        seed,
        5,
        program,
        Expected {
            output: String::new(),
            termination: "taskDeadlock",
        },
    )
}

fn concurrent_effects(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(2, 6);
    let order = random.shuffled(tasks);
    let spawns: String = (1..=tasks)
        .map(|index| format!("Lanzar Pause({index});\n"))
        .collect();
    let program = format!(
        "SubProceso Suspendible Pause(label Como Entero)\nDescartar Aguardar SolicitarTemporizador();\nEscribir label;\nFinSubProceso\nAlgoritmo Main\nTareas\n{spawns}FinTareas\nFinAlgoritmo\n"
    );
    let output: String = order.iter().map(|label| format!("{label}\n")).collect();
    let host = json!({"permissions": ["temporizador"], "requested_permissions": ["temporizador"], "orden_entrega": order});
    Agenda {
        host: Some(host),
        ..agenda(seed, 6, program, completed(output))
    }
}

fn snapshot_under_collection(seed: u64, random: &mut SplitMix64) -> Agenda {
    let base = random.between(1, 100);
    let program = format!(
        "SubProceso Suspendible Reader(stream Como Canal<Inmutable<Vector<Vector<Entero>>>>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(frozen): Definir Mutable total Como Entero <- 0;\nPara Cada row En frozen Hacer\ntotal <- total + row[0];\nFinPara\nEscribir total;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nDefinir inner Como Vector<Entero> <- Vector();\ninner.Agregar({base});\nDefinir outer Como Vector<Vector<Entero>> <- Vector();\nouter.Agregar(inner);\nouter.Agregar(inner);\nDefinir frozen Como Inmutable<Vector<Vector<Entero>>> <- Instantanea(outer);\ninner[0] <- 0;\nDefinir stream Como Canal<Inmutable<Vector<Vector<Entero>>>> <- Canal(1);\nTareas\nLanzar Reader(stream);\nAguardar stream.Enviar(frozen);\nFinTareas\nFinAlgoritmo\n"
    );
    let doubled = base.saturating_mul(2);
    Agenda {
        gc_stress: true,
        ..agenda(seed, 7, program, completed(format!("{doubled}\n")))
    }
}
