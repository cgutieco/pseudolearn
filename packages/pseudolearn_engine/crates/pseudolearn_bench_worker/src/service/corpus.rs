use pseudolearn_api::service::Profile;

pub struct ReferenceProgram {
    pub name: String,
    pub text: String,
    pub profile: Profile,
}

pub fn reference_programs() -> Result<Vec<ReferenceProgram>, String> {
    let directory = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../../apps/pseudolearn_app/assets/knowledge/examples");
    let mut programs = Vec::new();
    for entry in std::fs::read_dir(&directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        let name = path
            .file_name()
            .and_then(|value| value.to_str())
            .unwrap_or("")
            .to_owned();
        if !name.ends_with(".pseudo") {
            continue;
        }
        let profile = if name.ends_with("_en.pseudo") {
            Profile::English
        } else {
            Profile::Spanish
        };
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        programs.push(ReferenceProgram {
            name,
            text,
            profile,
        });
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
