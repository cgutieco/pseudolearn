use jni::EnvUnowned;
use jni::errors::ThrowRuntimeExAndDefault;
use jni::jni_mangle;
use jni::objects::{JClass, JObject};

#[jni_mangle("com.pseudolearn.app.PlatformCertificateVerifier")]
pub fn initialize<'caller>(
    mut unowned_environment: EnvUnowned<'caller>,
    _verifier_class: JClass<'caller>,
    application_context: JObject<'caller>,
) {
    unowned_environment
        .with_env(|environment| {
            rustls_platform_verifier::android::init_with_env(environment, application_context)
        })
        .resolve::<ThrowRuntimeExAndDefault>();
}
