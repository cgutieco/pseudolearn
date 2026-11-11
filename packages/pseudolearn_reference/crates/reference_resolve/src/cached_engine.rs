use reference_model::{
    CodeEngine, ExecutionReport, ExecutionRequest, Profile, ProgramView, RawToken,
};
use std::cell::RefCell;
use std::collections::BTreeMap;

type Key = (String, Profile);
type ExecutionKey = (
    String,
    Profile,
    Vec<String>,
    Option<String>,
    (bool, Option<u64>, Option<usize>),
);

pub struct CachedEngine<Engine: CodeEngine> {
    inner: Engine,
    tokens: RefCell<BTreeMap<Key, Vec<RawToken>>>,
    translations: RefCell<BTreeMap<Key, Result<String, String>>>,
    executions: RefCell<BTreeMap<ExecutionKey, ExecutionReport>>,
}

impl<Engine: CodeEngine> CachedEngine<Engine> {
    pub fn new(inner: Engine) -> Self {
        Self {
            inner,
            tokens: RefCell::default(),
            translations: RefCell::default(),
            executions: RefCell::default(),
        }
    }
}

impl<Engine: CodeEngine> CodeEngine for CachedEngine<Engine> {
    fn tokenize(&self, code: &str, profile: Profile) -> Vec<RawToken> {
        let key = (code.to_owned(), profile);
        if let Some(cached) = self.tokens.borrow().get(&key) {
            return cached.clone();
        }
        let computed = self.inner.tokenize(code, profile);
        self.tokens.borrow_mut().insert(key, computed.clone());
        computed
    }

    fn translate(&self, code: &str, target: Profile) -> Result<String, String> {
        let key = (code.to_owned(), target);
        if let Some(cached) = self.translations.borrow().get(&key) {
            return cached.clone();
        }
        let computed = self.inner.translate(code, target);
        self.translations.borrow_mut().insert(key, computed.clone());
        computed
    }

    fn execute(&self, request: &ExecutionRequest) -> ExecutionReport {
        let key = (
            request.code.clone(),
            request.profile,
            request.inputs.clone(),
            request.host.clone(),
            (request.trace, request.statement_limit, request.depth_limit),
        );
        if let Some(cached) = self.executions.borrow().get(&key) {
            return cached.clone();
        }
        let computed = self.inner.execute(request);
        self.executions.borrow_mut().insert(key, computed.clone());
        computed
    }

    fn intermediate(&self, code: &str, profile: Profile) -> Result<String, String> {
        self.inner.intermediate(code, profile)
    }

    fn program_view(&self, code: &str, profile: Profile) -> Result<ProgramView, String> {
        self.inner.program_view(code, profile)
    }

    fn fingerprint(&self) -> String {
        self.inner.fingerprint()
    }
}
