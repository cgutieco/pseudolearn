#![cfg(feature = "native")]

#[path = "native_access/support.rs"]
mod support;

#[test]
fn method_variant_results_preserve_inactive_roots_under_forced_collection() -> Result<(), String> {
    support::compare(
        "Clase Holder\nDefinir amount Como Entero;\nMetodo Fetch() Como Resultado<Entero, Holder>\nRetornar Error(Nuevo Holder());\nFinMetodo\nFinClase\nAlgoritmo Main\nDefinir holder Como Holder <- Nuevo Holder();\nDefinir Mutable outcome Como Resultado<Entero, Holder> <- holder.Fetch();\nDescartar outcome;\noutcome <- Exito(9);\nDefinir keeper Como Holder <- Nuevo Holder();\nkeeper.amount <- 7;\nSegun outcome Hacer\nExito(number): Escribir number;\nError(problem): Escribir problem.amount;\nFinSegun\nEscribir keeper.amount;\nFinAlgoritmo\n",
    )
}
