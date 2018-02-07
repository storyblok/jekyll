require "storyblok"

module Jekyll
  class StoryblokPage < Page
    def initialize(site, base, dir, story, links)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      # We will use the root component (eg. content type) as layout
      layout = story['content']['component']

      self.process(@name)
      # Jekyll provides the processed layouts in the site.layouts hash, so we
      # will use it here!
      # This makes it possible to use gem-based Jekyll themes.
      self.data    = site.layouts[layout].data.dup
      self.content = site.layouts[layout].content.dup

      # Assign the received data from the Storyblok API as variables
      self.data['story'] = story
      self.data['title'] = story['name']
      self.data['links'] = links
    end
  end

  class StoryblokPageGenerator < Generator
    safe true

    def generate(site)
      client = ::Storyblok::Client.new(token: 'qR6GM4L0j1w4h2fFZiZ28Qtt', version: 'draft')
      res = client.stories
      stories = res['data']['stories']

      res_links = client.links
      links = res_links['data']['links']

      stories.each do |story|
        site.pages << StoryblokPage.new(site, site.source, story['full_slug'], story, links)

        if story['full_slug'] == 'home'
          site.pages << StoryblokPage.new(site, site.source, '', story, links)
        end
      end
    end
  end
end