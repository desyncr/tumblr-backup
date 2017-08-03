#!/usr/bin/env ruby
require 'dotenv'
require 'tumblr_client'
require 'json'
require 'pry'
require 'open-uri'
require 'ruby-progressbar'
require 'whirly'
require 'fileutils'

Dotenv.load

Tumblr.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.oauth_token = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

# disable downloads
@enable_downloads = ENV['ENABLE_DOWNLOAD'] || true

@download_path = "./dumps/#{ENV['TUMBLR_URL']}"

# the hash to be saved into JSON file
@postsHash = {}

# offset count for pagination
@posts_offset = 0

def request_posts (offset)
  client = Tumblr::Client.new
  client.posts(ENV['TUMBLR_URL'], :offset => offset)
end

# initial request
@posts_whole = request_posts(@posts_offset)

# save total post count
@total_posts_count = @posts_whole['total_posts']

# setup progressbar!
@progressbar = ProgressBar.create(
  :title => "Posts Backed Up",
  :total => @total_posts_count,
  :format => '  %p%% (%c/%C) %t'
)

# track progress
@saved_posts_count = 0

# tumblr limits responses to 20 posts
@tumblr_response_limit = 20

# set posts to process
@posts = @posts_whole['posts']

# timeout (in seconds) for photo downloads
@request_timeout = 60

def download(url, path)
  return if File.exists? "#{path}"

  File.open(path, 'wb') do |f|
    f.write open(url, :read_timeout => @request_timeout).read
  end
end

def download_photo(url)
  filename = url.split('/')[4]
  download url, "#{@download_path}/#{filename}"
end

def download_video(url)
  filename = url.split('/')[3]
  download url, "#{@download_path}/#{filename}"
end

def extract_filename(photo_url)
  filename_regex = /[^\/]*$/
  filename_regex.match(photo_url)
end

def process_photos(photos)
  photos.each do |photo, index|
    if @enable_downloads
      download_photo(photo['original_size']['url'])
    end
  end
end

def process_video(post)
  video_url = ''
  if post['video_url'].nil?
    video_url = post['permalink_url']
  else
    video_url = post['video_url']
    if @enable_downloads
      download_video(video_url)
    end
  end

  video_url
end

def process_posts(posts)
  posts.each do |post|
    post_type = post['type']

    @postsHash[post['id']] = post

    if post_type == 'photo'
      process_photos(post['photos'])
    elsif post_type == 'video'
      process_video(post)
    end

    @saved_posts_count += 1

    @progressbar.increment

    if @saved_posts_count == @posts_offset + @tumblr_response_limit
      @posts_offset += @tumblr_response_limit
      request_next_page(@posts_offset)
    elsif @saved_posts_count == @total_posts_count
      Whirly.stop
      posts_to_json(@postsHash)
      return
    end
  end

end

def request_next_page(offset)
  @next_page = request_posts(offset)
  process_posts(@next_page['posts'])
end

def posts_to_json(hash)
  File.open("#{@download_path}/#{ENV['TUMBLR_URL']}.json", 'w') do |f|
    f.write(JSON.pretty_generate(hash))
  end
end

# Let's begin!
Whirly.start(:spinner => 'pencil')

FileUtils.mkdir_p @download_path if File.exists? @download_path
process_posts(@posts)

