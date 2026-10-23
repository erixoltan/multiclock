// Checks FuzzyTime.js outside Qt. Run: make check
const fs = require("fs"), path = require("path"), assert = require("assert");
const src = fs.readFileSync(path.join(__dirname, "../common/ui/FuzzyTime.js"), "utf8");
const { phrase, preset, parse } = new Function(src.replace(".pragma library", "") + "\nreturn { phrase, preset, parse };")();

const d = (h, m, s) => new Date(2026, 0, 1, h, m, s || 0);
const p = (i, h, m, s) => phrase(d(h, m, s), preset(i).rules, preset(i).step);
// old behaviour, five-minute set
assert.equal(p(0, 10, 0), "Ten o'clock");
assert.equal(p(0, 10, 17), "Quarter past ten");
assert.equal(p(0, 10, 35), "Twenty-five to eleven");
assert.equal(p(0, 10, 58), "Eleven o'clock");
assert.equal(p(0, 23, 58), "Midnight");
assert.equal(p(0, 11, 58), "Noon");
assert.equal(p(0, 12, 20), "Twenty past twelve");
assert.equal(p(0, 23, 40), "Twenty to twelve");
assert.equal(p(0, 0, 5), "Five past twelve");
// quarter
assert.equal(p(1, 10, 8), "Quarter past ten");
assert.equal(p(1, 10, 53), "Eleven o'clock");
// time of day
assert.equal(p(2, 4, 59), "Night");
assert.equal(p(2, 5, 0), "Early morning");
assert.equal(p(2, 23, 30), "Late evening");
assert.equal(p(2, 23, 59, 45), "Night");
// every minute of the day matches some rule in every preset
for (let i = 0; i < 3; i++) for (let m = 0; m < 1440; m++)
  assert.ok(!/^\d+:\d\d$/.test(p(i, Math.floor(m / 60), m % 60)), i + " " + m);
for (let i = 0; i < 3; i++) assert.deepEqual(parse(preset(i).rules).errors, []);
// custom
const custom = "# mine\nhours = 0h,1h,2h,3h,4h,5h,6h,7h,8h,9h,10h,11h,12h,13h,14h,15h,16h,17h,18h,19h,20h,21h,22h,23h\n22:00-6:00 = go to bed = now\n:30 = {h12}:{mm} / {h24} half {next} {bogus}\nnonsense\n25:00 = x\n:15 =\n";
assert.deepEqual(parse(custom).errors, [5, 6, 7]);
assert.equal(phrase(d(23, 0), custom, 30), "go to bed = now");
assert.equal(phrase(d(3, 0), custom, 30), "go to bed = now");
assert.equal(phrase(d(13, 31), custom, 30), "1:30 / 13 half 14h {bogus}");
assert.equal(phrase(d(13, 50), custom, 30), "14:00");
assert.equal(phrase(d(13, 50), "", 5), "13:50");
assert.deepEqual(parse("hours = a, b").errors, [1]);
console.log("ok");
