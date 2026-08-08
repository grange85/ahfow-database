# _plugins/on_this_day_generator.rb
#
# Generates one page per calendar day (366 total) at /on-this-day/MM-DD/
# Each page lists all non-cancelled shows across all artists that occurred on that
# month/day combination, regardless of year, plus any anniversaries/events from
# _data/ahfow-anniversaries.csv.
#
# Pages are accessible in Liquid via the `on_this_day` layout with:
#   page.month_day      - e.g. "01-15"
#   page.month_name     - e.g. "January"
#   page.day            - e.g. 15
#   page.shows          - array of show hashes, sorted by date, each with artist_slug injected
#   page.anniversaries  - array of anniversary hashes for this day, sorted by year

module Jekyll
  class OnThisDayPage < Page
    def initialize(site, month_day, month_name, day, shows, anniversaries, image_url, prev_day, next_day)
      @site = site
      @base = site.source
      @dir  = "on-this-day/#{month_day}"
      @name = "index.html"

      process(@name)

      @data = {
        "layout"        => "on_this_day",
        "title"         => "On this day: #{month_name} #{day}",
        "month_day"     => month_day,
        "month_name"    => month_name,
        "day"           => day,
        "shows"         => shows,
        "anniversaries" => anniversaries,
        "image_url"     => image_url,
        "prev_day"      => prev_day,
        "next_day"      => next_day,
        "sitemap"       => true,
      }

      @content = ""
    end
  end

  class OnThisDayGenerator < Generator
    safe true
    priority :low

    ARTIST_SLUGS = {
      "galaxie-500-shows"     => "galaxie-500",
      "luna-shows"            => "luna",
      "damon-and-naomi-shows" => "damon-and-naomi",
      "dean-and-britta-shows" => "dean-and-britta",
    }.freeze

    BUILD_YEAR = Date.today.year

    def generate(site)
      # ----------------------------------------------------------------
      # 1. Group shows by MM-DD across all four artist data files
      # ----------------------------------------------------------------
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

      # ----------------------------------------------------------------
      # 2. Group anniversaries by MM-DD from _data/ahfow-anniversaries.csv
      # ----------------------------------------------------------------
      anniversaries_by_day = Hash.new { |h, k| h[k] = [] }

      anniversaries = site.data["ahfow-anniversaries"]
      if anniversaries.is_a?(Array)
        anniversaries.each do |entry|
          month_day = entry["month_day"].to_s.strip
          next if month_day.empty?

          year = entry["year"].to_s.strip
          years_ago = year.empty? ? nil : BUILD_YEAR - year.to_i

          anniversaries_by_day[month_day] << entry.merge(
            "years_ago" => years_ago
          )
        end
      else
        Jekyll.logger.warn "OnThisDayGenerator:", "No anniversaries data found at _data/ahfow-anniversaries.csv"
      end

      # ----------------------------------------------------------------
      # 3. Build ordered list of all 366 MM-DD strings for prev/next nav
      # ----------------------------------------------------------------
      all_days = (1..12).flat_map do |month|
        (1..Date.new(2000, month, -1).day).map do |day|
          Date.new(2000, month, day).strftime("%m-%d")
        end
      end

      # ----------------------------------------------------------------
      # 4. Create one page per calendar day
      # ----------------------------------------------------------------
      (1..12).each do |month|
        days_in_month = Date.new(2000, month, -1).day
        (1..days_in_month).each do |day|
          date       = Date.new(2000, month, day)
          month_day  = date.strftime("%m-%d")
          month_name = date.strftime("%B")

          shows         = by_day[month_day].sort_by { |s| s["date"].to_s }
          anniversaries = anniversaries_by_day[month_day].sort_by { |a| a["year"].to_s == "" ? "9999" : a["year"].to_s }

          image_urls = shows.map { |s| s["poster-url"].to_s.strip }.reject(&:empty?) +
                       anniversaries.map { |a| a["image-url"].to_s.strip }.reject(&:empty?)
          image_url  = image_urls.sample

          idx      = all_days.index(month_day)
          prev_day = all_days[idx - 1]
          next_day = all_days[(idx + 1) % 366]

          site.pages << OnThisDayPage.new(
            site, month_day, month_name, day,
            shows, anniversaries, image_url, prev_day, next_day
          )
        end
      end

      total_shows         = by_day.values.sum(&:size)
      total_anniversaries = anniversaries_by_day.values.sum(&:size)
      Jekyll.logger.info "OnThisDayGenerator:",
        "Created 366 pages covering #{total_shows} shows and #{total_anniversaries} anniversaries."
    end
  end
end
