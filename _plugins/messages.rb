module Jekyll
    class GettextPlugin
        attr_reader :catalogs

        def initialize(site)
            @path = site.config['messages_dir'] || '_messages'
            @default_lang = site.config['lang'] || 'en'
        end

        def catalogs
            @_catalogs ||= Hash.new do |cats, lang|
                cat = Hash.new {|_, msg| msg }

                if lang != @default_lang
                    src = File.join(@path, "#{lang}.yml")
                    begin
                        cat.update SafeYAML.load_file(src)
                    rescue Errno::ENOENT
                        Jekyll.logger.warn "Message catalog for #{lang} not found #{src}."
                    end
                end

                cats[lang] = cat 
            end
        end

        def translate(ctx, msg, *fmt)
            lang = ctx.registers[:page]['lang'] || @default_lang
            msg = catalogs[lang][msg] || msg
            msg.gsub!(/([^%]|^)%\d+/) {|n| fmt[n[1,n.length].to_i-1].to_s }
            msg.sub!('%%', '%')
            msg.to_liquid
        end

        def self.translate(ctx, msg, *fmt)
            @instance ||= self.new(ctx.registers[:site])
            @instance.translate(ctx, msg, *fmt)
        end
    end

    module Tags
        class GettextPluginTag < Liquid::Tag
            def initialize(tag_name, msg, *fmt)
                @msg = msg.to_s.chomp(' ')
                @fmt = fmt
                super
            end

            def render(ctx)
                GettextPlugin.translate(ctx, @msg, *@fmt)
            end
        end
    end

    module Filters
        def gettext(msg, *fmt)
            GettextPlugin.translate(@context, msg.to_s, *fmt)
        end

        alias :t :gettext 
    end
end

Liquid::Template.register_tag('t', Jekyll::Tags::GettextPluginTag)
