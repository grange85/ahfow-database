# _plugins/ics_feed_generator.rb
#
# Generates /ahfow.ics — a subscribable iCalendar feed containing:
#   - Past shows as yearly recurring anniversary events
#   - Future shows as one-off events
#   - Entries from _data/ahfow-anniversaries.csv as yearly recurring events
#
# Cancelled and uncertain-date shows are excluded.
# The feed display name is "A Head Full of Wishes".

module Jekyll
  class IcsFeedGenerator < Generator
    safe true
    priority :low

    ARTIST_SLUGS = {
      "galaxie-500-shows"     => "galaxie-500",
      "luna-shows"            => "luna",
      "damon-and-naomi-shows" => "damon-and-naomi",
      "dean-and-britta-shows" => "dean-and-britta",
    }.freeze

    def generate(site)
      today     = Date.today
      build_dts = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
      base_url  = (site.config["url"].to_s + site.config["baseurl"].to_s).chomp("/")

      lines = []
      lines << "BEGIN:VCALENDAR"
      lines << "VERSION:2.0"
      lines << "PRODID:-//A Head Full of Wishes//fullofwishes.co.uk//EN"
      lines << "X-WR-CALNAME:A Head Full of Wishes"
      lines << fold("X-WR-CALDESC:Shows and anniversaries for Galaxie 500, Luna, Damon & Naomi, Dean & Britta and Dean Wareham")
      lines << "X-WR-TIMEZONE:UTC"
      lines << "CALSCALE:GREGORIAN"
      lines << "METHOD:PUBLISH"

      # ----------------------------------------------------------------
      # Shows
      # ----------------------------------------------------------------
      ARTIST_SLUGS.each do |data_key, artist_slug|
        shows = site.data.dig("gigography", data_key)
        next unless shows.is_a?(Array)

        shows.each do |show|
          next if show["cancelled"].to_s.strip != ""
          next if show["uncertain-date"].to_s.strip != ""

          date_str = show["date"].to_s.strip
          next if date_str.empty?

          begin
            show_date = Date.parse(date_str)
          rescue ArgumentError
            next
          end

          is_past     = show_date < today
          dtstart     = show_date.strftime("%Y%m%d")
          artist_name = show["artistname"].to_s.strip
          artist_name = artist_slug if artist_name.empty?
          venue       = show["venue"].to_s.strip
          city        = show["city"].to_s.strip
          state       = show["state"].to_s.strip
          country     = show["country"].to_s.strip
          show_slug   = show["show-slug"].to_s.strip
          venue_slug  = show["venue-slug"].to_s.strip

          location_parts = [venue, city, state, country].reject(&:empty?)
          location = location_parts.join(", ")

          if is_past
            summary = "#{artist_name} at #{location} (#{show_date.year})"
          else
            summary = "#{artist_name} - #{location}"
          end

          uid = "#{dtstart}-#{artist_slug}-#{venue_slug}@fullofwishes.co.uk"
          url = "#{base_url}/#{artist_slug}/shows/#{show_slug}/"

          lines << "BEGIN:VEVENT"
          lines << "DTSTART;VALUE=DATE:#{dtstart}"
          lines << "DTEND;VALUE=DATE:#{dtstart}"
          lines << fold("SUMMARY:#{escape_ics(summary)}")
          lines << fold("LOCATION:#{escape_ics(location)}") unless location.empty?
          lines << fold("URL:#{url}")
          lines << fold("UID:#{uid}")
          lines << "DTSTAMP:#{build_dts}"
          lines << "RRULE:FREQ=YEARLY" if is_past
          lines << "END:VEVENT"
        end
      end

      # ----------------------------------------------------------------
      # Anniversaries
      # ----------------------------------------------------------------
      anniversaries = site.data["ahfow-anniversaries"]
      if anniversaries.is_a?(Array)
        anniversaries.each do |entry|
          month_day = entry["month_day"].to_s.strip
          next if month_day.empty?

          title  = entry["title"].to_s.strip
          next if title.empty?

          year   = entry["year"].to_s.strip
          notes  = entry["notes"].to_s.strip

          # Use the known year as the DTSTART base, or 1900 if unknown
          base_year = year.empty? ? "1900" : year
          dtstart   = "#{base_year}#{month_day.delete("-")}"

          summary = year.empty? ? title : "#{title} (#{year})"
          uid     = "#{month_day}-#{slugify(title)}@fullofwishes.co.uk"

          lines << "BEGIN:VEVENT"
          lines << "DTSTART;VALUE=DATE:#{dtstart}"
          lines << "DTEND;VALUE=DATE:#{dtstart}"
          lines << fold("SUMMARY:#{escape_ics(summary)}")
          lines << fold("DESCRIPTION:#{escape_ics(notes)}") unless notes.empty?
          lines << fold("UID:#{uid}")
          lines << "DTSTAMP:#{build_dts}"
          lines << "RRULE:FREQ=YEARLY"
          lines << "END:VEVENT"
        end
      end

      lines << "END:VCALENDAR"

      # Write as a Jekyll page
      site.pages << IcsFeedPage.new(site, lines.join("\r\n") + "\r\n")

      Jekyll.logger.info "IcsFeedGenerator:", "Generated /ahfow.ics"
    end

    private

    # ICS line folding: max 75 octets, continuation lines start with a space
    def fold(line)
      return line if line.bytesize <= 75
      result = []
      while line.bytesize > 75
        chunk = line.byteslice(0, 75)
        # avoid splitting a multi-byte character
        chunk = chunk.chars.first(75).join
        result << chunk
        line = " " + line[chunk.length..]
      end
      result << line
      result.join("\r\n")
    end

    def escape_ics(str)
      str.to_s.gsub("\\", "\\\\").gsub("\n", "\\n").gsub(",", "\\,").gsub(";", "\\;")
    end

    def slugify(str)
      str.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    end
  end

  class IcsFeedPage < Page
    def initialize(site, content)
      @site    = site
      @base    = site.source
      @dir     = ""
      @name    = "ahfow.ics"
      process(@name)
      @data    = { "layout" => nil, "sitemap" => false }
      @content = content
      @output  = content
    end
  end
end
