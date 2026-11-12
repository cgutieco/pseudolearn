mod translation;

pub use translation::{code, translate};

pub const TASKS: &str = "SubProceso Suspendible Produce(stream Como Canal<Entero>)
  Definir accepted Como Logico <- Aguardar stream.Enviar(1);
  Si accepted Entonces
  FinSi
  stream.Cerrar();
FinSubProceso

SubProceso Suspendible Consume(stream Como Canal<Entero>)
  Repetir
  Segun Aguardar stream.Recibir() Hacer
  Algo(received): Escribir received;
  Nada: Salir;
  FinSegun
  Hasta Que Falso
FinSubProceso

Algoritmo P
  Definir stream Como Canal<Entero> <- Canal(1);
  Tareas
  Lanzar Produce(stream);
  Lanzar Consume(stream);
  FinTareas
FinAlgoritmo
";

pub const HIERARCHY: &str = "Clase Animal
Definir nombre Como Cadena;
Metodo Constructor(n Como Cadena)
Este.nombre <- n;
FinMetodo
Metodo hablar() Como Cadena
Retornar Este.nombre + \" hace ruido\";
FinMetodo
FinClase
Clase Perro Hereda De Animal
Metodo Constructor(n Como Cadena)
Super.Constructor(n);
FinMetodo
Metodo hablar() Como Cadena
Retornar Super.hablar() + \" y ladra\";
FinMetodo
FinClase
Algoritmo P
Definir a Como Animal <- Nuevo Perro(\"Rex\");
Escribir a.hablar();
FinAlgoritmo
";

pub const NETWORK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>
Definir net Como RedCap <- Propagar SolicitarRed();
Retornar Exito(1);
FinSubProceso
Algoritmo Main
Segun Probe() Hacer
Exito(value): Escribir value;
Error(problem): Escribir problem.Codigo;
FinSegun
FinAlgoritmo
";

pub const FAILING_SCOPE: &str = "SubProceso Suspendible Work() Como Resultado<Entero, Cadena>
Retornar Error(\"failed\");
FinSubProceso
Algoritmo P
Tareas failureReport
Lanzar Work();
FinTareas
Segun failureReport Hacer
Nada: Escribir \"ok\";
Algo(problem): Escribir problem.Primero, problem.Canceladas;
FinSegun
FinAlgoritmo
";

pub const SELECTION: &str = "SubProceso Suspendible Close(stream Como Canal<Entero>)
stream.Cerrar();
FinSubProceso
Algoritmo P
Definir stream Como Canal<Entero> <- Canal(1);
Definir other Como Canal<Entero> <- Canal(4);
Tareas
Lanzar Close(other);
Elegir
Recibir first Desde stream:
Segun first Hacer
Algo(value): Escribir value;
Nada: Escribir 1;
FinSegun
Recibir second Desde other:
Segun second Hacer
Algo(value): Escribir value;
Nada: Escribir 2;
FinSegun
FinElegir
FinTareas
FinAlgoritmo
";
