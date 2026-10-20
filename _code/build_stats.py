#!/usr/bin/env python3
"""Build per-artist stats for the AHFOW Jekyll site from the shows CSV exports.

Outputs (under --site):
  _data/stats/<artist>/songs_played.json   most-played songs (distinct shows)
  _data/stats/<artist>/by_country.json     show counts by country
  _data/stats/<artist>/by_state.json       US show counts by state
  <artist>/shows/songs-played.md
  <artist>/shows/by-country.md
  <artist>/shows/by-state.md
  _includes/stats/*.html                    shared table templates (no JavaScript)
"""
import argparse, csv, datetime, json, re, collections, pathlib

ARTISTS = {  # url slug -> CSV export filename stem
    "galaxie-500": "galaxie-500-shows",
    "luna": "luna-shows",
    "damon-and-naomi": "damon-and-naomi-shows",
    "dean-and-britta": "dean-and-britta-shows",
}
US_STATES = {
    "AL":"Alabama","AK":"Alaska","AZ":"Arizona","AR":"Arkansas","CA":"California","CO":"Colorado",
    "CT":"Connecticut","DE":"Delaware","DC":"District of Columbia","FL":"Florida","GA":"Georgia",
    "HI":"Hawaii","ID":"Idaho","IL":"Illinois","IN":"Indiana","IA":"Iowa","KS":"Kansas","KY":"Kentucky",
    "LA":"Louisiana","ME":"Maine","MD":"Maryland","MA":"Massachusetts","MI":"Michigan","MN":"Minnesota",
    "MS":"Mississippi","MO":"Missouri","MT":"Montana","NE":"Nebraska","NV":"Nevada","NH":"New Hampshire",
    "NJ":"New Jersey","NM":"New Mexico","NY":"New York","NC":"North Carolina","ND":"North Dakota",
    "OH":"Ohio","OK":"Oklahoma","OR":"Oregon","PA":"Pennsylvania","RI":"Rhode Island","SC":"South Carolina",
    "SD":"South Dakota","TN":"Tennessee","TX":"Texas","UT":"Utah","VT":"Vermont","VA":"Virginia",
    "WA":"Washington","WV":"West Virginia","WI":"Wisconsin","WY":"Wyoming",
}

def load(path):
    return list(csv.DictReader(open(path, encoding="utf-8", newline="")))

def song_key(s):
    return re.sub(r"[^a-z0-9]", "", s.lower())

def clean_song(s):
    """Tidy one setlist entry. Drops everything from a '^' onward (the '^' marks an
    unidentified or annotated part), removes [bracketed] notes such as
    'Tugboat [with Kramer]' or '[Instrumental?]', and tidies whitespace."""
    s = s.split("^", 1)[0]
    s = re.sub(r"\[[^\]]*\]", "", s)
    s = re.sub(r"\s{2,}", " ", s)
    return s.strip()

def is_placeholder(s):
    return s == ""

def check(slug, rows):
    """Warn about data problems that would make the stats wrong or misleading."""
    for r in rows:
        for col in ("country", "state", "city", "date"):
            if r[col] != r[col].strip().replace("\xa0", "") or "\xa0" in r[col]:
                print(f"WARNING {slug}: whitespace in {col} {r[col]!r} ({r['date']})", file=__import__("sys").stderr)
        if r["city"].endswith(","):
            print(f"WARNING {slug}: city ends with comma {r['city']!r} ({r['date']})", file=__import__("sys").stderr)
        if r["country"] == "Canada" and not r["state"]:
            print(f"WARNING {slug}: Canada show with no province ({r['date']} {r['city']})", file=__import__("sys").stderr)
        if r["country"] == "USA" and not r["state"]:
            print(f"WARNING {slug}: USA show with no state ({r['date']} {r['city']})", file=__import__("sys").stderr)
        if r["state"] == "" and r["country"] == "" and r["city"]:
            print(f"WARNING {slug}: no country ({r['date']} {r['city']})", file=__import__("sys").stderr)

def build(slug, path, as_of):
    rows = load(path)
    check(slug, rows)
    kept, excluded = [], collections.Counter()
    for r in rows:
        try:
            d = datetime.date.fromisoformat(r["date"])
        except ValueError:
            excluded["bad date"] += 1
            print(f"WARNING {slug}: unreadable date {r['date']!r} ({r['city']}) - row skipped", file=__import__("sys").stderr)
            continue
        if r["cancelled"].upper() == "TRUE":
            excluded["cancelled"] += 1
            continue
        if d >= as_of:
            excluded["upcoming"] += 1
            continue
        kept.append(r)

    # countries and states
    countries = collections.Counter(r["country"] or "Unknown" for r in kept)
    states = collections.Counter(r["state"] or "Unknown" for r in kept
                                 if r["country"] == "USA")

    # songs: count distinct shows per song key; display the most common spelling
    spelled = collections.defaultdict(collections.Counter)
    shows_per_song = collections.Counter()
    for r in kept:
        seen = set()
        for raw in r["setlist"].split("|"):
            s = clean_song(raw)
            if is_placeholder(s):
                continue
            k = song_key(s)
            if not k:
                continue
            spelled[k][s] += 1
            seen.add(k)
        for k in seen:
            shows_per_song[k] += 1
    songs = []
    for k, n in shows_per_song.items():
        title = spelled[k].most_common(1)[0][0]
        songs.append({"title": title, "shows": n})
    songs.sort(key=lambda x: (-x["shows"], x["title"].lower()))

    by_country = [{"country": c, "shows": n} for c, n in
                  sorted(countries.items(), key=lambda x: (-x[1], x[0].lower()))]
    by_state = [{"code": s, "name": US_STATES.get(s, s), "shows": n} for s, n in
                sorted(states.items(), key=lambda x: (-x[1], x[0]))]

    summary = {
        "shows_counted": len(kept),
        "shows_with_setlist": sum(1 for r in kept if r["setlist"]),
        "excluded": dict(excluded),
        "first_show": min(r["date"] for r in kept),
        "last_show": max(r["date"] for r in kept),
        "countries": len(countries),
        "us_states": len(states),
    }
    return songs, by_country, by_state, summary

