# _plugins/track_data_generator.rb
#
# Pre-computes discography and gigography lookups for each track page,
# so the track.html layout doesn't need to scan large data files via Liquid.
#
# Runs at priority :low so it executes after jekyll-datapage-gen (priority :normal)
# has already created the track pages from discography.tracks CSV data.
#
# Injects into each track page:
#   page.computed_releases  - array of release hashes
#   page.computed_shows     - hash keyed by artist slug, each an array of show hashes

module Jekyll
  class TrackDataGenerator < Generator
    safe true
    priority :low  # Must run after jekyll-datapage-gen (priority :normal)

    ARTIST_SLUGS = {
      "Galaxie 500"   => "galaxie-500",
      "Luna"          => "luna",
      "Dean & Britta" => "dean-and-britta",
      "Dean Wareham"  => "dean-wareham",
      "Damon & Naomi" => "damon-and-naomi",
    }.freeze

    GIG_ARTISTS = %w[galaxie-500 luna damon-and-naomi dean-and-britta].freeze

    def generate(site)
      # ----------------------------------------------------------------
      # 1. Build a lookup index: normalised track slug -> array of releases
      #    Iterates all discography data files once.
      # ----------------------------------------------------------------
      releases_by_slug = Hash.new { |h, k| h[k] = [] }

      site.data["discography"]&.each do |album_key, records|
        next unless records.is_a?(Array)

        records.each do |record|
          track_index = record["Track-index"].to_s
          next if track_index.empty?

          # Track-index is pipe-delimited, e.g. "|bluethunder|tellme|"
          slugs = track_index.split("|").map(&:strip).reject(&:empty?)
          next if slugs.empty?

          artist       = record["Artist"].to_s
          album_artist = record["AlbumArtist"].to_s
          display_artist = album_artist.empty? ? artist : album_artist
          artist_slug  = ARTIST_SLUGS[artist]

          if album_key.include?("singles")
            album_section = "singles"
          elsif album_key.include?("misc")
            album_section = "miscellaneous"
          else
            album_section = record["Title"].to_s
          end

          release = {
            "title"         => record["Title"],
            "artist"        => display_artist,
            "artist_slug"   => artist_slug,
            "label"         => record["Label"],
            "date"          => record["Date"],
            "catno"         => record["CatNo"].to_s,
            "album_section" => album_section,
          }

          slugs.each { |s| releases_by_slug[s] << release }
        end
      end

      # ----------------------------------------------------------------
      # 2. Build a lookup index: normalised track slug -> { artist_slug -> [shows] }
      #    Iterates each gigography data file once.
      # ----------------------------------------------------------------
      shows_by_slug = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }

      GIG_ARTISTS.each do |artist_slug|
        data_key = "#{artist_slug}-shows"
        shows = site.data.dig("gigography", data_key)
        next unless shows.is_a?(Array)

        sorted_shows = shows.sort_by { |s| s["date"].to_s }

        sorted_shows.each do |show|
          setlist_index = show["setlist-index"].to_s
          next if setlist_index.empty?

          slugs = setlist_index.split("|").map(&:strip).reject(&:empty?)
          slugs.each { |s| shows_by_slug[s][artist_slug] << show }
        end
      end

      # ----------------------------------------------------------------
      # 3. Inject pre-computed data into each track page.
      #    Track pages are identified by the presence of page.data["ahfow"]["slug"],
      #    which is set by jekyll-datapage-gen via page_data_prefix: ahfow.
      # ----------------------------------------------------------------
      track_pages = site.pages.select { |p| p.data.dig("ahfow", "slug") }

      track_pages.each do |page|
        raw_slug = page.data.dig("ahfow", "slug").to_s
        # Normalise to match the Track-index/setlist-index format (no hyphens)
        lookup_slug = raw_slug.gsub("-", "")

        page.data["computed_releases"] = releases_by_slug[lookup_slug] || []
        page.data["computed_shows"]    = shows_by_slug[lookup_slug]    || {}
      end

      Jekyll.logger.info "TrackDataGenerator:",
        "Annotated #{track_pages.size} track pages with pre-computed release and show data."
    end
  end
end
