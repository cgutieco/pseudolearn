use crate::book::compile;
use crate::checks::{documents, verify};
use crate::workspace::{LOCK_FILE, Workspace, load};
use reference_engine::ApiEngine;
use reference_model::{Profile, RuleId, Violation};
use reference_resolve::CachedEngine;
use reference_verify::{CoverageReport, build_lock};
use std::path::PathBuf;

struct Options {
    root: PathBuf,
    output: PathBuf,
    route_output: PathBuf,
    draft: bool,
}

pub fn run(arguments: &[String]) -> Result<bool, String> {
    let (command, options) = parse(arguments)?;
    let workspace = load(&options.root)?;
    match command.as_str() {
        "lock" => lock(&workspace),
        "build" | "check" | "coverage" => compiled(&command, &workspace, &options),
        _ => Err(usage()),
    }
}

fn compiled(command: &str, workspace: &Workspace, options: &Options) -> Result<bool, String> {
    let engine = CachedEngine::new(ApiEngine);
    let book = compile(workspace, &engine)?;
    let (mut violations, report) = verify(workspace, &book);
    match command {
        "coverage" => {
            print_coverage(&report);
            crate::route_coverage::print_route_coverage(&book);
            return Ok(true);
        }
        "build" if violations.is_empty() || options.draft => {
            crate::bundle_files::write(&options.output, &book.bundles)?;
            crate::bundle_files::write(&options.route_output, &book.route_bundles)?;
            println!(
                "reference: bundles written to {} and {}",
                options.output.display(),
                options.route_output.display()
            );
        }
        "check" => {
            violations.extend(crate::bundle_files::compare(
                &options.output,
                &book.bundles,
                RuleId::BundleStale,
            )?);
            violations.extend(crate::bundle_files::compare(
                &options.route_output,
                &book.route_bundles,
                RuleId::RouteBundleStale,
            )?);
        }
        _ => {}
    }
    report_violations(&violations);
    Ok(violations.is_empty())
}

fn lock(workspace: &Workspace) -> Result<bool, String> {
    let lock = build_lock(documents(workspace, Profile::Spanish), &workspace.corpus);
    let text = serde_json::to_string_pretty(&lock).map_err(|error| error.to_string())?;
    let path = workspace.root.join(LOCK_FILE);
    std::fs::write(&path, format!("{text}\n"))
        .map_err(|error| format!("cannot write {}: {error}", path.display()))?;
    println!("reference: anchors locked in {}", path.display());
    Ok(true)
}

fn report_violations(violations: &[Violation]) {
    for violation in violations {
        eprintln!("{violation}");
    }
    if !violations.is_empty() {
        let stale = violations
            .iter()
            .filter(|violation| {
                matches!(
                    violation.rule,
                    RuleId::BundleStale | RuleId::RouteBundleStale
                )
            })
            .count();
        eprintln!(
            "reference: {} violations ({stale} stale bundle files)",
            violations.len()
        );
    }
}

fn print_coverage(report: &CoverageReport) {
    for area in &report.areas {
        let measured = area.total.saturating_sub(area.excluded).max(1);
        let percent = area
            .covered
            .saturating_mul(100)
            .checked_div(measured)
            .unwrap_or(0);
        println!(
            "{:<15} {:>4}/{:<4} {percent:>3}%  excluded {}",
            area.name,
            area.covered,
            area.total.saturating_sub(area.excluded),
            area.excluded
        );
        for missing in &area.missing {
            println!("  missing {missing}");
        }
    }
}

fn parse(arguments: &[String]) -> Result<(String, Options), String> {
    let mut words = arguments.iter();
    let command = words.next().cloned().ok_or_else(usage)?;
    let mut root = PathBuf::from(".");
    let mut output = None;
    let mut route_output = None;
    let mut draft = false;
    while let Some(flag) = words.next() {
        if flag == "--borrador" {
            draft = true;
            continue;
        }
        let value = words.next().ok_or_else(usage)?;
        match flag.as_str() {
            "--root" => root = PathBuf::from(value),
            "--out" => output = Some(PathBuf::from(value)),
            "--out-ruta" => route_output = Some(PathBuf::from(value)),
            _ => return Err(usage()),
        }
    }
    let output = output.unwrap_or_else(|| root.join("../../apps/pseudolearn_app/assets/reference"));
    let route_output =
        route_output.unwrap_or_else(|| root.join("../../apps/pseudolearn_app/assets/route"));
    Ok((
        command,
        Options {
            root,
            output,
            route_output,
            draft,
        },
    ))
}

fn usage() -> String {
    "usage: reference <build|check|coverage|lock> [--root DIR] [--out DIR] [--out-ruta DIR] [--borrador]".to_owned()
}
