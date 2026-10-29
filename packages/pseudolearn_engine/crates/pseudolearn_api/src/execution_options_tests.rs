use crate::{ExecuteRequest, ExecutionLimits};

#[test]
fn maps_the_configured_json_depth_into_vm_options() {
    let defaults = crate::execution::options(&ExecuteRequest::default());
    let configured = crate::execution::options(&ExecuteRequest {
        limits: ExecutionLimits {
            max_json_depth: Some(1),
            ..ExecutionLimits::default()
        },
        ..ExecuteRequest::default()
    });
    assert_eq!(defaults.max_json_depth, 64);
    assert_eq!(configured.max_json_depth, 1);
}
