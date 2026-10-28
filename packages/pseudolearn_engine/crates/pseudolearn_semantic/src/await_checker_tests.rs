use crate::session::SemanticOptions;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn accepts_an_awaited_suspendible_call() {
    for (program, profile) in programs("awaited_call") {
        for strict in [true, false] {
            assert!(analyze(program, profile, strict).is_empty());
        }
    }
}

#[test]
fn accepts_await_in_values_calls_and_recursive_procedures() {
    for kind in [
        "arithmetic",
        "argument",
        "chain",
        "one_character",
        "recursive",
    ] {
        for (program, profile) in programs(kind) {
            for strict in [true, false] {
                let diagnostics = analyze(program, profile, strict);
                assert!(diagnostics.is_empty(), "{kind}: {diagnostics:?}");
            }
        }
    }
}

#[test]
fn reports_unawaited_calls_and_invalid_operands() {
    for (program, profile) in programs("unawaited_call") {
        for strict in [true, false] {
            assert_eq!(
                analyze(program, profile, strict),
                vec![DiagnosticCode::SuspendibleCallWithoutAwait]
            );
        }
    }
    for (program, profile) in programs("invalid_operand") {
        for strict in [true, false] {
            assert_eq!(
                analyze(program, profile, strict),
                vec![DiagnosticCode::AwaitOperandInvalid]
            );
        }
    }
}

#[test]
fn reports_context_errors_with_specific_precedence() {
    for (program, profile) in programs("outside_suspendible") {
        for strict in [true, false] {
            assert_eq!(
                analyze(program, profile, strict),
                vec![DiagnosticCode::AwaitOutsideSuspendible]
            );
        }
    }
    for (program, profile) in programs("inside_defer") {
        for strict in [true, false] {
            assert_eq!(
                analyze(program, profile, strict),
                vec![DiagnosticCode::AwaitInsideDefer]
            );
        }
    }
}

#[test]
fn includes_suspension_in_pure_function_effect_analysis() {
    for (program, profile) in programs("pure_function") {
        for strict in [true, false] {
            let diagnostics = analyze(program, profile, strict);
            assert!(diagnostics.contains(&DiagnosticCode::AwaitOutsideSuspendible));
            assert!(diagnostics.contains(&DiagnosticCode::PureFunctionTransitiveSideEffect));
        }
    }
}

