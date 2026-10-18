use crate::class_layout::ClassDescriptor;
use crate::config::{AotLimits, BooleanWords};
use crate::fault::{FaultSite, SourceRange};
use crate::metadata::{ExecutableMetadata, ExecutableSettings};
use pseudolearn_diagnostics::DiagnosticCode;

const MAGIC: &[u8; 4] = b"PLM2";

#[derive(Default)]
struct Writer {
    bytes: Vec<u8>,
}

impl Writer {
    fn unsigned32(&mut self, value: u32) {
        self.bytes.extend_from_slice(&value.to_le_bytes());
    }

    fn unsigned64(&mut self, value: u64) {
        self.bytes.extend_from_slice(&value.to_le_bytes());
    }

    fn signed64(&mut self, value: i64) {
        self.bytes.extend_from_slice(&value.to_le_bytes());
    }

    fn count(&mut self, value: usize) {
        self.unsigned32(u32::try_from(value).unwrap_or(u32::MAX));
    }

    fn text(&mut self, value: &str) {
        self.count(value.len());
        self.bytes.extend_from_slice(value.as_bytes());
    }
}

pub fn encode_metadata(metadata: &ExecutableMetadata) -> Vec<u8> {
    let mut writer = Writer::default();
    writer.bytes.extend_from_slice(MAGIC);
    write_settings(&mut writer, &metadata.settings);
    writer.count(metadata.sites.len());
    for site in &metadata.sites {
        write_site(&mut writer, site);
    }
    writer.count(metadata.classes.len());
    for class in &metadata.classes {
        write_class(&mut writer, class);
    }
    writer.bytes
}

fn write_settings(writer: &mut Writer, settings: &ExecutableSettings) {
    writer.text(&settings.source_name);
    writer.text(&settings.locale);
    writer.signed64(settings.seed);
    writer.unsigned32(u32::from(settings.forced_collection));
    writer.unsigned32(settings.limits.frames);
    writer.unsigned64(settings.limits.instruction_units.unwrap_or(0));
    writer.unsigned32(u32::from(settings.limits.instruction_units.is_some()));
    writer.unsigned64(settings.limits.cells);
    writer.unsigned32(settings.limits.root_capacity);
    writer.text(&settings.boolean_words.truth);
    writer.text(&settings.boolean_words.falsity);
    writer.text(&settings.error_template);
    writer.text(&settings.warning_template);
    writer.text(&settings.information_template);
    writer.text(&settings.exhausted_template);
}

fn write_site(writer: &mut Writer, site: &FaultSite) {
    writer.text(site.code.as_str());
    writer.text(&site.lexeme);
    writer.unsigned32(site.range.start_line);
    writer.unsigned32(site.range.start_column);
    writer.unsigned32(site.range.end_line);
    writer.unsigned32(site.range.end_column);
}

fn write_class(writer: &mut Writer, class: &ClassDescriptor) {
    writer.unsigned32(u32::from(class.dense));
    writer.count(class.fields.len());
    for field in &class.fields {
        writer.unsigned32(*field);
    }
}

struct Reader<'bytes> {
    remaining: &'bytes [u8],
}

impl<'bytes> Reader<'bytes> {
    fn take(&mut self, count: usize) -> Option<&'bytes [u8]> {
        let (head, tail) = self.remaining.split_at_checked(count)?;
        self.remaining = tail;
        Some(head)
    }

    fn unsigned32(&mut self) -> Option<u32> {
        Some(u32::from_le_bytes(self.take(4)?.try_into().ok()?))
    }

    fn unsigned64(&mut self) -> Option<u64> {
        Some(u64::from_le_bytes(self.take(8)?.try_into().ok()?))
    }

    fn signed64(&mut self) -> Option<i64> {
        Some(i64::from_le_bytes(self.take(8)?.try_into().ok()?))
    }

    fn count(&mut self) -> Option<usize> {
        usize::try_from(self.unsigned32()?).ok()
    }

    fn text(&mut self) -> Option<String> {
        let count = self.count()?;
        String::from_utf8(self.take(count)?.to_vec()).ok()
    }
}

pub fn decode_metadata(bytes: &[u8]) -> Option<ExecutableMetadata> {
    let mut reader = Reader { remaining: bytes };
    if reader.take(MAGIC.len())? != MAGIC {
        return None;
    }
    let settings = read_settings(&mut reader)?;
    let mut sites = Vec::new();
    for _ in 0..reader.count()? {
        sites.push(read_site(&mut reader)?);
    }
    let mut classes = Vec::new();
    for _ in 0..reader.count()? {
        classes.push(read_class(&mut reader)?);
    }
    reader.remaining.is_empty().then_some(ExecutableMetadata {
        settings,
        sites,
        classes,
    })
}

fn read_settings(reader: &mut Reader<'_>) -> Option<ExecutableSettings> {
    let source_name = reader.text()?;
    let locale = reader.text()?;
    let seed = reader.signed64()?;
    let forced_collection = reader.unsigned32()? != 0;
    let frames = reader.unsigned32()?;
    let units = reader.unsigned64()?;
    let has_units = reader.unsigned32()? != 0;
    let cells = reader.unsigned64()?;
    let root_capacity = reader.unsigned32()?;
    Some(ExecutableSettings {
        source_name,
        locale,
        seed,
        forced_collection,
        limits: AotLimits {
            frames,
            instruction_units: has_units.then_some(units),
            cells,
            root_capacity,
        },
        boolean_words: BooleanWords {
            truth: reader.text()?,
            falsity: reader.text()?,
        },
        error_template: reader.text()?,
        warning_template: reader.text()?,
        information_template: reader.text()?,
        exhausted_template: reader.text()?,
    })
}

fn read_site(reader: &mut Reader<'_>) -> Option<FaultSite> {
    let code = DiagnosticCode::from_name(&reader.text()?)?;
    let lexeme = reader.text()?;
    Some(FaultSite {
        lexeme,
        code,
        range: SourceRange {
            start_line: reader.unsigned32()?,
            start_column: reader.unsigned32()?,
            end_line: reader.unsigned32()?,
            end_column: reader.unsigned32()?,
        },
    })
}

fn read_class(reader: &mut Reader<'_>) -> Option<ClassDescriptor> {
    let dense = reader.unsigned32()? != 0;
    let mut fields = Vec::new();
    for _ in 0..reader.count()? {
        fields.push(reader.unsigned32()?);
    }
    Some(ClassDescriptor { fields, dense })
}
