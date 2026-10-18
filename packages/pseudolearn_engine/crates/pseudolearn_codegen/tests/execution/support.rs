#![forbid(unsafe_code)]

use pseudolearn_codegen::{CompiledObject, TargetConfig, compile_module_to_object};
use pseudolearn_ir::parse_module;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::atomic::{AtomicU32, Ordering};

static COUNTER: AtomicU32 = AtomicU32::new(0);

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Kind {
    Integer,
    Real,
    Boolean,
    Character,
    Handle,
    Unit,
}

impl Kind {
    fn rust_type(self) -> &'static str {
        match self {
            Self::Integer => "i64",
            Self::Real => "f64",
            Self::Boolean => "u8",
            Self::Character | Self::Handle => "u32",
            Self::Unit => "()",
        }
    }
}

pub struct Signature {
    pub parameters: Vec<Kind>,
    pub returns: Kind,
}

pub struct Call {
    pub function: usize,
    pub frames: u32,
    pub budget: Option<u64>,
    pub arguments: Vec<String>,
    pub input: String,
    pub cells: Option<u64>,
}

impl Call {
    pub fn with(function: usize, arguments: &[&str]) -> Self {
        Self {
            function,
            frames: 1_000,
            budget: None,
            arguments: arguments.iter().map(|text| (*text).to_owned()).collect(),
            input: String::new(),
            cells: None,
        }
    }
}

#[derive(Debug)]
pub struct Outcome {
    pub status: u32,
    pub value: String,
    pub code: String,
    pub range: String,
    pub depth: u32,
    pub remaining: i64,
    pub output: String,
}

pub struct Harness {
    executable: PathBuf,
    sites: PathBuf,
}

pub type Failure = String;

pub fn failure(error: impl std::fmt::Display) -> Failure {
    error.to_string()
}

pub type Patch = fn(&mut pseudolearn_ir::Module);

pub fn no_patch(_: &mut pseudolearn_ir::Module) {}

pub fn build_object_with(module_text: &str, patch: Patch) -> Result<CompiledObject, Failure> {
    let mut module = parse_module(module_text).map_err(failure)?;
    patch(&mut module);
    compile_module_to_object(&module, &TargetConfig::host()).map_err(failure)
}

pub(crate) fn work_directory() -> Result<PathBuf, Failure> {
    let number = COUNTER.fetch_add(1, Ordering::SeqCst);
    let directory = Path::new(env!("CARGO_TARGET_TMPDIR"))
        .join(format!("harness-{}-{number}", std::process::id()));
    std::fs::create_dir_all(&directory).map_err(failure)?;
    Ok(directory)
}

pub(crate) fn newest_rlib(dependencies: &Path, crate_name: &str) -> Result<PathBuf, Failure> {
    let prefix = format!("lib{crate_name}-");
    std::fs::read_dir(dependencies)
        .map_err(failure)?
        .filter_map(Result::ok)
        .map(|entry| entry.path())
        .filter(|path| {
            let name = path
                .file_name()
                .and_then(|name| name.to_str())
                .unwrap_or("");
            name.starts_with(&prefix) && name.ends_with(".rlib")
        })
        .max_by_key(|path| {
            std::fs::metadata(path)
                .and_then(|meta| meta.modified())
                .ok()
        })
        .ok_or_else(|| format!("no rlib for {crate_name}"))
}

fn declarations(signatures: &[Signature]) -> String {
    let mut text = String::new();
    for (index, signature) in signatures.iter().enumerate() {
        let mut parameters = String::new();
        for (position, kind) in signature.parameters.iter().enumerate() {
            parameters.push_str(&format!(", argument_{position}: {}", kind.rust_type()));
        }
        let returns = match signature.returns {
            Kind::Unit => String::new(),
            kind => format!(" -> {}", kind.rust_type()),
        };
        text.push_str(&format!(
            "    fn __pl_fn_{index}(context: *mut AotRuntimeContext{parameters}){returns};\n"
        ));
    }
    text
}

fn dispatch(signatures: &[Signature]) -> String {
    let mut text = String::new();
    for (index, signature) in signatures.iter().enumerate() {
        let mut call = format!("unsafe {{ __pl_fn_{index}(context");
        for (position, kind) in signature.parameters.iter().enumerate() {
            call.push_str(&format!(
                ", arguments[{}].parse::<{}>().unwrap()",
                position.saturating_add(5),
                kind.rust_type()
            ));
        }
        call.push_str(") }");
        text.push_str(&match signature.returns {
            Kind::Unit => format!("        {index} => {{ {call}; String::from(\"unit\") }}\n"),
            Kind::Real => format!("        {index} => format!(\"{{:?}}\", {call}),\n"),
            _ => format!("        {index} => format!(\"{{}}\", {call}),\n"),
        });
    }
    text
}

fn class_lines(compiled: &CompiledObject) -> String {
    compiled
        .classes
        .iter()
        .map(|class| {
            let fields: Vec<String> = class.fields.iter().map(u32::to_string).collect();
            format!("{},{}\n", u8::from(class.dense), fields.join(","))
        })
        .collect()
}

fn site_lines(compiled: &CompiledObject) -> String {
    compiled
        .fault_sites
        .iter()
        .map(|site| {
            format!(
                "{},{},{},{},{}\n",
                site.code.as_str(),
                site.range.start_line,
                site.range.start_column,
                site.range.end_line,
                site.range.end_column
            )
        })
        .collect()
}

