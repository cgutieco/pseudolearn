use pseudolearn_api::service::Profile;

pub struct ReferenceProgram {
    pub name: String,
    pub text: String,
    pub profile: Profile,
}

pub fn reference_programs() -> Result<Vec<ReferenceProgram>, String> {
    let mut programs = Vec::new();
    for (edition, profile) in [("es/es", Profile::Spanish), ("en/en", Profile::English)] {
        let directory = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(format!(
            "../../../../apps/pseudolearn_app/assets/route/{edition}/exercises"
        ));
        for entry in std::fs::read_dir(&directory).map_err(|error| error.to_string())? {
            let path = entry.map_err(|error| error.to_string())?.path();
            let document: serde_json::Value = serde_json::from_str(
                &std::fs::read_to_string(&path).map_err(|error| error.to_string())?,
            )
            .map_err(|error| error.to_string())?;
            let teaches_errors = document
                .get("id")
                .and_then(serde_json::Value::as_str)
                .is_some_and(|identifier| identifier.contains(".errores."));
            let Some(text) = document
                .pointer("/program/source")
                .and_then(serde_json::Value::as_str)
            else {
                continue;
            };
            if teaches_errors {
                continue;
            }
            programs.push(ReferenceProgram {
                name: format!(
                    "{edition}/{}",
                    path.file_name()
                        .and_then(|value| value.to_str())
                        .unwrap_or("")
                ),
                text: text.to_owned(),
                profile,
            });
        }
    }
    programs.sort_by(|left, right| left.name.cmp(&right.name));
    Ok(programs)
}

pub fn machine_description() -> serde_json::Value {
    let brand = std::process::Command::new("sysctl")
        .args(["-n", "machdep.cpu.brand_string"])
        .output()
        .ok()
        .and_then(|output| String::from_utf8(output.stdout).ok())
        .map(|text| text.trim().to_owned())
        .filter(|text| !text.is_empty());
    let compiler = std::process::Command::new("rustc")
        .arg("--version")
        .output()
        .ok()
        .and_then(|output| String::from_utf8(output.stdout).ok())
        .map(|text| text.trim().to_owned());
    serde_json::json!({
        "os": std::env::consts::OS,
        "arch": std::env::consts::ARCH,
        "cpu": brand,
        "rustc": compiler,
    })
}