fn programs(kind: &str) -> Vec<(&'static str, Profile)> {
    let spanish = match kind {
        "arithmetic" => {
            "SubProceso Suspendible ReadNow(clock Como Reloj) Como Entero\nSegun Aguardar clock.Ahora() Hacer\nExito(value): Retornar value;\nError(problem): Escribir problem.Codigo;\nRetornar 0;\nFinSegun\nRetornar 0;\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarReloj() Hacer\nExito(clock): Escribir (Aguardar ReadNow(clock)) + (Aguardar ReadNow(clock));\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
        }
        "argument" => {
            "SubProceso Suspendible ReadNow(clock Como Reloj) Como Entero\nSegun Aguardar clock.Ahora() Hacer\nExito(value): Retornar value;\nError(problem): Escribir problem.Codigo;\nRetornar 0;\nFinSegun\nRetornar 0;\nFinSubProceso\nFuncion UseValue(value Como Entero) Como Entero\nRetornar value;\nFinFuncion\nAlgoritmo Main\nSegun SolicitarReloj() Hacer\nExito(clock): Escribir UseValue(Aguardar ReadNow(clock));\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
        }
        "chain" => {
            "SubProceso Suspendible First()\nAguardar Second();\nFinSubProceso\nSubProceso Suspendible Second()\nAguardar Third();\nFinSubProceso\nSubProceso Suspendible Third()\nEscribir 1;\nFinSubProceso\nAlgoritmo Main\nAguardar First();\nFinAlgoritmo\n"
        }
        "one_character" => {
            "SubProceso Suspendible A()\nEscribir 1;\nFinSubProceso\nAlgoritmo Main\nAguardar A();\nFinAlgoritmo\n"
        }
        "recursive" => {
            "SubProceso Suspendible Recurse(level Como Entero)\nSi level > 0 Entonces\nAguardar Recurse(level - 1);\nFinSi\nEscribir 0;\nFinSubProceso\nAlgoritmo Main\nAguardar Recurse(3);\nFinAlgoritmo\n"
        }
        "awaited_call" => {
            "SubProceso Suspendible Value()\nEscribir 7;\nFinSubProceso\nAlgoritmo Main\nAguardar Value();\nFinAlgoritmo\n"
        }
        "unawaited_call" => {
            "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo Main\nWork();\nFinAlgoritmo\n"
        }
        "invalid_operand" => "Algoritmo Main\nEscribir Aguardar 1;\nFinAlgoritmo\n",
        "outside_suspendible" => {
            "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nSubProceso Caller()\nAguardar Work();\nFinSubProceso\nAlgoritmo Main\nCaller();\nFinAlgoritmo\n"
        }
        "inside_defer" => {
            "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nSubProceso Suspendible Caller()\nDiferir\nAguardar Work();\nFinDiferir\nFinSubProceso\nAlgoritmo Main\nAguardar Caller();\nFinAlgoritmo\n"
        }
        _ => {
            "SubProceso Suspendible Worker()\nEscribir 1;\nFinSubProceso\nFuncion Calculate() Como Entero\nAguardar Worker();\nRetornar 1;\nFinFuncion\nAlgoritmo Main\nEscribir Calculate();\nFinAlgoritmo\n"
        }
    };
    let english = match kind {
        "arithmetic" => {
            "subroutine suspendable ReadNow(clock as Clock) as integer\nswitch await clock.now() do\nsuccess(value): return value;\nfailure(problem): write problem.code;\nreturn 0;\nendSwitch\nreturn 0;\nendSubroutine\nalgorithm Main\nswitch requestClock() do\nsuccess(clock): write (await ReadNow(clock)) + (await ReadNow(clock));\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
        }
        "argument" => {
            "subroutine suspendable ReadNow(clock as Clock) as integer\nswitch await clock.now() do\nsuccess(value): return value;\nfailure(problem): write problem.code;\nreturn 0;\nendSwitch\nreturn 0;\nendSubroutine\nfunction UseValue(value as integer) as integer\nreturn value;\nend function\nalgorithm Main\nswitch requestClock() do\nsuccess(clock): write UseValue(await ReadNow(clock));\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
        }
        "chain" => {
            "subroutine suspendable First()\nawait Second();\nendSubroutine\nsubroutine suspendable Second()\nawait Third();\nendSubroutine\nsubroutine suspendable Third()\nwrite 1;\nendSubroutine\nalgorithm Main\nawait First();\nendAlgorithm\n"
        }
        "one_character" => {
            "subroutine suspendable A()\nwrite 1;\nendSubroutine\nalgorithm Main\nawait A();\nendAlgorithm\n"
        }
        "recursive" => {
            "subroutine suspendable Recurse(level as integer)\nif level > 0 then\nawait Recurse(level - 1);\nendIf\nwrite 0;\nendSubroutine\nalgorithm Main\nawait Recurse(3);\nendAlgorithm\n"
        }
        "awaited_call" => {
            "subroutine suspendable Value()\nwrite 7;\nendSubroutine\nalgorithm Main\nawait Value();\nendAlgorithm\n"
        }
        "unawaited_call" => {
            "subroutine suspendable Work()\nendSubroutine\nalgorithm Main\nWork();\nendAlgorithm\n"
        }
        "invalid_operand" => "algorithm Main\nwrite await 1;\nendAlgorithm\n",
        "outside_suspendible" => {
            "subroutine suspendable Work()\nwrite 1;\nendSubroutine\nsubroutine Caller()\nawait Work();\nendSubroutine\nalgorithm Main\nCaller();\nendAlgorithm\n"
        }
        "inside_defer" => {
            "subroutine suspendable Work()\nwrite 1;\nendSubroutine\nsubroutine suspendable Caller()\ndefer\nawait Work();\nendDefer\nendSubroutine\nalgorithm Main\nawait Caller();\nendAlgorithm\n"
        }
        _ => {
            "subroutine suspendable Worker()\nwrite 1;\nendSubroutine\nfunction Calculate() as integer\nawait Worker();\nreturn 1;\nend function\nalgorithm Main\nwrite Calculate();\nendAlgorithm\n"
        }
    };
    vec![(spanish, Profile::Spanish), (english, Profile::English)]
}

fn analyze(program: &str, profile: Profile, strict: bool) -> Vec<DiagnosticCode> {
    let source = SourceText::new(program.to_owned());
    let (tree, syntax_diagnostics) = parse_source(&source, profile);
    assert!(syntax_diagnostics.is_empty());
    let (_, diagnostics) =
        crate::analyze_with_options(&tree, &source, SemanticOptions { profile, strict });
    diagnostics
        .into_iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}
