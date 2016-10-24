module Jekyll
  module MultilingualPlugin
    
    def self.localize_data item
      language = item.data['language']
      if language.is_a?(String) and item.data[language].respond_to?(:to_hash) then
        item.data.merge! item.data[language]
      end
    end
    
    def self.add_translations collection
      collection.each do |item|
        translations = self.find_translations collection, item
        item.data['translations'] = translations.map do |translation|
          {
            "url" => translation.url,
            "title" => translation.data['title'],
            "language" => translation.data['language'],
          }
        end
      end
    end
    
    private
    
    def self.find_translations collection, item
      collection.select {|i| i.path == item.path and i.data['language'] != item.data['language']}
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site, payload|
  site.pages.each(&Jekyll::MultilingualPlugin.method(:localize_data))
  site.documents.each(&Jekyll::MultilingualPlugin.method(:localize_data))
end

Jekyll::Hooks.register :site, :pre_render do |site|
  Jekyll::MultilingualPlugin.add_translations site.pages
  Jekyll::MultilingualPlugin.add_translations site.documents
end