use crate::dap_launch_options::configure;
use crate::options::parse_cli_options;
use serde_json::json;

#[test]
fn launch_options_keep_i64_values_exact_and_observe_events() -> Result<(), String> {
    let mut options = parse_cli_options(&[]).ok().ok_or("missing options")?;
    configure(
        &mut options,
        &json!({"seed":"9223372036854775807","profile":"en"}),
    )?;
    assert_eq!(options.execution.seed, Some(i64::MAX));
    assert_eq!(options.vocabulary.as_deref(), Some("en"));
    assert!(options.execution.trace);
    Ok(())
}

#[test]
fn malformed_or_noncanonical_launch_configuration_is_rejected() -> Result<(), String> {
    let mut options = parse_cli_options(&[]).ok().ok_or("missing options")?;
    for arguments in [
        json!({"seed":1}),
        json!({"seed":"01"}),
        json!({"seed":"-0"}),
        json!({"backend":"native"}),
        json!({"profile":1}),
        json!({"stopOnEntry":"false"}),
        json!({"workspaceRoot":1}),
    ] {
        assert!(configure(&mut options, &arguments).is_err());
    }
    Ok(())
}

#[test]
fn launch_rejects_retired_authority_configuration() -> Result<(), String> {
    let mut options = parse_cli_options(&[]).ok().ok_or("missing options")?;
    for field in [
        "permissions",
        "grants",
        "origins",
        "filesRoot",
        "env",
        "serverPath",
    ] {
        let arguments = json!({field:"untrusted"});
        assert!(configure(&mut options, &arguments).is_err());
    }
    Ok(())
}

#[test]
fn launch_preserves_empty_and_unicode_arguments() -> Result<(), String> {
    let mut options = parse_cli_options(&[]).ok().ok_or("missing options")?;
    configure(&mut options, &json!({"args":["", "λ", "--seed"]}))?;
    assert_eq!(options.execution.program_arguments, ["", "λ", "--seed"]);
    assert!(configure(&mut options, &json!({"args":[1]})).is_err());
    assert!(
        configure(
            &mut options,
            &json!({"cwd":"/missing-pseudolearn-directory"})
        )
        .is_err()
    );
    Ok(())
}
