pub const FAN_OUT: &str = "SubProceso Suspendible Work()
Escribir \"w\";
FinSubProceso
Algoritmo Main
Definir tasks Como Entero;
Leer tasks;
Tareas
Para index <- 1 Hasta tasks Con Paso 1 Hacer
Lanzar Work();
FinPara
FinTareas
Escribir \"end\";
FinAlgoritmo
";

pub const PRODUCER_CONSUMER: &str =
    "SubProceso Suspendible Produce(stream Como Canal<Entero>, items Como Entero)
Para index <- 1 Hasta items Con Paso 1 Hacer
Aguardar stream.Enviar(index);
FinPara
stream.Cerrar();
FinSubProceso
SubProceso Suspendible Consume(stream Como Canal<Entero>)
Definir total Como Entero <- 0;
Repetir
Segun Aguardar stream.Recibir() Hacer
Algo(value): total <- total + value;
Nada: Salir;
FinSegun
Hasta Que Falso
Escribir total;
FinSubProceso
Algoritmo Main
Definir capacity, items Como Entero;
Leer capacity;
Leer items;
Definir stream Como Canal<Entero> <- Canal(capacity);
Tareas
Lanzar Produce(stream, items);
Lanzar Consume(stream);
FinTareas
FinAlgoritmo
";

pub const SIBLING_FAILURE: &str = "SubProceso Suspendible Idle(stream Como Canal<Entero>)
Definir total Como Entero <- 0;
Segun Aguardar stream.Recibir() Hacer
Algo(value): total <- total + value;
Nada: total <- 0;
FinSegun
FinSubProceso
SubProceso Suspendible Fail(code Como Cadena) Como Resultado<Entero, Cadena>
Retornar Error(code);
FinSubProceso
Algoritmo Main
Definir tasks, failing Como Entero;
Leer tasks;
Leer failing;
Definir stream Como Canal<Entero> <- Canal(1);
Tareas problem
Para index <- 1 Hasta tasks Con Paso 1 Hacer
Si index = failing Entonces
Lanzar Fail(Concatenar(\"e\", ConvertirATexto(failing)));
SiNo
Lanzar Idle(stream);
FinSi
FinPara
FinTareas
Segun problem Hacer
Nada: Escribir \"ok\";
Algo(report): Escribir report.Primero;
Escribir report.Canceladas;
FinSegun
FinAlgoritmo
";

pub const STARVATION: &str =
    "SubProceso Suspendible Spin(marker Como Cadena, stream Como Canal<Entero>, rounds Como Entero)
Definir counter Como Entero <- 0;
Mientras counter < rounds Hacer
counter <- counter + 1;
FinMientras
Escribir marker;
Aguardar stream.Enviar(1);
FinSubProceso
SubProceso Suspendible Waiter(stream Como Canal<Entero>)
Definir total Como Entero <- 0;
Segun Aguardar stream.Recibir() Hacer
Algo(value): total <- total + value;
Nada: total <- 0;
FinSegun
Segun Aguardar stream.Recibir() Hacer
Algo(value): total <- total + value;
Nada: total <- 0;
FinSegun
FinSubProceso
Algoritmo Main
Definir rounds Como Entero;
Leer rounds;
Definir stream Como Canal<Entero> <- Canal(2);
Tareas
Lanzar Waiter(stream);
Lanzar Spin(\"alpha\", stream, rounds);
Lanzar Spin(\"beta\", stream, rounds);
FinTareas
FinAlgoritmo
";

pub const READY_SELECTION: &str = "Algoritmo Main
Definir firstReady, branches Como Entero;
Leer firstReady;
Leer branches;
Definir c1 Como Canal<Entero> <- Canal(1);
Definir c2 Como Canal<Entero> <- Canal(1);
Definir c3 Como Canal<Entero> <- Canal(1);
Definir c4 Como Canal<Entero> <- Canal(1);
Para index <- firstReady + 1 Hasta branches Con Paso 1 Hacer
Segun index Hacer
1: Aguardar c1.Enviar(1);
2: Aguardar c2.Enviar(2);
3: Aguardar c3.Enviar(3);
De Otro Modo: Aguardar c4.Enviar(4);
FinSegun
FinPara
Elegir
Recibir r1 Desde c1:
Segun r1 Hacer
Algo(value): Escribir value;
Nada: Escribir 0;
FinSegun
Recibir r2 Desde c2:
Segun r2 Hacer
Algo(value): Escribir value;
Nada: Escribir 0;
FinSegun
Recibir r3 Desde c3:
Segun r3 Hacer
Algo(value): Escribir value;
Nada: Escribir 0;
FinSegun
Recibir r4 Desde c4:
Segun r4 Hacer
Algo(value): Escribir value;
Nada: Escribir 0;
FinSegun
FinElegir
FinAlgoritmo
";

pub const INJECTED_DEADLOCK: &str = "SubProceso Suspendible Stuck(stream Como Canal<Entero>)
Definir total Como Entero <- 0;
Segun Aguardar stream.Recibir() Hacer
Algo(value): total <- total + value;
Nada: total <- 0;
FinSegun
FinSubProceso
Algoritmo Main
Definir tasks Como Entero;
Leer tasks;
Definir stream Como Canal<Entero> <- Canal(1);
Tareas
Para index <- 1 Hasta tasks Con Paso 1 Hacer
Lanzar Stuck(stream);
FinPara
FinTareas
FinAlgoritmo
";

pub const CONCURRENT_EFFECTS: &str = "SubProceso Suspendible Pause(label Como Entero)
Descartar Aguardar SolicitarTemporizador();
Escribir label;
FinSubProceso
Algoritmo Main
Definir tasks Como Entero;
Leer tasks;
Tareas
Para index <- 1 Hasta tasks Con Paso 1 Hacer
Lanzar Pause(index);
FinPara
FinTareas
FinAlgoritmo
";

pub const SNAPSHOT_UNDER_COLLECTION: &str =
    "SubProceso Suspendible Reader(stream Como Canal<Inmutable<Vector<Vector<Entero>>>>)
Segun Aguardar stream.Recibir() Hacer
Algo(frozen): Definir total Como Entero <- 0;
Para Cada row En frozen Hacer
total <- total + row[0];
FinPara
Escribir total;
Nada: Escribir 0;
FinSegun
FinSubProceso
Algoritmo Main
Definir base Como Entero;
Leer base;
Definir inner Como Vector<Entero> <- Vector();
inner.Agregar(base);
Definir outer Como Vector<Vector<Entero>> <- Vector();
outer.Agregar(inner);
outer.Agregar(inner);
Definir frozen Como Inmutable<Vector<Vector<Entero>>> <- Instantanea(outer);
inner[0] <- 0;
Definir stream Como Canal<Inmutable<Vector<Vector<Entero>>>> <- Canal(1);
Tareas
Lanzar Reader(stream);
Aguardar stream.Enviar(frozen);
FinTareas
FinAlgoritmo
";
