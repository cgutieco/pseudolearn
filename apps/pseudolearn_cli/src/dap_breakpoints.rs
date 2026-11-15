use crate::dap_protocol::{argument, natural};
use crate::dap_session::DapSession;
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn breakpoints(&mut self, request: &Value) -> Result<Value, String> {
        self.execution()?;
        let source = self.sources.identifier(argument(request, "source"))?;
        let requested = argument(request, "breakpoints")
            .as_array()
            .cloned()
            .unwrap_or_default();
        if requested.len() > 4096 {
            return Err("breakpoint limit exceeded".to_owned());
        }
        let modified = argument(request, "sourceModified")
            .as_bool()
            .unwrap_or(false);
        let mut accepted = Vec::new();
        let mut rejected = Vec::new();
        for location in &requested {
            let point = self.breakpoint_location(source, location, modified);
            match point {
                Ok(point) => {
                    accepted.push(point);
                    rejected.push(None);
                }
                Err(reason) => rejected.push(Some(reason)),
            }
        }
        self.breakpoints.insert(source, accepted);
        self.configure_breakpoints(source, rejected)
    }

    fn configure_breakpoints(
        &mut self,
        source: u32,
        rejected: Vec<Option<String>>,
    ) -> Result<Value, String> {
        let all: Vec<Value> = self.breakpoints.values().flatten().cloned().collect();
        let configured = self.call(
            "debug_configure",
            &json!({"resource":self.execution()?,
            "breakpoints":all,"stop_on_entry":self.stop_on_entry}),
        )?;
        let resolved = configured
            .get("breakpoints")
            .and_then(Value::as_array)
            .map_or(&[][..], Vec::as_slice)
            .iter()
            .filter(|point| {
                point.get("source_id").and_then(Value::as_u64) == Some(u64::from(source))
            })
            .cloned()
            .collect::<Vec<_>>();
        let mut iterator = resolved.into_iter();
        let breakpoints: Vec<Value> = rejected
            .into_iter()
            .map(|reason| match reason {
                Some(reason) => json!({"verified":false,"message":reason}),
                None => self.present_breakpoint(source, iterator.next().unwrap_or(Value::Null)),
            })
            .collect();
        Ok(json!({"breakpoints":breakpoints}))
    }

    fn breakpoint_location(
        &self,
        source: u32,
        location: &Value,
        modified: bool,
    ) -> Result<Value, String> {
        if modified {
            return Err("source differs from the execution snapshot".to_owned());
        }
        if ["condition", "hitCondition", "logMessage"]
            .iter()
            .any(|field| location.get(field).is_some())
        {
            return Err("conditional and log breakpoints are unavailable".to_owned());
        }
        let line = location
            .get("line")
            .and_then(Value::as_u64)
            .ok_or("missing breakpoint line")?;
        let column = natural(
            location.get("column").unwrap_or(&Value::Null),
            u64::from(self.sources.columns_start_at_one),
        );
        let (line, column) = self.sources.core_location(source, line, column)?;
        let mut resolved = json!({"source_id":source,"line":line});
        if location.get("column").is_some() {
            resolved["column"] = json!(column);
        }
        Ok(resolved)
    }

    fn present_breakpoint(&self, source: u32, mut point: Value) -> Value {
        if point.is_null() {
            return json!({"verified":false,"message":"no executable statement at location"});
        }
        let line = point.get("line").and_then(Value::as_u64).unwrap_or(1);
        let column = point.get("column").and_then(Value::as_u64).unwrap_or(1);
        let (line, column) = self.sources.location(source, line, column);
        point["line"] = json!(line);
        point["column"] = json!(column);
        point["source"] = self.sources.describe(source);
        point
    }
}
