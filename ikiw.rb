# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'msgpack'

module Storage

  def self.get_path(key)
    filename = [key].pack('m').tr('+/', '-_').gsub("\n", '')
    p filename
    File.dirname(__FILE__) + '/data/' + filename
  end

  def self.[](key)
    path = get_path(key)
    if File.exist?(path)
      MessagePack.unpack(open(path, 'rb'){|fp| fp.read})
    else
      nil
    end
  end

  def self.[]=(key, value)
    path = get_path(key)
    if value
      open(path, 'wb'){|fp| fp.write(value.to_msgpack)}
    else
      File.delete(path)
    end
  end

end

class Page
  attr_accessor :title
  attr_accessor :content

  def initialize(title, content)
    @title = title
    @content = content
  end

  def to_msgpack
    {
      :title   => title,
      :content => content,
    }.to_msgpack
  end

end

helpers do

  def storage
    Storage
  end

end

get '/stylesheets/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get /^([^.]+)(\.([^.\/]+?))?$/ do
  path = params[:captures][0]
  ext = params[:captures][2] || 'html'
  mime_type = {
    'html' => 'application/xhtml+xml',
    'json' => 'application/json',
  }[ext]
  return 404 unless mime_type
  return 404 if (path[-1].chr == '/' and params[:captures][2])
  key = path.sub(/\/$/, '/index')
  data = storage[key] || {}
  page = Page.new(data["title"] || '', data["content"] || '')

  content_type mime_type, :charset => 'utf-8'
  case ext
  when 'html'
    haml :page, :locals => {:page => page}
  when 'json'
    '{}' # TODO: JSONize
  end
end

put /^([^.]+)(\.([^.\/]+?))?$/ do
  path = params[:captures][0]
  return path[-1].chr == '/' ? 404 : 405 if params[:captures][2]
  key = path.sub(/\/$/, '/index')
  return 422 if !params[:title] ^ !params[:content]
  if params[:title] and params[:content]
    storage[key] = Page.new(params[:title], params[:content])
  else
    storage[key] = nil
  end
  headers 'Location' => request.url
  201
end