pub fn build_harness(
    module_text: &str,
    (signatures, patch): (&[Signature], Patch),
) -> Result<Harness, Failure> {
    let compiled = build_object_with(module_text, patch)?;
    let directory = work_directory()?;
    let object = directory.join("program.o");
    std::fs::write(&object, &compiled.bytes).map_err(failure)?;
    std::fs::write(directory.join("sites.txt"), site_lines(&compiled)).map_err(failure)?;
    std::fs::write(directory.join("classes.txt"), class_lines(&compiled)).map_err(failure)?;
    let source = include_str!("harness.template")
        .replace("@@DECLARATIONS@@", &declarations(signatures))
        .replace("@@DISPATCH@@", &dispatch(signatures));
    let source_path = directory.join("harness.rs");
    std::fs::write(&source_path, source).map_err(failure)?;
    link(&directory, &source_path, &object)
}

fn link(directory: &Path, source: &Path, object: &Path) -> Result<Harness, Failure> {
    let dependencies = std::env::current_exe()
        .map_err(failure)?
        .parent()
        .ok_or_else(|| "no deps directory".to_owned())?
        .to_path_buf();
    let executable = directory.join("harness");
    let output = Command::new("rustc")
        .args(["--edition", "2024", "--crate-name", "harness"])
        .arg(source)
        .arg("-o")
        .arg(&executable)
        .arg("-L")
        .arg(format!("dependency={}", dependencies.display()))
        .arg("--extern")
        .arg(extern_argument(&dependencies, "pseudolearn_aot_rt")?)
        .arg("-C")
        .arg(format!("link-arg={}", object.display()))
        .output()
        .map_err(failure)?;
    if !output.status.success() {
        return Err(format!(
            "harness link failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    Ok(Harness {
        executable,
        sites: directory.join("sites.txt"),
    })
}

pub(crate) fn extern_argument(dependencies: &Path, crate_name: &str) -> Result<String, Failure> {
    let path = newest_rlib(dependencies, crate_name)?;
    Ok(format!("{crate_name}={}", path.display()))
}

impl Harness {
    pub fn run(&self, call: &Call) -> Result<Outcome, Failure> {
        let budget = call
            .budget
            .map_or(-1, |units| i64::try_from(units).unwrap_or(-1));
        let output = Command::new(&self.executable)
            .arg(&self.sites)
            .arg(call.function.to_string())
            .arg(call.frames.to_string())
            .arg(budget.to_string())
            .args(&call.arguments)
            .env("PL_INPUT", call.input.replace('\n', "\\n"))
            .env(
                "PL_CELLS",
                call.cells.map_or(String::new(), |cells| cells.to_string()),
            )
            .output()
            .map_err(failure)?;
        if !output.status.success() {
            return Err(format!(
                "harness crashed: {:?} {}",
                output.status,
                String::from_utf8_lossy(&output.stderr)
            ));
        }
        parse_outcome(&String::from_utf8_lossy(&output.stdout))
    }
}

fn decode_hex(text: &str) -> Result<String, Failure> {
    let bytes = text
        .as_bytes()
        .chunks(2)
        .map(|pair| {
            let digits = std::str::from_utf8(pair).map_err(failure)?;
            u8::from_str_radix(digits, 16).map_err(failure)
        })
        .collect::<Result<Vec<u8>, Failure>>()?;
    String::from_utf8(bytes).map_err(failure)
}

fn parse_outcome(line: &str) -> Result<Outcome, Failure> {
    let field = |name: &str| -> String {
        line.trim()
            .split('|')
            .find_map(|piece| piece.strip_prefix(&format!("{name}=")))
            .unwrap_or("")
            .to_owned()
    };
    Ok(Outcome {
        status: field("status").parse().map_err(failure)?,
        value: field("value"),
        code: field("code"),
        range: field("range"),
        depth: field("depth").parse().map_err(failure)?,
        remaining: field("remaining").parse().map_err(failure)?,
        output: decode_hex(&field("output"))?,
    })
}

pub fn shared(
    cell: &'static std::sync::OnceLock<Result<Harness, Failure>>,
    module_text: &str,
    signatures: &[Signature],
) -> Result<&'static Harness, Failure> {
    shared_with(cell, module_text, (signatures, no_patch))
}

pub fn shared_with(
    cell: &'static std::sync::OnceLock<Result<Harness, Failure>>,
    module_text: &str,
    configuration: (&[Signature], Patch),
) -> Result<&'static Harness, Failure> {
    cell.get_or_init(|| build_harness(module_text, configuration))
        .as_ref()
        .map_err(Clone::clone)
}

pub fn expect_value(outcome: &Outcome, value: &str) -> Result<(), Failure> {
    if outcome.status == 0 && outcome.value == value {
        Ok(())
    } else {
        Err(format!("expected value {value}, got {outcome:?}"))
    }
}

pub fn expect_fault(
    outcome: &Outcome,
    status: u32,
    code: &str,
    range: &str,
) -> Result<(), Failure> {
    if outcome.status == status && outcome.code == code && outcome.range == range {
        Ok(())
    } else {
        Err(format!(
            "expected status {status} {code} at {range}, got {outcome:?}"
        ))
    }
}
