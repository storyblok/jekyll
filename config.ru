require 'rack/jekyll'
require 'jekyll'
require 'yaml'
require 'fileutils'

class Rebuilder
  def self.call(env)
    # Remove the _site folder
    FileUtils.rm_rf("./_site/.", secure: true)

    # Load Jekyll config
    conf = Jekyll.configuration(:source => './', :destination => './_site')

    # Actually rebuild the site
    Jekyll::Site.new(conf).process

    # return a success
    [200, { "Content-Type" => "text/plain" }, ["OK"]]
  end
end

app = Rack::Builder.new do
  map "/rebuild" do
    run Rebuilder
  end

  map "/" do
    run Rack::Jekyll.new(:auto => true, :source => './', :destination => './_site')
  end
end

run app