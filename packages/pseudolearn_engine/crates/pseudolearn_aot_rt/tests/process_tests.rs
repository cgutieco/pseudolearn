use pseudolearn_aot_rt::*;
use std::cell::RefCell;
use std::io::{Cursor, Write};
use std::rc::Rc;

#[derive(Clone, Default)]
struct Sink(Rc<RefCell<Vec<u8>>>);

impl Write for Sink {
    fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
        self.0.borrow_mut().extend_from_slice(bytes);
        Ok(bytes.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

fn metadata(code: DiagnosticCode) -> ExecutableMetadata {
    ExecutableMetadata {
        settings: ExecutableSettings {
            source_name: "p.pseudo".to_owned(),
            locale: "en".to_owned(),
            seed: 1,
            limits: AotLimits::default(),
            boolean_words: BooleanWords {
                truth: "true".to_owned(),
                falsity: "false".to_owned(),
            },
            error_template: "{path}:{line}:{column}: error: {message} [{code}]\n".to_owned(),
            exhausted_template: "{path}: input ended\n".to_owned(),
        },
        sites: vec![FaultSite {
            code,
            range: SourceRange {
                start_line: 3,
                start_column: 5,
                end_line: 3,
                end_column: 9,
            },
        }],
        classes: Vec::new(),
    }
}

struct Outcome {
    code: i32,
    output: String,
    errors: String,
}

fn named(name: &str) -> Result<DiagnosticCode, String> {
    DiagnosticCode::from_name(name).ok_or_else(|| format!("unknown code {name}"))
}

fn run(metadata: ExecutableMetadata, entry: EntryFunction, input: &str) -> Outcome {
    let output = Sink::default();
    let errors = Sink::default();
    let code = run_executable(
        metadata,
        entry,
        ProcessStreams {
            input: Box::new(Cursor::new(input.as_bytes().to_vec())),
            output: Box::new(output.clone()),
            errors: Box::new(errors.clone()),
        },
    );
    let text = |sink: &Sink| String::from_utf8_lossy(&sink.0.borrow()).into_owned();
    Outcome {
        code,
        output: text(&output),
        errors: text(&errors),
    }
}

extern "C" fn write_forty_two(context: *mut AotRuntimeContext) {
    rt_aot_write(context, 0, 42, KIND_INTEGER | NEWLINE_FLAG);
}

extern "C" fn write_then_fault(context: *mut AotRuntimeContext) {
    rt_aot_write(context, 0, 1, KIND_INTEGER | NEWLINE_FLAG);
    rt_aot_fault(context, 0);
}

extern "C" fn read_integer(context: *mut AotRuntimeContext) {
    rt_aot_read(context, 0, KIND_INTEGER);
}

#[test]
fn a_completed_program_exits_zero_with_its_output_and_no_diagnostics() -> Result<(), String> {
    let outcome = run(metadata(DiagnosticCode::InternalFault), write_forty_two, "");
    assert_eq!(outcome.code, EXIT_COMPLETED);
    assert_eq!(outcome.output, "42\n");
    assert_eq!(outcome.errors, "");
    Ok(())
}

#[test]
fn a_program_fault_exits_three_after_preserving_prior_output() -> Result<(), String> {
    let code = named("divisionByZero")?;
    let outcome = run(metadata(code), write_then_fault, "");
    assert_eq!(outcome.code, EXIT_FAILED);
    assert_eq!(outcome.output, "1\n");
    assert!(outcome.errors.starts_with("p.pseudo:3:5: error: "));
    assert!(outcome.errors.ends_with(" [divisionByZero]\n"));
    Ok(())
}

#[test]
fn a_budget_fault_exits_four() -> Result<(), String> {
    let code = named("statementBudgetExhausted")?;
    let outcome = run(metadata(code), write_then_fault, "");
    assert_eq!(outcome.code, EXIT_LIMIT);
    assert!(outcome.errors.ends_with(" [statementBudgetExhausted]\n"));
    Ok(())
}

#[test]
fn an_internal_fault_exits_five() -> Result<(), String> {
    let outcome = run(
        metadata(DiagnosticCode::InternalFault),
        write_then_fault,
        "",
    );
    assert_eq!(outcome.code, EXIT_INTERNAL);
    Ok(())
}

#[test]
fn exhausted_input_exits_four_with_the_exhaustion_template() -> Result<(), String> {
    let outcome = run(metadata(DiagnosticCode::InternalFault), read_integer, "");
    assert_eq!(outcome.code, EXIT_LIMIT);
    assert_eq!(outcome.errors, "p.pseudo: input ended\n");
    Ok(())
}

#[test]
fn an_unknown_class_layout_is_an_internal_failure() -> Result<(), String> {
    let mut broken = metadata(DiagnosticCode::InternalFault);
    broken.classes.push(ClassDescriptor {
        fields: vec![99],
        dense: true,
    });
    let outcome = run(broken, write_forty_two, "");
    assert_eq!(outcome.code, EXIT_INTERNAL);
    assert_eq!(outcome.output, "");
    Ok(())
}

#[test]
fn a_template_keeps_unknown_placeholders_empty_and_unclosed_braces_literal() -> Result<(), String> {
    let mut custom = metadata(named("divisionByZero")?);
    custom.settings.error_template = "{unknown}|{line} {".to_owned();
    let outcome = run(custom, write_then_fault, "");
    assert_eq!(outcome.errors, "|3 {");
    Ok(())
}
