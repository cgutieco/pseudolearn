use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;
use pseudolearn_transpiler::{TargetLanguage, TranspileOutcome, TranspileRequest, transpile};

pub fn translate(program: &str, target: TargetLanguage) -> Result<TranspileOutcome, String> {
    let source = SourceText::new(program.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let options = SemanticOptions {
        profile: Profile::Spanish,
    };
    let (module, _) = analyze_with_options(&tree, &source, options);
    let module = module.ok_or("analysis failed")?;
    let request = TranspileRequest {
        target,
        profile: Profile::Spanish,
        seed: Some(7),
        truth: "Verdadero",
        falsity: "Falso",
    };
    Ok(transpile(&module, &request))
}

pub fn code(program: &str, target: TargetLanguage) -> Result<String, String> {
    match translate(program, target)? {
        TranspileOutcome::Code(transpilation) => Ok(transpilation.code),
        TranspileOutcome::Unavailable(blockers) => Err(format!("unavailable: {blockers:?}")),
    }
}

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
