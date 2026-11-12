export type BrowserOperationSupport = "value" | "platform_error";

const CAPABILITY_REQUESTS = [
  "request_console", "request_arguments", "request_directory", "request_clock",
  "request_timer", "request_network", "request_environment", "network_restrict",
];

const VALUE_OPERATIONS = [
  "console_write", "console_write_error", "console_set_exit_code", "arguments_values",
  "clock_now", "clock_local_now", "timer_wait", "network_send", "network_close",
  "directory_derive", "directory_close", "directory_exists", "directory_is_directory",
  "directory_list", "directory_delete", "directory_rename", "directory_create",
  "file_open", "file_close", "file_read_bytes", "file_read_text", "file_write_bytes",
  "file_write_text", "file_append_bytes", "file_append_text",
];

export const BROWSER_OPERATION_SUPPORT: Readonly<Record<string, BrowserOperationSupport>> = Object.freeze({
  ...Object.fromEntries(CAPABILITY_REQUESTS.map((name) => [name, "value" as const])),
  ...Object.fromEntries(VALUE_OPERATIONS.map((name) => [name, "value" as const])),
  environment_get: "platform_error",
});
