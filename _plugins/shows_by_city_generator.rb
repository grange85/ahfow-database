# _plugins/shows_by_city_generator.rb
#
# Generates a three-level hierarchy of pages:
#
#   /shows-by-city/                        - all countries index
#   /shows-by-city/<country-slug>/         - all cities in a country
#   /shows-by-city/<country-slug>/<city-slug>/  - individual city page
#
# City slug for USA includes state: austin-tx
# City slug for other countries: city only: london
#
# Each page type uses a different layout:
#   shows_by_city_index    - top-level country list
#   shows_by_country       - city list for one country
#   shows_by_city          - individual city shows

module Jekyll

  # -----------------------------------------------------------------------
  # Page classes
  # -----------------------------------------------------------------------

  class ShowsByCityIndexPage < Page
    def initialize(site, countries)
      @site = site
      @base = site.source
      @dir  = "shows-by-city"
      @name = "index.html"
      process(@name)
      @data = {
        "layout"    => "shows_by_city_index",
        "title"     => "Shows by city",
        "countries" => countries,
        "sitemap"   => true,
      }
      @content = ""
    end
  end

  class ShowsByCountryPage < Page
    def initialize(site, country, country_slug, cities)
      @site = site
      @base = site.source
      @dir  = "shows-by-city/#{country_slug}"
      @name = "index.html"
      process(@name)
      @data = {
        "layout"       => "shows_by_country",
        "title"        => "Shows in #{country}",
        "country"      => country,
        "country_slug" => country_slug,
        "cities"       => cities,
        "sitemap"      => true,
      }
      @content = ""
    end
  end

  class ShowsByCityPage < Page
    def initialize(site, city, state, country, country_slug, city_slug, shows)
      @site = site
      @base = site.source
      @dir  = "shows-by-city/#{country_slug}/#{city_slug}"
      @name = "index.html"
      process(@name)

      parts = [city]
      parts << state if state.to_s.strip != ""
      parts << country if country.to_s.strip != ""
      display_location = parts.join(", ")

      @data = {
        "layout"           => "shows_by_city",
        "title"            => "Shows in #{display_location}",
        "city"             => city,
        "state"            => state,
        "country"          => country,
        "country_slug"     => country_slug,
        "city_slug"        => city_slug,
        "display_location" => display_location,
        "shows"            => shows,
        "sitemap"          => true,
      }
      @content = ""
    end
  end

  # -----------------------------------------------------------------------
  # Generator
  # -----------------------------------------------------------------------

  class ShowsByCityGenerator < Generator
    safe true
    priority :low

    ARTIST_SLUGS = {
      "galaxie-500-shows"     => "galaxie-500",
      "luna-shows"            => "luna",
      "damon-and-naomi-shows" => "damon-and-naomi",
      "dean-and-britta-shows" => "dean-and-britta",
    }.freeze

    def generate(site)
      # Structure: country_slug -> city_slug -> array of shows
      by_country_city = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }

      # Store display metadata keyed by slug
      country_meta = {}  # country_slug -> { country: }
      city_meta    = {}  # "country_slug/city_slug" -> { city:, state:, country:, country_slug: }

      ARTIST_SLUGS.each do |data_key, artist_slug|
        shows = site.data.dig("gigography", data_key)
        next unless shows.is_a?(Array)

        shows.each do |show|
          next if show["cancelled"].to_s.strip != "" || show["uncertain-date"].to_s.strip != ""

          city    = show["city"].to_s.strip
          state   = show["state"].to_s.strip
          country = show["country"].to_s.strip
          next if city.empty? || country.empty?

          country_slug = slugify(country)
          city_slug    = build_city_slug(city, state, country)
          meta_key     = "#{country_slug}/#{city_slug}"

          by_country_city[country_slug][city_slug] << show.merge("artist_slug" => artist_slug)

          country_meta[country_slug] ||= { "country" => country }
          city_meta[meta_key] ||= {
            "city"         => city,
            "state"        => state.empty? ? nil : state,
            "country"      => country,
            "country_slug" => country_slug,
          }
        end
      end

      # ---- Build country index data (for top-level index page) ----------
      countries = by_country_city.keys.sort.map do |country_slug|
        cities      = by_country_city[country_slug]
        show_count  = cities.values.sum(&:size)
        {
          "country"      => country_meta[country_slug]["country"],
          "country_slug" => country_slug,
          "city_count"   => cities.size,
          "show_count"   => show_count,
        }
      end

      site.pages << ShowsByCityIndexPage.new(site, countries)

      # ---- Build per-country pages and per-city pages -------------------
      by_country_city.each do |country_slug, cities_hash|
        # City list for the country index page, sorted by city name
        cities = cities_hash.keys.sort.map do |city_slug|
          meta       = city_meta["#{country_slug}/#{city_slug}"]
          show_count = cities_hash[city_slug].size
          {
            "city"         => meta["city"],
            "state"        => meta["state"],
            "city_slug"    => city_slug,
            "show_count"   => show_count,
            "display_name" => [meta["city"], meta["state"]].compact.join(", "),
          }
        end

        site.pages << ShowsByCountryPage.new(
          site,
          country_meta[country_slug]["country"],
          country_slug,
          cities
        )

        # Individual city pages
        cities_hash.each do |city_slug, shows|
          meta         = city_meta["#{country_slug}/#{city_slug}"]
          sorted_shows = shows.sort_by { |s| s["date"].to_s }

          site.pages << ShowsByCityPage.new(
            site,
            meta["city"],
            meta["state"],
            meta["country"],
            country_slug,
            city_slug,
            sorted_shows
          )
        end
      end

      total_cities    = by_country_city.values.sum(&:size)
      total_countries = by_country_city.size
      Jekyll.logger.info "ShowsByCityGenerator:",
        "Created #{total_countries} country pages and #{total_cities} city pages."
    end

    private

    def slugify(str)
      str.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    end

    def build_city_slug(city, state, country)
      parts = [city]
      parts << state if country == "USA" && state.to_s.strip != ""
      slugify(parts.join("-"))
    end
  end
end
