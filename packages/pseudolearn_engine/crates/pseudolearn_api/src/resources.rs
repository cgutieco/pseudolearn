use crate::execution_resource::{ExecutionResource, usage};
use crate::{AnalyzeRequest, ApiError, ExecuteRequest, execute_analyze};
use serde_json::{Value, json};
use std::collections::BTreeMap;

#[derive(Default)]
pub struct ApiSession {
    next_identifier: u64,
    nonce: u64,
    pub(crate) locales: BTreeMap<u64, String>,
    pub(crate) resources: BTreeMap<u64, Resource>,
}

pub(crate) enum Resource {
    Document(AnalyzeRequest),
    Analysis {
        document: u64,
        request: AnalyzeRequest,
    },
    Execution {
        analysis: u64,
        execution: Box<ExecutionResource>,
    },
    Editing(Box<pseudolearn_service::EditSession>),
}

static SESSION_COUNTER: std::sync::atomic::AtomicU64 = std::sync::atomic::AtomicU64::new(1);

impl ApiSession {
    pub(crate) fn session_nonce(&mut self) -> u64 {
        if self.nonce == 0 {
            self.nonce = SESSION_COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        }
        self.nonce
    }

    pub fn call(&mut self, operation: &str, arguments: &Value) -> Value {
        let outcome = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
            self.dispatch(operation, arguments)
        }));
        match outcome {
            Ok(Ok(value)) => json!({"value":value}),
            Ok(Err(error)) => failure(&error),
            Err(_) => failure(&ApiError::InternalFault("internalFault".to_owned())),
        }
    }

    fn dispatch(&mut self, operation: &str, arguments: &Value) -> Result<Value, ApiError> {
        match operation {
            "record" => crate::recording::record(self, arguments),
            "step" => crate::stepping::step(self, arguments),
            "fault_stages" => Ok(crate::fault_injection::stages()),
            "inject_fault" => crate::fault_injection::inject(arguments),
            "encode_events" => crate::event_codec::encode(arguments),
            "decode_events" => crate::event_codec::decode(arguments),
            "negotiate" => crate::negotiation::negotiate(arguments),
            "create_document" => self.create_document(arguments),
            "create_analysis" => self.create_analysis(arguments),
            "analyze_project" => crate::project_operations::analyze(arguments),
            "execute_project" => crate::project_operations::execute(arguments),
            "resolve_manifest" => crate::manifest_operations::resolve(arguments),
            "build_lock" => crate::lock_operations::build(arguments),
            "resolve_lock" => crate::lock_operations::resolve(arguments),
            "document" => self.document(arguments),
            "analysis" => self.analysis(arguments),
            "start" | "start_execution" => self.start(arguments),
            "program_view" | "query_node" => self.program_view_operation(operation, arguments),
            "query_page" => self.query_page_operation(arguments),
            "release" => self.release(identifier(arguments)?),
            _ => match self.service_operation(operation, arguments) {
                Some(outcome) => outcome,
                None => self.execution_operation(operation, arguments),
            },
        }
    }

    pub(crate) fn insert(&mut self, resource: Resource) -> Result<u64, ApiError> {
        let identifier = self
            .next_identifier
            .checked_add(1)
            .ok_or_else(|| usage("resource identifiers exhausted"))?;
        self.next_identifier = identifier;
        self.resources.insert(identifier, resource);
        Ok(identifier)
    }

    fn create_document(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let request = parse_analysis(arguments)?;
        let previous = arguments
            .get("previous_document")
            .map(|value| {
                value
                    .as_u64()
                    .filter(|identifier| {
                        matches!(self.resources.get(identifier), Some(Resource::Document(_)))
                    })
                    .ok_or_else(|| usage("invalid previous document"))
            })
            .transpose()?;
        let resource = self.insert(Resource::Document(request))?;
        if let Some(previous) = previous {
            self.release(previous)?;
        }
        Ok(json!({"resource":resource}))
    }

    fn create_analysis(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let (document, request) =
            if let Some(document) = arguments.get("document").and_then(Value::as_u64) {
                match self.resources.get(&document) {
                    Some(Resource::Document(request)) => (document, request.clone()),
                    _ => return Err(usage("invalid document")),
                }
            } else {
                let request = parse_analysis(arguments)?;
                (self.insert(Resource::Document(request.clone()))?, request)
            };
        let analysis = self.insert(Resource::Analysis { document, request })?;
        self.remember_locale(analysis, arguments);
        Ok(json!({"resource":analysis,"document":document}))
    }

    fn document(&self, arguments: &Value) -> Result<Value, ApiError> {
        match self.resources.get(&identifier(arguments)?) {
            Some(Resource::Document(request)) => {
                serde_json::to_value(request).map_err(serialization)
            }
            _ => Err(usage("invalid document")),
        }
    }

    fn analysis(&self, arguments: &Value) -> Result<Value, ApiError> {
        let analysis = identifier(arguments)?;
        match self.resources.get(&analysis) {
            Some(Resource::Analysis { request, .. }) => {
                let mut report =
                    serde_json::to_value(execute_analyze(request)).map_err(serialization)?;
                if let Some(locale) = self.locale_of(analysis) {
                    crate::locale_operations::relocalize(&mut report, locale);
                }
                Ok(report)
            }
            _ => Err(usage("invalid analysis")),
        }
    }

    fn start(&mut self, arguments: &Value) -> Result<Value, ApiError> {
        let analysis = arguments
            .get("analysis")
            .and_then(Value::as_u64)
            .or_else(|| arguments.get("resource").and_then(Value::as_u64))
            .ok_or_else(|| usage("missing analysis"))?;
        let Some(Resource::Analysis { document, request }) = self.resources.get(&analysis) else {
            return Err(usage("invalid analysis"));
        };
        let view = crate::program_view::ProgramView::build(
            request,
            crate::program_view_operations::revision_of(*document),
        )?;
        let mut execution_request: ExecuteRequest =
            serde_json::from_value(arguments.clone()).map_err(serialization)?;
        execution_request.program = request.program.clone();
        execution_request.profile = request.profile.clone();
        execution_request.strictness = request.strictness.clone();
        execution_request.source = request.source;
        let mut execution = Box::new(ExecutionResource::start(&execution_request)?);
        execution.attach_view(view);
        if let Some(locale) = self.locale_of(analysis) {
            execution.use_locale(locale.to_owned());
        }
        Ok(json!({"resource":self.insert(Resource::Execution {analysis,execution})?}))
    }

    fn execution_operation(
        &mut self,
        operation: &str,
        arguments: &Value,
    ) -> Result<Value, ApiError> {
        let Some(Resource::Execution { execution, .. }) =
            self.resources.get_mut(&identifier(arguments)?)
        else {
            return Err(usage("invalid execution"));
        };
        match operation {
            "advance" => execution.advance(count(arguments, "batch_size", Some(1))?),
            "input" | "effect_result" => handle_execution_feed(execution, operation, arguments),
            "cancel" => {
                execution.cancel();
                Ok(Value::Null)
            }
            "seek" | "query_state" => execution.state(count(arguments, "event", None)?),
            "query_frame" | "query_variables" | "query_array_slice" | "query_object" => {
                execution.query(count(arguments, "event", None)?, operation, arguments)
            }
            "horizon" => Ok(execution.horizon()),
            "initial_state" => execution.initial_state(),
            "set_retention" => {
                execution.configure_retention(count(arguments, "events", None)?)?;
                Ok(Value::Null)
            }
            _ => Err(usage("unknown operation")),
        }
    }
}

