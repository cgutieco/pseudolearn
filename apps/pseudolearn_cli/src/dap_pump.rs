use crate::dap_protocol::event;
use crate::dap_session::DapSession;
use serde_json::{Value, json};

impl DapSession {
    pub(crate) fn pump(&mut self) -> Vec<Value> {
        self.pending.clear();
        if let Err(error) = self.pump_batch() {
            self.pending.push(event(
                "output",
                json!({"category":"stderr","output":format!("{error}\n")}),
            ));
            self.terminate();
        }
        std::mem::take(&mut self.pending)
    }

    fn pump_batch(&mut self) -> Result<(), String> {
        if self.finished || self.resource.is_none() {
            return Ok(());
        }
        let resource = self.execution()?;
        self.collect_effect_replies(&resource)?;
        if !self.running || self.input_token.is_some() {
            return Ok(());
        }
        if self
            .effects
            .as_ref()
            .is_some_and(crate::dap_effects::EffectHost::is_pending)
        {
            return Ok(());
        }
        let batch = self.call("advance", &json!({"resource":resource,"batch_size":64}))?;
        self.present_output(&batch);
        self.present_batch(&batch)
    }

    fn collect_effect_replies(&mut self, resource: &Value) -> Result<(), String> {
        if let Some(host) = self.effects.as_mut() {
            let replies = host.completed();
            for (effect, reply) in replies {
                self.call(
                    "effect_result",
                    &json!({"resource":resource,
                    "effect_seq":effect.get("effect_seq"),"result":reply}),
                )?;
            }
        }
        Ok(())
    }

    fn present_batch(&mut self, batch: &Value) -> Result<(), String> {
        if let Some(state) = batch.get("debug") {
            self.state = state.clone();
            self.update_sources();
        } else {
            self.refresh()?;
        }
        let kind = batch
            .pointer("/termination/kind")
            .and_then(Value::as_str)
            .unwrap_or("failed");
        if self.state.get("stopped").and_then(Value::as_bool) == Some(true) {
            self.running = false;
            let reason = self
                .state
                .get("reason")
                .and_then(Value::as_str)
                .unwrap_or("step")
                .to_owned();
            self.stopped(&reason);
            return Ok(());
        }
        match kind {
            "running" => Ok(()),
            "awaiting_input" => self.await_input(),
            "awaiting_effect" => self.dispatch_effects(batch),
            _ => {
                self.pending.push(event(
                    "exited",
                    json!({"exitCode":i32::from(kind != "completed")}),
                ));
                self.terminate();
                Ok(())
            }
        }
    }

    fn present_output(&mut self, batch: &Value) {
        let output = batch.get("output").and_then(Value::as_str).unwrap_or("");
        let fresh = output.get(self.output_bytes..).unwrap_or("");
        if !fresh.is_empty() {
            self.pending
                .push(event("output", json!({"category":"stdout","output":fresh})));
        }
        self.output_bytes = self.output_bytes.max(output.len());
    }

    fn await_input(&mut self) -> Result<(), String> {
        self.input_generation = self
            .input_generation
            .checked_add(1)
            .ok_or("input token space exhausted")?;
        let token = format!(
            "{}:{}:{}",
            self.execution()?,
            self.generation(),
            self.input_generation
        );
        self.input_token = Some(token.clone());
        self.pending
            .push(event("pseudolearn/awaitingInput", json!({"token":token})));
        Ok(())
    }

    fn dispatch_effects(&mut self, batch: &Value) -> Result<(), String> {
        let effects = batch
            .get("pending_effects")
            .and_then(Value::as_array)
            .cloned()
            .unwrap_or_else(|| batch.get("pending_effect").cloned().into_iter().collect());
        for effect in effects {
            let host = self
                .effects
                .as_mut()
                .ok_or("no physical effect provider is granted")?;
            if host.submit(effect.clone())?
                && effect.get("operation").and_then(Value::as_str) == Some("console_write")
            {
                let text = effect
                    .pointer("/arguments/0/value")
                    .and_then(Value::as_str)
                    .unwrap_or("");
                self.pending
                    .push(event("output", json!({"category":"stdout","output":text})));
            }
        }
        Ok(())
    }
}
