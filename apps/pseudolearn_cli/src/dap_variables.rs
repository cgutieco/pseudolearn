use crate::dap_protocol::argument;
use crate::dap_session::{DapSession, Reference};
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn variables(&mut self, request: &Value) -> Result<Value, String> {
        let (task, target, query) =
            self.variable_reference(argument(request, "variablesReference"))?;
        let start = argument(request, "start").as_u64().unwrap_or(0);
        let count = argument(request, "count")
            .as_u64()
            .filter(|count| *count != 0)
            .unwrap_or(4096);
        if count > 4096 {
            return Err("variable page exceeds 4096 values".to_owned());
        }
        let page = self.call(
            "query_page",
            &json!({"resource":self.execution()?,"event":self.state.get("event"),
            "task_id":task,"target":target,"query":query,"page_size":count,"offset":start}),
        )?;
        let filter = argument(request, "filter").as_str();
        self.present_variables(task, start, (&page, filter))
    }

    fn present_variables(
        &mut self,
        task: u64,
        start: u64,
        page_and_filter: (&Value, Option<&str>),
    ) -> Result<Value, String> {
        let (page, filter) = page_and_filter;
        let indexed = page
            .get("indexed")
            .and_then(Value::as_bool)
            .unwrap_or(false);
        if filter.is_some_and(|filter| {
            (filter == "named" && indexed) || (filter == "indexed" && !indexed)
        }) {
            return Ok(json!({"variables":[]}));
        }
        let elements = page
            .get("elements")
            .and_then(Value::as_array)
            .ok_or("missing page elements")?;
        let mut variables = Vec::new();
        for (index, element) in elements.iter().enumerate() {
            let name = element.get("name").and_then(Value::as_str).map_or_else(
                || {
                    start
                        .saturating_add(u64::try_from(index).unwrap_or(u64::MAX))
                        .to_string()
                },
                str::to_owned,
            );
            let value = element.get("value").unwrap_or(element);
            variables.push(self.variable(task, &name, value)?);
        }
        Ok(json!({"variables":variables}))
    }

    fn variable(&mut self, task: u64, name: &str, value: &Value) -> Result<Value, String> {
        let ordinal = value.get("ref").and_then(Value::as_u64);
        let reference = match ordinal {
            Some(target) => self.reference(Reference::Variables {
                task,
                target,
                query: "object_fields".to_owned(),
                generation: self.generation(),
            })?,
            None => 0,
        };
        let display = value.get("valor").and_then(Value::as_str).map_or_else(
            || {
                if value.get("nulo").and_then(Value::as_bool) == Some(true) {
                    "nulo".to_owned()
                } else if value.get("sin_valor").and_then(Value::as_bool) == Some(true) {
                    "sin_valor".to_owned()
                } else if let Some(ordinal) = ordinal {
                    format!("referencia({ordinal})")
                } else {
                    value.to_string()
                }
            },
            str::to_owned,
        );
        Ok(
            json!({"name":name,"value":display,"type":value.get("tipo"),"variablesReference":reference}),
        )
    }

    pub(crate) fn evaluate(&mut self, request: &Value) -> Result<Value, String> {
        let context = argument(request, "context").as_str().unwrap_or("watch");
        if !["hover", "watch", "repl"].contains(&context) {
            return Err("unsupported evaluate context".to_owned());
        }
        let (task, frame) = self.frame(argument(request, "frameId"))?;
        let expression = argument(request, "expression")
            .as_str()
            .ok_or("missing inspection expression")?;
        let value = self.call(
            "inspect_expression",
            &json!({"resource":self.execution()?,"event":self.state.get("event"),
            "task_id":task,"frame":frame,"expression":expression}),
        )?;
        let reference = match value.get("reference").and_then(Value::as_u64) {
            Some(target) => self.reference(Reference::Variables {
                task,
                target,
                query: "object_fields".to_owned(),
                generation: self.generation(),
            })?,
            None => 0,
        };
        Ok(
            json!({"result":value.get("value"),"type":value.get("type"),"variablesReference":reference}),
        )
    }
}
