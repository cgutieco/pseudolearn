use pseudolearn_check_model::{Architecture, Isolation, Violation, violation};
use std::path::Path;

pub fn check(root: &Path, rules: &Architecture) -> Result<Vec<Violation>, String> {
    let mut violations = Vec::new();
    for isolation in &rules.isolation {
        for target in &isolation.targets {
            let reachable = reachable_packages(root, &isolation.package, target)?;
            violations.extend(forbidden_findings(isolation, target, &reachable));
        }
    }
    Ok(violations)
}

fn reachable_packages(root: &Path, package: &str, target: &str) -> Result<Vec<String>, String> {
    let output = std::process::Command::new("cargo")
        .current_dir(root)
        .args([
            "tree",
            "--package",
            package,
            "--target",
            target,
            "--edges",
            "normal,build",
            "--prefix",
            "none",
            "--format",
            "{p}",
        ])
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    let listing = String::from_utf8_lossy(&output.stdout);
    Ok(listing
        .lines()
        .filter_map(|line| line.split_whitespace().next())
        .map(str::to_owned)
        .collect())
}

fn forbidden_findings(isolation: &Isolation, target: &str, reachable: &[String]) -> Vec<Violation> {
    let mut findings = Vec::new();
    for name in reachable {
        if isolation
            .forbidden
            .iter()
            .any(|pattern| matches_pattern(pattern, name))
        {
            findings.push(violation(
                "architecture.yaml",
                1,
                "LAYER-DIRECTION",
                &format!(
                    "{} reaches forbidden package {name} on {target}",
                    isolation.package
                ),
            ));
        }
    }
    findings
}

fn matches_pattern(pattern: &str, name: &str) -> bool {
    match pattern.strip_suffix('*') {
        Some(prefix) => name.starts_with(prefix),
        None => name == pattern,
    }
}
