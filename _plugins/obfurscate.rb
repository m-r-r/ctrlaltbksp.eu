module Jekyll
    module Filters
        def obfurscate(input, fallback='You must activate JavaScript')
            obfurscated = input.to_s.chars.map {|c| '%x' % c.ord } .join('0x')
            id = (rand * 100).to_i
            "<span class=\"obfurscated\" data-inner=\"#{obfurscated}\">
               #{fallback.strip}
            </span>"
        end
    end
end

