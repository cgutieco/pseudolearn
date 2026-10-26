use pseudolearn_ir::{print_canonical, verify_module};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_with_options};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn propagation_edges_preserve_typed_ssa_values() -> Result<(), String> {
    let source = SourceText::new("subroutine Fetch() as optional<integer>\nreturn some(7);\nendSubroutine\nsubroutine Forward() as optional<integer>\ndefine number as integer <- propagate Fetch();\nreturn some(number + 2);\nendSubroutine\nalgorithm Main\nswitch Forward() do\nsome(number): write number;\nnone: write 0;\nendSwitch\nendAlgorithm\n".to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let (module, diagnostics) = analyze_with_options(
        &tree,
        &source,
        SemanticOptions {
            profile: Profile::English,
            strict: true,
        },
    );
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let module = module.ok_or_else(|| "missing HIR".to_owned())?;
    let lowered = pseudolearn_lowering::lower_module(&module, &source)
        .map_err(|failure| format!("{failure:?}"))?;
    verify_module(&lowered)
        .map_err(|failure| format!("{failure}\n{}", print_canonical(&lowered)))?;
    Ok(())
}

#[test]
fn loop_body_bindings_do_not_create_undefined_header_arguments() -> Result<(), String> {
    for body in [
        "define mutable counter as integer <- 0;\nwhile counter < 2 do\ndefine value as integer <- counter;\nwrite value;\ncounter <- counter + 1;\nendWhile",
        "define mutable counter as integer <- 0;\nfor counter <- 1 to 2 step 1 do\ndefine value as integer <- counter;\nwrite value;\nendFor",
        "define mutable counter as integer <- 0;\nrepeat\ndefine value as integer <- counter;\ncounter <- counter + 1;\nwrite value;\nuntil counter = 2",
    ] {
        let program = format!("algorithm Main\n{body}\nendAlgorithm\n");
        let module = pseudolearn_api::compile_source_to_module(&program, "en", "strict")
            .map_err(|errors| format!("{errors:?}\n{program}"))?;
        verify_module(&module).map_err(|error| format!("{error:?}"))?;
    }
    Ok(())
}
