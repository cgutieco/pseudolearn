use pseudolearn_api::ApiSession;
use serde_json::Value;
use wasm_bindgen::{JsValue, prelude::wasm_bindgen};

mod projection;

#[cfg(test)]
mod projection_tests;

#[wasm_bindgen]
#[derive(Default)]
pub struct WasmSession {
    session: ApiSession,
}

#[wasm_bindgen]
impl WasmSession {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Self {
        Self::default()
    }

    pub fn call(&mut self, operation: &str, arguments_json: &str) -> Result<String, JsValue> {
        let arguments: Value = serde_json::from_str(arguments_json)
            .map_err(|_| JsValue::from_str("Invalid JSON arguments"))?;
        let response = self.session.call(operation, &arguments);
        serde_json::to_string(&response)
            .map_err(|_| JsValue::from_str("Failed to encode API response"))
    }

    #[wasm_bindgen(js_name = callProjected)]
    pub fn call_projected(
        &mut self,
        operation: &str,
        arguments_json: &str,
    ) -> Result<String, JsValue> {
        let arguments: Value = serde_json::from_str(arguments_json)
            .map_err(|_| JsValue::from_str("Invalid JSON arguments"))?;
        let response = self.session.call(operation, &arguments);
        let response_json = serde_json::to_string(&response)
            .map_err(|_| JsValue::from_str("Failed to encode API response"))?;
        let projection_json = serde_json::to_string(&projection::project(response))
            .map_err(|_| JsValue::from_str("Failed to encode projection"))?;
        serde_json::to_string(
            &serde_json::json!({"response_json":response_json,"projection_json":projection_json}),
        )
        .map_err(|_| JsValue::from_str("Failed to encode projection envelope"))
    }
}