fn handle_execution_feed(
    execution: &mut ExecutionResource,
    operation: &str,
    arguments: &Value,
) -> Result<Value, ApiError> {
    match operation {
        "input" => {
            let text = arguments
                .get("text")
                .and_then(Value::as_str)
                .ok_or_else(|| usage("missing input text"))?
                .to_owned();
            execution.input(text)?;
            Ok(Value::Null)
        }
        "effect_result" => {
            let result = arguments.get("result").cloned().unwrap_or(Value::Null);
            execution.effect_result(result)?;
            Ok(Value::Null)
        }
        _ => Err(usage("unknown operation")),
    }
}

impl ApiSession {
    fn release(&mut self, identifier: u64) -> Result<Value, ApiError> {
        if self.resources.remove(&identifier).is_none() {
            return Err(usage("invalid resource"));
        }
        let descendants: Vec<_> = self
            .resources
            .iter()
            .filter_map(|(child, resource)| match resource {
                Resource::Analysis { document, .. } if document == &identifier => Some(*child),
                Resource::Execution { analysis, .. } if analysis == &identifier => Some(*child),
                _ => None,
            })
            .collect();
        for descendant in descendants {
            self.release(descendant)?;
        }
        Ok(Value::Null)
    }
}

pub(crate) fn parse_analysis(arguments: &Value) -> Result<AnalyzeRequest, ApiError> {
    let request: ExecuteRequest =
        serde_json::from_value(arguments.clone()).map_err(serialization)?;
    if request.source.is_some_and(|source| !source.is_valid()) {
        return Err(usage("invalid source identity"));
    }
    Ok(AnalyzeRequest {
        program: request.program,
        profile: request.profile,
        strictness: request.strictness,
        source: request.source,
    })
}

pub(crate) fn identifier(arguments: &Value) -> Result<u64, ApiError> {
    arguments
        .get("resource")
        .and_then(Value::as_u64)
        .ok_or_else(|| usage("missing resource"))
}

fn serialization(error: serde_json::Error) -> ApiError {
    ApiError::InvalidProtocol(error.to_string())
}

fn failure(error: &ApiError) -> Value {
    let family = match error {
        ApiError::InternalFault(_) => "internal",
        ApiError::UnsupportedVersion(_) => "version",
        _ => "usage",
    };
    json!({"failure":{"family":family,"detail":error.to_string()}})
}

fn count(arguments: &Value, name: &str, default: Option<usize>) -> Result<usize, ApiError> {
    match arguments.get(name) {
        Some(value) => value
            .as_u64()
            .and_then(|count| usize::try_from(count).ok())
            .ok_or_else(|| usage("invalid count")),
        None => default.ok_or_else(|| usage("missing count")),
    }
}
