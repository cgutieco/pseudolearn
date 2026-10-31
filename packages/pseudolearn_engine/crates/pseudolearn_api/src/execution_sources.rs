use crate::execution_resource::usage;
use crate::program_view::ProgramView;
use crate::{AnalyzeRequest, ApiError, ExecuteRequest};
use pseudolearn_vm::TraceEvent;
use serde_json::{Value, json};
use std::collections::BTreeMap;

#[derive(Default)]
pub(crate) struct ExecutionSources {
    pub(crate) views: BTreeMap<u32, ProgramView>,
    pub(crate) texts: BTreeMap<u32, (String, String)>,
}

impl ExecutionSources {
    pub(crate) fn single(request: &ExecuteRequest) -> Self {
        let source = request.source.map_or(0, |source| source.source_id);
        Self {
            views: BTreeMap::new(),
            texts: BTreeMap::from([(source, (String::new(), request.program.clone()))]),
        }
    }

    pub(crate) fn project(
        request: &crate::project_resource::ProjectRequest,
    ) -> Result<Self, ApiError> {
        let mut sources = Self::default();
        for file in &request.input.files {
            let profile = pseudolearn_project::logical_path_key(&file.path)
                .and_then(|path| request.file_profiles.get(&path))
                .copied()
                .unwrap_or(request.profile);
            let analysis = AnalyzeRequest {
                program: file.text.clone(),
                profile: profile.as_str().to_owned(),
                strictness: if request.strict { "strict" } else { "flexible" }.to_owned(),
                source: Some(crate::ApiSourceIdentity {
                    project_id: request.input.project_id,
                    revision_id: request.input.revision_id,
                    source_id: file.source_id,
                }),
            };
            let revision = format!(
                "p{}.r{}.f{}",
                request.input.project_id, request.input.revision_id, file.source_id
            );
            sources.views.insert(
                file.source_id,
                ProgramView::build_project(&analysis, revision)?,
            );
            sources
                .texts
                .insert(file.source_id, (file.path.clone(), file.text.clone()));
        }
        Ok(sources)
    }

    pub(crate) fn event(&self, event: &TraceEvent) -> Value {
        let source = event.span.map_or(0, |span| span.source_id.value());
        crate::execution_wire::event_with_source(event, self.views.get(&source))
    }

    pub(crate) fn snapshot(&self) -> Value {
        json!(
            self.texts
                .iter()
                .map(|(identifier, (path, text))| {
                    json!({"source_id":identifier,"path":path,"text":text,
                "revision":self.views.get(identifier).map(ProgramView::revision)})
                })
                .collect::<Vec<_>>()
        )
    }

    pub(crate) fn breakpoint(
        &self,
        program: &pseudolearn_vm::LoadedProgram,
        arguments: &Value,
    ) -> Result<Value, ApiError> {
        let source = arguments
            .get("source_id")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        let line = arguments
            .get("line")
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing breakpoint line"))?;
        let column = arguments.get("column").and_then(Value::as_u64);
        let modified = arguments
            .get("sourceModified")
            .and_then(Value::as_bool)
            .unwrap_or(false);
        let resolved = u32::try_from(source)
            .ok()
            .zip(u32::try_from(line).ok())
            .and_then(|(source, line)| {
                let column = column.map(u32::try_from).transpose().ok()?;
                self.texts.contains_key(&source).then_some(())?;
                program.statement_location(source, line, column)
            })
            .filter(|_| !modified);
        Ok(match resolved {
            Some(span) => {
                json!({"source_id":source,"line":span.start_line,"column":span.start_column,"verified":true})
            }
            None => json!({"source_id":source,"line":line,"column":column,"verified":false,
                "message":"No executable statement at the requested location"}),
        })
    }
}
