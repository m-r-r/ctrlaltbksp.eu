# Store and render comments as a static part of a Jekyll site
#
# See README.mdwn for detailed documentation on this plugin.
#
# Homepage: http://theshed.hezmatt.org/jekyll-static-comments
#
#  Copyright (C) 2011 Matt Palmer <mpalmer@hezmatt.org>
#  Copyright (C) 2015 Mickaël RAYBAUD-ROIG <raybaudroigm@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 3, as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, see <http://www.gnu.org/licences/>

require 'yaml'

module StaticComments
	# Find all the comments for a post
	def self.find_for_post(post)
		@comments ||= read_comments(post.site.source)
		@comments[post.id]
	end

	# Read all the comments files in the site, and return them as a hash of
	# arrays containing the comments, where the key to the array is the value
	# of the 'post_id' field in the YAML data in the comments files.
	def self.read_comments(source)
		comments = Hash.new() { |h, k| h[k] = Array.new }

		Dir["#{source}/**/_comments/**/*.yml"].sort.each do |comment|
			next unless File.file?(comment) and File.readable?(comment)
			json_data = SafeYAML::load File.new(comment).read
			post_id = json_data.delete('post_id')
			comments[post_id] << json_data
		end
		comments
	end

	def self.reset
		@comments = nil
	end
end

Jekyll::Hooks.register :site, :after_reset do ||
  StaticComments.reset
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  post.data['comments'] = comments = StaticComments::find_for_post(post);
  post.data['comment_count'] = comments.length
end
