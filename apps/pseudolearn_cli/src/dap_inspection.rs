use crate::dap_protocol::argument;
use crate::dap_session::{DapSession, Reference};
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn inspect(&mut self, request: &Value) -> Result<Value, String> {
        let command = request.get("command").and_then(Value::as_str).unwrap_or("");
        self.execution()?;
        if command == "source" {
            return self.source(request);
        }
        if command == "loadedSources" {
            let sources = self
                .sources
                .snapshots
                .keys()
                .map(|identifier| self.sources.describe(*identifier))
                .collect::<Vec<_>>();
            return Ok(json!({"sources":sources}));
        }
        if self.running {
            return Err("inspection requires a paused execution".to_owned());
        }
        match command {
            "threads" => self.list_threads(),
            "stackTrace" => self.stack(request),
            "scopes" => self.scopes(request),
            "variables" => self.variables(request),
            "evaluate" => self.evaluate(request),
            _ => Err("unsupported inspection".to_owned()),
        }
    }

    fn source(&self, request: &Value) -> Result<Value, String> {
        let reference = argument(request, "sourceReference");
        let source = if reference.is_null() {
            argument(request, "source").clone()
        } else {
            json!({"sourceReference":reference})
        };
        let identifier = self.sources.identifier(&source)?;
        let snapshot = self
            .sources
            .snapshots
            .get(&identifier)
            .ok_or("unknown source")?;
        Ok(json!({"content":snapshot.text,"mimeType":"text/x-pseudolearn"}))
    }

    fn list_threads(&mut self) -> Result<Value, String> {
        self.refresh()?;
        let tasks = self
            .state
            .get("threads")
            .and_then(Value::as_array)
            .cloned()
            .unwrap_or_default();
        let mut threads = Vec::new();
        for task in tasks {
            let identifier = task
                .get("id")
                .and_then(Value::as_u64)
                .ok_or("invalid core task identity")?;
            let assigned = self.thread_id(identifier)?;
            threads.push(json!({"id":assigned,"name":task.get("name").and_then(Value::as_str).unwrap_or("PseudoLearn task")}));
        }
        Ok(json!({"threads":threads}))
    }

    fn stack(&mut self, request: &Value) -> Result<Value, String> {
        let task = self.selected_task(argument(request, "threadId"))?;
        let start = argument(request, "startFrame").as_u64().unwrap_or(0);
        let count = argument(request, "levels")
            .as_u64()
            .filter(|count| *count != 0)
            .unwrap_or(4096);
        if count > 4096 {
            return Err("stack page exceeds 4096 frames".to_owned());
        }
        let state = self.call(
            "debug_state",
            &json!({"resource":self.execution()?,"task_id":task,
            "start_frame":start,"frame_count":count}),
        )?;
        let frames = state
            .get("frames")
            .and_then(Value::as_array)
            .ok_or("missing core frames")?;
        let mut projected = Vec::new();
        for frame in frames {
            projected.push(self.stack_frame(task, frame)?);
        }
        Ok(json!({"stackFrames":projected,"totalFrames":state.get("total_frames")}))
    }

    fn stack_frame(&mut self, task: u64, frame: &Value) -> Result<Value, String> {
        let position = frame
            .get("id")
            .and_then(Value::as_u64)
            .ok_or("missing frame identity")?;
        let identifier = self.reference(Reference::Frame {
            task,
            position,
            generation: self.generation(),
        })?;
        let source = frame
            .get("source_id")
            .and_then(Value::as_u64)
            .and_then(|source| u32::try_from(source).ok())
            .ok_or("missing frame source")?;
        let (line, column) = self.sources.location(
            source,
            frame.get("line").and_then(Value::as_u64).unwrap_or(1),
            frame.get("column").and_then(Value::as_u64).unwrap_or(1),
        );
        Ok(
            json!({"id":identifier,"name":frame.get("name"),"source":self.sources.describe(source),
            "line":line,"column":column,"presentationHint":"normal"}),
        )
    }

    fn scopes(&mut self, request: &Value) -> Result<Value, String> {
        let (task, target) = self.frame(argument(request, "frameId"))?;
        let reference = self.reference(Reference::Variables {
            task,
            target,
            query: "frame_variables".to_owned(),
            generation: self.generation(),
        })?;
        Ok(
            json!({"scopes":[{"name":"Locals","presentationHint":"locals","variablesReference":reference,"expensive":false}]}),
        )
    }
}
