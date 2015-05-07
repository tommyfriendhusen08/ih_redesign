# we need to ensure we're running in bundler
begin
  Bundler
rescue
  abort("Make sure you're running 'bundle exec middleman'. If you are and still getting this error, config.rb needs attention.")
end

### 
# Compass
###

# Susy grids in Compass
# First: gem install compass-susy-plugin
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Haml
###

# CodeRay syntax highlighting in Haml
# First: gem install haml-coderay
# require 'haml-coderay'

# CoffeeScript filters in Haml
# First: gem install coffee-filter
# require 'coffee-filter'

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

###
# Page command
###

# Per-page layout changes:
# 
# With no layout
# page "/path/to/file.html", :layout => false
# 
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
# 
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
  def custom_or_default_content(thingy)
      if content_for?(thingy)
        yield_content(thingy)
      else
        data.site.send(thingy) || ''
      end
  end
end

activate :syntax

# Change the CSS directory
# set :css_dir, "alternative_css_directory"

# Change the JS directory
# set :js_dir, "alternative_js_directory"

# Change the images directory
# set :images_dir, "alternative_image_directory"

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
   activate :minify_css
  
  # Minify Javascript on build
   activate :minify_javascript
  
  # Enable cache buster
   activate :cache_buster
  
  # Use relative URLs
  activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end

activate :directory_indexes
page "/404.html", :directory_index => false

require 'susy'

# Methods defined in the helpers block are available in templates
helpers do
  # Calculate the years for a copyright
  def copyright_years(start_year)
    end_year = Date.today.year
    if start_year == end_year
      start_year.to_s
    else
      start_year.to_s + '-' + end_year.to_s
    end
  end
end

require 'lib/aws_buckets'

def sekrets
  @sekrets ||= (
    key = IO.read('.sekrets.key').strip rescue nil
    Sekrets.settings_for('./config/sekrets.yml.enc', :key => key)
  )
end

def settings
  @settings ||= (
    Map.for(sekrets.aws)
  )
end

begin
  AWS.config({
    :access_key_id     => settings.access_key_id,
    :secret_access_key => settings.secret_access_key,
    :region            => settings.region
  })

  bucket_name         = settings.bucket

  unless bucket_name.blank?
    AWSBuckets.create_unless_exists!(AWS::S3, bucket_name)

    #FIXME: configure bucket for static site hosting through API

    s3                  = AWS::S3.new(:s3_endpoint => 's3.amazonaws.com')
    location_constraint = s3.buckets[bucket_name].location_constraint
    endpoint            = ['s3', location_constraint].compact.join('-') + '.amazonaws.com'
    bucket              = AWS::S3.new(:s3_endpoint => endpoint).buckets[bucket_name]

    bucket.cors = {
      :allowed_origins => %w'*',
      :allowed_methods => %w'GET POST PUT',
      #:allowed_headers => %w'origin accept x-requested-with content-type',
      :allowed_headers => %w'*',
      #:max_age_seconds => 3600,
    }

    bucket.cors.each do |rule|
      #p rule
    end

    #object = bucket.objects['pages/assets.js']
  end
rescue Exception => e
  puts "Error initializing AWS: #{e}"
end

# Activate sync extension
activate :s3_sync do |sync|
  sync.bucket =  settings.bucket # Your bucket name
  sync.region = settings.region # The region your storage bucket is in (eg us-east-1, us-west-1, eu-west-1, ap-southeast-1 )
  sync.aws_access_key_id = settings.access_key_id # Your Amazon S3 access key
  sync.aws_secret_access_key = settings.secret_access_key # Your Amazon S3 access secret
  sync.delete = true # Do not delete when sync'ing
  sync.after_build = false # Disable sync to run after Middleman build ( defaults to true )
  sync.prefer_gzip = true
end

default_caching_policy max_age:(60 * 60 * 24 * 365)
caching_policy 'text/html', max_age:0, must_revalidate: true, no_cache: true
