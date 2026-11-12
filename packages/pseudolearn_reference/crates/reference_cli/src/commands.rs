use crate::book::{Book, compile};
use crate::checks::{documents, verify};
use crate::web_bundles::{web_editions, web_route_editions};
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
    web_output: PathBuf,
    web_route_output: PathBuf,
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
        "build" if violations.is_empty() || options.draft => write_bundles(&book, options)?,
        "check" => violations.extend(stale_bundles(&book, options)?),
        _ => {}
    }
    report_violations(&violations);
    Ok(violations.is_empty())
}

fn write_bundles(book: &Book, options: &Options) -> Result<(), String> {
    crate::bundle_files::write(&options.output, &book.bundles)?;
    crate::bundle_files::write(&options.route_output, &book.route_bundles)?;
    crate::bundle_files::write(&options.web_output, &web_editions(&book.bundles))?;
    crate::bundle_files::write(
        &options.web_route_output,
        &web_route_editions(&book.route_bundles),
    )?;
    println!(
        "reference: bundles written to {}, {}, {} and {}",
        options.output.display(),
        options.route_output.display(),
        options.web_output.display(),
        options.web_route_output.display()
    );
    Ok(())
}

fn stale_bundles(book: &Book, options: &Options) -> Result<Vec<Violation>, String> {
    let mut violations =
        crate::bundle_files::compare(&options.output, &book.bundles, RuleId::BundleStale)?;
    violations.extend(crate::bundle_files::compare(
        &options.route_output,
        &book.route_bundles,
        RuleId::RouteBundleStale,
    )?);
    violations.extend(crate::bundle_files::compare(
        &options.web_output,
        &web_editions(&book.bundles),
        RuleId::WebBundleStale,
    )?);
    violations.extend(crate::bundle_files::compare(
        &options.web_route_output,
        &web_route_editions(&book.route_bundles),
        RuleId::WebRouteBundleStale,
    )?);
    Ok(violations)
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
                    RuleId::BundleStale
                        | RuleId::RouteBundleStale
                        | RuleId::WebBundleStale
                        | RuleId::WebRouteBundleStale
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
    let mut overrides = std::collections::BTreeMap::new();
    let mut draft = false;
    while let Some(flag) = words.next() {
        if flag == "--borrador" {
            draft = true;
            continue;
        }
        let value = words.next().ok_or_else(usage)?;
        match flag.as_str() {
            "--root" => root = PathBuf::from(value),
            "--out" | "--out-ruta" | "--out-web" | "--out-web-ruta" => {
                overrides.insert(flag.as_str(), PathBuf::from(value));
            }
            _ => return Err(usage()),
        }
    }
    Ok((command, resolve_options(root, &overrides, draft)))
}

fn resolve_options(
    root: PathBuf,
    overrides: &std::collections::BTreeMap<&str, PathBuf>,
    draft: bool,
) -> Options {
    let output_for = |flag: &str, default: &str| {
        overrides
            .get(flag)
            .cloned()
            .unwrap_or_else(|| root.join(default))
    };
    Options {
        output: output_for("--out", "../../apps/pseudolearn_app/assets/reference"),
        route_output: output_for("--out-ruta", "../../apps/pseudolearn_app/assets/route"),
        web_output: output_for(
            "--out-web",
            "../../apps/pseudolearn_web/src/entities/specification/generated",
        ),
        web_route_output: output_for(
            "--out-web-ruta",
            "../../apps/pseudolearn_web/src/entities/learning-route/generated",
        ),
        root: root.clone(),
        draft,
    }
}

fn usage() -> String {
    "usage: reference <build|check|coverage|lock> [--root DIR] [--out DIR] [--out-ruta DIR] [--out-web DIR] [--out-web-ruta DIR] [--borrador]".to_owned()
}
