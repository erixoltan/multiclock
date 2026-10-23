.pragma library

// Fuzzy-time phrases (English only), driven by a small rule text that the
// user can edit in settings. The built-in phrase sets below use the same
// format.
//
// One rule per line, "<when> = <phrase>". The time is first rounded to the
// nearest `step` minutes, then the first rule that matches wins:
//
//   12:00 = Noon                  exactly this time (24-hour clock)
//   :15 = Quarter past {hour}     this minute of any hour
//   5:00-9:00 = Early morning     from the first time up to (not including)
//                                 the second; may run past midnight
//
// Placeholders in a phrase:
//   {hour} {next}    this hour / the next hour as a word ("ten")
//   {Hour} {Next}    the same, capitalized
//   {h12} {h24} {mm} digits
//
// "hours = twelve, one, ..." replaces the hour words; give 12 names
// (starting at twelve) or 24 (starting at midnight). Lines starting with
// "#" are comments.

const HOURS = ["twelve", "one", "two", "three", "four", "five", "six",
               "seven", "eight", "nine", "ten", "eleven"];

// Indexed by the phraseSet setting; anything else means "custom".
const PRESETS = [
    {
        step: 5,
        rules: [
            "0:00 = Midnight",
            "12:00 = Noon",
            ":00 = {Hour} o'clock",
            ":05 = Five past {hour}",
            ":10 = Ten past {hour}",
            ":15 = Quarter past {hour}",
            ":20 = Twenty past {hour}",
            ":25 = Twenty-five past {hour}",
            ":30 = Half past {hour}",
            ":35 = Twenty-five to {next}",
            ":40 = Twenty to {next}",
            ":45 = Quarter to {next}",
            ":50 = Ten to {next}",
            ":55 = Five to {next}",
        ].join("\n"),
    },
    {
        step: 15,
        rules: [
            "0:00 = Midnight",
            "12:00 = Noon",
            ":00 = {Hour} o'clock",
            ":15 = Quarter past {hour}",
            ":30 = Half past {hour}",
            ":45 = Quarter to {next}",
        ].join("\n"),
    },
    {
        step: 1,
        rules: [
            "0:00-5:00 = Night",
            "5:00-9:00 = Early morning",
            "9:00-12:00 = Morning",
            "12:00-14:00 = Midday",
            "14:00-17:00 = Afternoon",
            "17:00-21:00 = Evening",
            "21:00-0:00 = Late evening",
        ].join("\n"),
    },
];

function preset(index) {
    return PRESETS[index] || PRESETS[0];
}

function capitalize(s) {
    return s.charAt(0).toUpperCase() + s.slice(1);
}

// "H:MM" -> minutes since midnight, or -1.
function parseTime(s) {
    const m = /^(\d{1,2}):(\d{2})$/.exec(s.trim());
    if (!m)
        return -1;
    const h = parseInt(m[1], 10);
    const min = parseInt(m[2], 10);
    return (h < 24 && min < 60) ? h * 60 + min : -1;
}

// "<when>" -> a rule without its phrase, or null.
function parseWhen(when) {
    const minute = /^:(\d{2})$/.exec(when);
    if (minute) {
        const min = parseInt(minute[1], 10);
        return min < 60 ? { minute: min } : null;
    }
    const dash = when.indexOf("-");
    if (dash < 0) {
        const at = parseTime(when);
        return at >= 0 ? { from: at, to: at + 1 } : null;
    }
    const from = parseTime(when.slice(0, dash));
    const to = parseTime(when.slice(dash + 1));
    return (from >= 0 && to >= 0) ? { from: from, to: to } : null;
}

// Returns { rules, hours, errors }; `errors` lists the 1-based numbers of
// lines that could not be understood (they are skipped).
function parse(text) {
    const result = { rules: [], hours: HOURS, errors: [] };
    const lines = String(text).split("\n");
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line === "" || line.charAt(0) === "#")
            continue;
        const eq = line.indexOf("=");
        const key = eq < 0 ? "" : line.slice(0, eq).trim();
        const value = eq < 0 ? "" : line.slice(eq + 1).trim();

        if (key.toLowerCase() === "hours") {
            const names = value.split(",").map(function (n) { return n.trim(); });
            if ((names.length === 12 || names.length === 24) && names.indexOf("") < 0)
                result.hours = names;
            else
                result.errors.push(i + 1);
            continue;
        }

        const rule = parseWhen(key);
        if (!rule || value === "") {
            result.errors.push(i + 1);
            continue;
        }
        rule.phrase = value;
        result.rules.push(rule);
    }
    return result;
}

// The face asks for the same text every tick, so remember the last parse.
var cachedText = null;
var cachedSet = null;

function parsed(text) {
    if (text !== cachedText) {
        cachedSet = parse(text);
        cachedText = text;
    }
    return cachedSet;
}

function matches(rule, t) {
    if (rule.minute !== undefined)
        return t % 60 === rule.minute;
    if (rule.from < rule.to)
        return t >= rule.from && t < rule.to;
    return t >= rule.from || t < rule.to;   // runs past midnight
}

function twoDigits(n) {
    return (n < 10 ? "0" : "") + n;
}

function phrase(date, text, step) {
    const set = parsed(text);
    step = Math.max(1, step || 1);

    const exact = date.getHours() * 60 + date.getMinutes() + date.getSeconds() / 60;
    const t = (Math.round(exact / step) * step) % 1440;
    const hours = Math.floor(t / 60);
    const fallback = hours + ":" + twoDigits(t % 60);

    let template = null;
    for (let i = 0; i < set.rules.length; i++) {
        if (matches(set.rules[i], t)) {
            template = set.rules[i].phrase;
            break;
        }
    }
    if (template === null)
        return fallback;

    const names = set.hours;
    const thisHour = names[hours % names.length];
    const nextHour = names[(hours + 1) % names.length];
    const values = {
        "hour": thisHour,
        "next": nextHour,
        "Hour": capitalize(thisHour),
        "Next": capitalize(nextHour),
        "h12": String(hours % 12 === 0 ? 12 : hours % 12),
        "h24": String(hours),
        "mm": twoDigits(t % 60),
    };
    return template.replace(/\{(\w+)\}/g, function (whole, name) {
        return values.hasOwnProperty(name) ? values[name] : whole;
    });
}
