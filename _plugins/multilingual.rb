module Jekyll
  class MultilingualPages < Generator
    safe :true
    priority :highest

    def generate(site)
      @default_language = site.config["lang"] || "en"
      @url_style = site.config['i18n_url_style'].intern rescue :ext

      new_files = []
      site.each_site_file do |file|
        if file.respond_to? :data and file.data.key? 'languages'
          languages = file.data['languages']

          if languages.is_a? Array
            languages = Proc.new do |hash|
              languages.map {|lang| hash[lang] = Hash.new}
              hash
            end.call({})
          end

          languages.each_pair do |lang, localized_data|
            if lang =~ /^[a-z]{2}$/i
              new_file = new_file(site, file)
              new_file.data.delete 'languages'
              new_file.data.update localized_data if localized_data.is_a? Hash
              new_file.data['lang'] = lang
              new_files << patch_url(new_file, lang)
            end
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

    def patch_url(file, lang)
      return file if lang == @default_language
      oldurl = file.url

      if @url_style == :ext
        if oldurl[/\.html$/].nil?
            newurl = File.join(oldurl, "index.#{lang}.html")
        else
            newurl = oldurl[0,oldurl.length-5] + ".#{lang}.html"
        end
      else
        newurl = File.join(lang, oldurl)
      end

      file.instance_variable_set(:@_url, newurl)
      file.instance_variable_set(:@url, newurl)
      puts "#{file.inspect} #{file.dest}"
      file
    end

    def new_file(site, orig)
      if orig.is_a? Page or orig.is_a? Draft or orig.is_a? Post
        return orig.class.new(site, site.source, orig.dir, orig.name)
      elsif orig.is_a? Document
        return Document.new(orig.path, {:site => site, :collection => orig.collection})
      end
      throw unless false
    end
  end
end
