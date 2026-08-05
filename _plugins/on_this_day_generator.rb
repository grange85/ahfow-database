# _plugins/on_this_day_generator.rb
#
# Generates one page per calendar day (366 total) at /database/on-this-day/MM-DD/
# Each page lists all non-cancelled shows across all artists that occurred on that
# month/day combination, regardless of year.
#
# Pages are accessible in Liquid via the `on_this_day` layout with:
#   page.month_day   - e.g. "01-15"
#   page.month_name  - e.g. "January"
#   page.day         - e.g. 15
#   page.shows       - array of show hashes, sorted by date, each with artist_slug injected

module Jekyll
  class OnThisDayPage < Page
    def initialize(site, month_day, month_name, day, shows)
      @site = site
      @base = site.source
      @dir  = "on-this-day/#{month_day}"
      @name = "index.html"

      process(@name)

      @data = {
        "layout"     => "on_this_day",
        "title"      => "On this day: #{month_name} #{day}",
        "month_day"  => month_day,
        "month_name" => month_name,
        "day"        => day,
        "shows"      => shows,
        "sitemap"    => true,
      }

      @content = ""
    end
  end

  class OnThisDayGenerator < Generator
    safe true
    priority :low

    ARTIST_SLUGS = {
      "galaxie-500-shows"    => "galaxie-500",
      "luna-shows"           => "luna",
      "damon-and-naomi-shows" => "damon-and-naomi",
      "dean-and-britta-shows" => "dean-and-britta",
    }.freeze

    def generate(site)
      # Group shows by MM-DD across all four artist data files
      by_day = Hash.new { |h, k| h[k] = [] }

      ARTIST_SLUGS.each do |data_key, artist_slug|
        shows = site.data.dig("gigography", data_key)
        next unless shows.is_a?(Array)

        shows.each do |show|
          next if show["cancelled"].to_s.strip != "" || show["uncertain-date"].to_s.strip != ""
          date_str = show["date"].to_s.strip
          next if date_str.empty?

          begin
            date = Date.parse(date_str)
          rescue ArgumentError
            next
          end

          month_day = date.strftime("%m-%d")
          by_day[month_day] << show.merge("artist_slug" => artist_slug)
        end
      end

      # Create one page per day that has at least one show.
      # Iterate all 366 possible days so pages exist even for days
      # with no shows (they'll show a friendly empty state).
      # Use 2000 as a leap-year-safe base year to cover Feb 29.
      (1..12).each do |month|
        days_in_month = Date.new(2000, month, -1).day
        (1..days_in_month).each do |day|
          date      = Date.new(2000, month, day)
          month_day = date.strftime("%m-%d")
          month_name = date.strftime("%B")

          shows = by_day[month_day].sort_by { |s| s["date"].to_s }

          site.pages << OnThisDayPage.new(site, month_day, month_name, day, shows)
        end
      end

      total_shows = by_day.values.sum(&:size)
      Jekyll.logger.info "OnThisDayGenerator:",
        "Created 366 on-this-day pages covering #{total_shows} shows."
    end
  end
end
