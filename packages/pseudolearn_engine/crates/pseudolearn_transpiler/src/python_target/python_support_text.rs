const READ_LINE: &str = r#"def read_line():
    try:
        return input()
    except EOFError:
        raise SystemExit("no more input")"#;

const READERS: &str = r#"def read_integer():
    while True:
        text = read_line().strip()
        if re.fullmatch(r"[+-]?[0-9]+", text) is not None:
            return int(text)"#;

const READ_REAL: &str = r#"def read_real():
    while True:
        try:
            value = float(read_line().strip())
            if math.isfinite(value):
                return value
        except ValueError:
            pass"#;

const READ_TEXT: &str = r#"def read_text():
    return read_line()"#;

const READ_CHARACTER: &str = r#"def read_character():
    while True:
        text = read_line()
        if len(text) == 1:
            return text"#;

const ROUND_HALF_AWAY: &str = r#"def round_half_away(value):
    whole = decimal.Decimal(value).quantize(decimal.Decimal(1), rounding=decimal.ROUND_HALF_UP)
    return truncate(float(whole))"#;

const TRUNCATE: &str = r#"def truncate(value):
    whole = int(value)
    if whole < -(2 ** 63) or whole >= 2 ** 63:
        raise OverflowError("integerOverflow")
    return whole"#;

const FLOOR: &str = r#"def floor(value):
    return truncate(math.floor(value))"#;

const CEILING: &str = r#"def ceiling(value):
    return truncate(math.ceil(value))"#;

const RANDOM: &str = r#"MASK = (1 << 64) - 1


def random_words(seed):
    state = seed & MASK
    words = []
    for _ in range(4):
        state = (state + 0x9E3779B97F4A7C15) & MASK
        mixed = ((state ^ (state >> 30)) * 0xBF58476D1CE4E5B9) & MASK
        mixed = ((mixed ^ (mixed >> 27)) * 0x94D049BB133111EB) & MASK
        words.append(mixed ^ (mixed >> 31))
    return words


def rotate(value, amount):
    return ((value << amount) | (value >> (64 - amount))) & MASK


RANDOM_WORDS = random_words(SEED)


def next_word():
    first, second, third, fourth = RANDOM_WORDS
    result = (rotate((second * 5) & MASK, 7) * 9) & MASK
    shift = (second << 17) & MASK
    third ^= first
    fourth ^= second
    second ^= third
    first ^= fourth
    RANDOM_WORDS[:] = [first, second, third ^ shift, rotate(fourth, 45)]
    return result


def next_below(bound):
    remainder = ((MASK % bound) + 1) % bound
    accepted = (-remainder) & MASK
    while True:
        word = next_word()
        if remainder == 0 or word < accepted:
            return word % bound


def random(bound):
    if bound <= 0:
        raise ValueError("invalidRandomBound")
    return next_below(bound)


def random_between(low, high):
    if low > high:
        raise ValueError("invalidRandomRange")
    width = high - low
    offset = next_below(width + 1) if width + 1 <= MASK else next_word()
    return low + offset


def random_unit():
    integer = next_word() >> 11
    return ((integer >> 32) * 4294967296.0 + (integer & 0xFFFFFFFF)) / 9007199254740992.0"#;

const CHARACTER_AT: &str = r#"def character_at(text, position):
    if position < 0 or position >= len(text):
        raise IndexError("stringPositionOutOfRange")
    return text[position]"#;

const CHARACTER_FROM_CODE: &str = r#"def character_from_code(code):
    if code < 0 or code > 1114111 or 55296 <= code <= 57343:
        raise ValueError("invalidCharacterCode")
    return chr(code)"#;

const SUBSTRING: &str = r#"def substring(text, start, end):
    if start < 0 or start > len(text) or end + 1 < start or end + 1 > len(text):
        raise IndexError("stringPositionOutOfRange")
    return text[start:end + 1]"#;

const TEXT_POSITION: &str = r#"def text_position(text, part):
    found = text.find(part)
    return Some(found) if found >= 0 else Nothing()"#;

const REPLACE_ALL: &str = r#"def replace_all(text, old, new):
    return text if old == "" else text.replace(old, new)"#;

const SPLIT_TEXT: &str = r#"def split_text(text, separator):
    if separator == "":
        raise ValueError("emptySeparator")
    return text.split(separator)"#;

const TEXT_TO_INTEGER: &str = r#"def text_to_integer(text):
    if re.fullmatch(r"[+-]?[0-9]+", text) is None:
        raise ValueError("stringToNumberConversionFailed")
    return int(text)"#;

const TEXT_TO_REAL: &str = r#"def text_to_real(text):
    try:
        value = float(text)
    except ValueError:
        raise ValueError("stringToNumberConversionFailed")
    if not math.isfinite(value) or text.strip() != text:
        raise ValueError("stringToNumberConversionFailed")
    return value"#;

const COLLECTION_TEXT: &str = r#"def shown(value, quoted):
    if isinstance(value, bool):
        return boolean_text(value)
    if isinstance(value, float):
        return real_text(value)
    if isinstance(value, str):
        return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"' if quoted else value
    if isinstance(value, list):
        return "[" + ", ".join(shown(entry, True) for entry in value) + "]"
    if isinstance(value, dict):
        return "{" + ", ".join(shown(key, True) + ": " + shown(entry, True) for key, entry in value.items()) + "}"
    return str(value)


def collection_text(collection):
    return shown(collection, False)"#;

const DICTIONARY_FIND: &str = r#"def dictionary_find(dictionary, key):
    return Some(dictionary[key]) if key in dictionary else Nothing()"#;

const DICTIONARY_REMOVE: &str = r#"def dictionary_remove(dictionary, key):
    return Some(dictionary.pop(key)) if key in dictionary else Nothing()"#;

const VECTOR_INDEX_OF: &str = r#"def vector_index_of(vector, value):
    return Some(vector.index(value)) if value in vector else Nothing()"#;

pub(crate) fn text_source(name: &str) -> String {
    let text = match name {
        "read_line" => READ_LINE,
        "read_integer" => READERS,
        "read_real" => READ_REAL,
        "read_text" => READ_TEXT,
        "read_character" => READ_CHARACTER,
        "round_half_away" => ROUND_HALF_AWAY,
        "truncate" => TRUNCATE,
        "floor" => FLOOR,
        "ceiling" => CEILING,
        "random" => RANDOM,
        "character_at" => CHARACTER_AT,
        "character_from_code" => CHARACTER_FROM_CODE,
        "substring" => SUBSTRING,
        "text_position" => TEXT_POSITION,
        "replace_all" => REPLACE_ALL,
        "split_text" => SPLIT_TEXT,
        "text_to_integer" => TEXT_TO_INTEGER,
        "text_to_real" => TEXT_TO_REAL,
        "collection_text" => COLLECTION_TEXT,
        "dictionary_find" => DICTIONARY_FIND,
        "dictionary_remove" => DICTIONARY_REMOVE,
        "vector_index_of" => VECTOR_INDEX_OF,
        _ => "",
    };
    text.to_owned()
}
