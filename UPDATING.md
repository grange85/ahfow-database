# Updating the AHFOW database stats

1. Export the four shows sheets as CSV (galaxie-500, luna, damon-and-naomi, dean-and-britta)
   into one folder. Filenames must end in `-shows.csv` (e.g. `luna-shows.csv`).
2. From the root of the Jekyll site repo, run:

       python3 build_stats.py --csv-dir <folder-with-csvs> --site .

3. Read the WARNING lines. Each one is a data problem to fix in the sheet and re-export:
   - unreadable date (usually a trailing non-breaking space in the `date` cell)
   - whitespace in country, state, city or date
   - city ending in a comma
   - Canada show with no province, or USA show with no state
   Rows with an unreadable date are skipped, so fix these before publishing.
4. Commit the changed `_data/stats/` and `database/` files and push.

The script is safe to rerun. It only writes `_data/stats/` and `database/<artist>/` pages
and `_includes/stats/`. Future-dated and cancelled shows are excluded automatically.

Output: `<artist>/shows/songs-played.md`, `by-country.md` and `by-state.md` under the
folder you pass as `--site` (the repo root). The `/database/` URL prefix comes from the
site's existing configuration, so the pages carry no permalink.

Song rules: a setlist entry is cut at any '^' (the '^' and everything after it is dropped),
[bracketed] notes are removed (e.g. "Tugboat [with Kramer]" counts as "Tugboat"), and entries
that end up empty are not counted.
 
