module Jekyll

  class MultilingualPages < Generator
    safe :true
    priority :highest

    def generate(site)
      @site = site
      @default_language = site.config["lang"] || "en"
      new_files = []

      site.each_site_file do |file|
        if (file.is_a? Page or file.is_a? Post or file.is_a? Document) \
            and file.data.key? 'languages'
          languages = file.data['languages']
          alternates = []

          if languages.is_a? Array
            languages = Proc.new do |hash|
              languages.map {|lang| hash[lang] = Hash.new}
              hash
            end.call({})
          end

          languages.each_pair do |lang, localized_data|
            if lang =~ /^[a-z]{2}$/i
              new_file = new_file(site, file, /#{@default_language}/i !~ lang ? lang : nil)
              new_file.data.delete 'languages'
              new_file.data.update localized_data if localized_data.is_a? Hash
              new_file.data['lang'] = lang
              new_file.data['permalink'] = make_permalink(file, lang)

              new_files << new_file
              alternates << new_file
            end
          end

          alternates.each do |alt|
            alts = {}
            alternates.each {|a| alts[a.data['lang']] = a}
            alts.delete alt.data['lang']
            alt.data['translations'] = alts
          end
        end
      end

      new_files.each {|f| add_file(site, f) }
      site.posts.sort!.reverse!
    end

    private

    def add_file(site, file)
      if file.is_a? Draft
        site.drafts << file
      elsif file.is_a? Post
        site.posts << file
      elsif file.is_a? Page
        site.pages << file
      elsif file.is_a? Document
        file.collection << file
      end
    end

    def make_permalink(file, lang)
      url = file.url('') rescue file.url
      if /#{@default_language}/i !~ lang
        url.sub(/(\.\w+)?$/i, ".#{lang}\\0")
      else 
        url
      end.sub(/^#{@site.baseurl}?\/?/i, '/')
    end

    def new_file(site, orig, lang)
      if orig.is_a? Document
        Document.new(orig.path, {:site => site, :collection => orig.collection})
      else
       orig.class.new(site, site.source, orig.dir, orig.name)
      end
    end
  end
end