PAGES = {
    "songs-played": ("Songs played", "songs_played", "stats/songs-played.html"),
    "by-country": ("By country", "by_country", "stats/by-country.html"),
    "by-state": ("By US state", "by_state", "stats/by-state.html"),
}

INCLUDES = {
"songs-played.html": """<p>{{ page.summary_text }}</p>
<table class="stats-table">
  <thead><tr><th scope="col">#</th><th scope="col">Song</th><th scope="col">Shows</th></tr></thead>
  <tbody>
  {% for s in site.data.stats[page.artist].songs_played limit:200 %}
    <tr><td>{{ forloop.index }}</td><td>{{ s.title }}</td><td>{{ s.shows }}</td></tr>
  {% endfor %}
  </tbody>
</table>
""",
"by-country.html": """<p>{{ page.summary_text }}</p>
<table class="stats-table">
  <thead><tr><th scope="col">Country</th><th scope="col">Shows</th></tr></thead>
  <tbody>
  {% for c in site.data.stats[page.artist].by_country %}
    <tr><td>{{ c.country }}</td><td>{{ c.shows }}</td></tr>
  {% endfor %}
  </tbody>
</table>
""",
"by-state.html": """<p>{{ page.summary_text }}</p>
<table class="stats-table">
  <thead><tr><th scope="col">State</th><th scope="col">Shows</th></tr></thead>
  <tbody>
  {% for s in site.data.stats[page.artist].by_state %}
    <tr><td>{{ s.name }}</td><td>{{ s.shows }}</td></tr>
  {% endfor %}
  </tbody>
</table>
""",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv-dir", required=True)
    ap.add_argument("--site", required=True)
    ap.add_argument("--as-of", default=datetime.date.today().isoformat())
    a = ap.parse_args()
    as_of = datetime.date.fromisoformat(a.as_of)
    site = pathlib.Path(a.site)
    csvdir = pathlib.Path(a.csv_dir)

    (site / "_includes/stats").mkdir(parents=True, exist_ok=True)
    for name, body in INCLUDES.items():
        (site / "_includes/stats" / name).write_text(body, encoding="utf-8")

    report = {}
    for slug, stem in ARTISTS.items():
        path = next(csvdir.glob(f"*{stem}.csv"))
        songs, by_country, by_state, summary = build(slug, path, as_of)
        report[slug] = {"summary": summary, "top_songs": songs[:10],
                        "top_countries": by_country[:8], "top_states": by_state[:8]}
        d = site / "_data/stats" / slug
        d.mkdir(parents=True, exist_ok=True)
        (d / "songs_played.json").write_text(json.dumps(songs, ensure_ascii=False, indent=1), encoding="utf-8")
        (d / "by_country.json").write_text(json.dumps(by_country, ensure_ascii=False, indent=1), encoding="utf-8")
        (d / "by_state.json").write_text(json.dumps(by_state, ensure_ascii=False, indent=1), encoding="utf-8")

        counted = summary["shows_counted"]
        base_note = (f"Counted from {counted} shows, {summary['first_show'][:4]} to {summary['last_show'][:4]}. "
                     "Cancelled and upcoming shows are left out.")
        texts = {
            "songs-played": f"Songs played most often across {summary['shows_with_setlist']} shows with a setlist. "
                            "Each count is the number of shows a song appeared in. " + base_note,
            "by-country": f"Show counts by country. {base_note}",
            "by-state": f"US show counts by state. {base_note}",
        }
        for page_key, (title, data_key, inc) in PAGES.items():
            pdir = site / slug / "shows"
            pdir.mkdir(parents=True, exist_ok=True)
            fm = (f"---\nlayout: default\ntitle: \"{title}\"\nartist: {slug}\n"
                  f"permalink: /{slug}/shows/{page_key}/\n"
                  f"summary_text: \"{texts[page_key]}\"\n---\n"
                  f"{{% include {inc} %}}\n")
            (pdir / f"{page_key}.md").write_text(fm, encoding="utf-8")

    (site / "stats-build-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=1), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=1))

if __name__ == "__main__":
    main()
