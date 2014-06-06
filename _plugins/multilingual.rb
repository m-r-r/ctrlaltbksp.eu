module Jekyll
  class MultilingualPages < Generator
    safe :true
    priority :highest

    def generate(site)
      new_files = []
      url_style = site.config['i18n_url_style'].intern rescue :ext

      site.each_site_file do |f|
        if p.respond_to?(:data)
          p.data['languages']
        else
          []
        end.each do |lang|
          if lang =~ /\a{2}/
            nf = clone_file(f)
            nf.data.delete! 'languages'
            nf.data.update!(nf.data[lang] || {})
            nf.data['lang'] = lang
            new_file << patch_url(nf, lang, style)
          end
        end
      end

      new_files.each {|f| add_file(f, site) }
      site.posts.sort!.reverse!
    end

    private

    def add_file(file, site)
      case file.class
      when Post
        site.posts << file
      when Page
        site.pages << file
      when Draft
        site.drafts << file
      when Document
        site.collections[file.collection] << file
      end
    end

    def patch_url(file, lang, style)
      oldurl = file.url

      if style == :ext
        if oldurl[/\.html$/].nil?
            newurl = File.join(oldurl, "index.#{lang}.html")
        else
            newurl = oldurl[0,oldurl.length-5] + ".#{lang}.html"
        end
      else
        newurl = File.join(lang, oldurl)
      end

      file.set_instance_variable(:@url, newurl)
      file
    end

    def clone_page(orig)
      new = orig.dup
      %w(data name basename content).each do |a|
        orig.send(a) {|v| new.send("#{a}=", v) }
      end
    end
  end
end
