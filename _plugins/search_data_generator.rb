require 'csv'

module Jekyll
  class SearchDataGenerator < Generator
    safe true
    priority :highest

    def generate(site)
      search_data = {
        'releases' => [],
        'shows' => [],
        'tracks' => []
      }

      # Collect releases from collections
      site.collections.each do |name, collection|
        collection.docs.each do |doc|
          if doc.data['layout'] == 'discog'
            search_data['releases'] << {
              'title' => "RELEASE #{doc.data['title']}",
              'url' => "/database#{doc.url}",
              'date' => doc.data['date']&.to_s || ''
            }
          end
        end
      end

      # Parse tracks from CSV
      tracks_file = File.join(site.source, '_data', 'discography', 'tracks.csv')
      if File.exist?(tracks_file)
        CSV.foreach(tracks_file, headers: true) do |row|
          if row['title'].to_s.strip.length > 0
            track_url = row['slug'] ? "/database/tracks/#{row['slug']}/" : ''
            search_data['tracks'] << {
              'title' => "TRACK: #{row['title']}",
              'slug' => row['slug'] || '',
              'url' => track_url
            }
          end
        end
      end

      # Parse shows from CSV files
      gigography_dir = File.join(site.source, '_data', 'gigography')
      Dir.glob("#{gigography_dir}/*-shows.csv").each do |csv_file|
        CSV.foreach(csv_file, headers: true) do |row|
          if row['date'].to_s.strip.length > 0 && row['slug'].to_s.strip.length > 0
            # Determine artist from filename
            filename = File.basename(csv_file, '.csv')
            artist_slug = filename.gsub('-shows', '')

            # Construct show slug same as jekyll-datapage-generator:
            # record['slug'] + "-" + date + disambiguate + "-" + venue-slug
            date_str = Date.parse(row['date']).strftime('%Y-%m-%d') rescue row['date']
            disambiguate = row['disambiguate'].to_s.strip
            show_slug = "#{row['slug']}-#{date_str}#{disambiguate}-#{row['venue-slug']}"
            show_url = "/database/#{artist_slug}/shows/#{show_slug}/"
            # puts row['state'].inspect
            location = [row['city'], row['state'], row['country']].compact.join(', ')
            # location = [row['city'], row['state'], row['country']].select { |v| v.to_s.strip != '' }.join(', ')
            search_data['shows'] << {
              'title' => "SHOW: #{row['artistname']} - #{row['venue']}, #{location} - #{row['date']}",
              'artist_slug' => artist_slug,
              'url' => show_url
            }
          end
        end
      end

      # Store in site.data for use in search.json
      site.data['search_index'] = search_data

      # Also write directly to _site/search.json
      output_file = File.join(site.dest, 'search.json')
      FileUtils.mkdir_p(File.dirname(output_file))

      merged_search = search_data['releases'] + search_data['shows'] + search_data['tracks']
      File.write(output_file, JSON.pretty_generate(merged_search))

      Jekyll.logger.info("Search Data Generated:", "Releases: #{search_data['releases'].length}, Shows: #{search_data['shows'].length}, Tracks: #{search_data['tracks'].length}")
    end
  end
end
