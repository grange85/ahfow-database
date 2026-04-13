require 'csv'

module Jekyll
  class CSVLookupTag < Liquid::Tag
    def initialize(tag_name, input, tokens)
      super
      # Splits the input: "products.csv slug price"
      @matches = /^(?<full_slug>(?<artist_slug>[-a-z]*)-.*$)/.match(input.strip)
      @artist_slug = @matches['artist_slug']
      @show_slug = @matches['full_slug']
      @file_name = @artist_slug.to_s + '-shows.csv'
      @target_cols = 'artistname,date,venue,city,state.country'.split(',')
    end

    def render(context)
      # Get the slug value from the page variables (e.g., page.slug)
      # Or pass a raw string
      slug_to_find = @show_slug
      
      site = context.registers[:site]
      file_path = File.join(site.source, '_data/gigography/', @file_name)

      if File.exist?(file_path)
        CSV.foreach(file_path, headers: true) do |row|
          if row['show-slug'] == slug_to_find
            return @target_cols.each_with_object({}) { |col, hash| hash[col] = row[col] }
          end
        end
        return 'blah'
      end

      "Data not found" + file_path.to_s
    end
  end
end

Liquid::Template.register_tag('get_csv_data', Jekyll::CSVLookupTag)
