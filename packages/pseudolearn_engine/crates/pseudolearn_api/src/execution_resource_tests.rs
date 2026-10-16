use super::ExecutionResource;
use crate::ExecuteRequest;
use pseudolearn_vm::{machine_event_count, machine_events};

#[test]
fn execution_checkpoints_retain_small_deltas_and_live_machine() {
    let request = ExecuteRequest {
        program: "Algoritmo Checkpoints\nDefinir index Como Entero;\nDimension values[4096] Como Entero;\nPara index <- 1 Hasta 160 Con Paso 1 Hacer\nvalues[index] <- index;\nEscribir index;\nFinPara\nFinAlgoritmo\n".to_owned(),
        ..ExecuteRequest::default()
    };
    let execution = ExecutionResource::start(&request);
    assert!(execution.is_ok());
    let Ok(mut execution) = execution else {
        return;
    };
    let advance = execution.advance(256);
    assert!(advance.is_ok());
    let stats = execution.store.stats();
    assert!(stats.checkpoints > 1);
    assert!(stats.live_words > 4096);
    assert!(stats.last_cost.copied_slots < stats.live_words / 2);
    assert!(machine_events(&execution.machine).is_empty());
    assert!(machine_event_count(&execution.machine) >= 256);
}
