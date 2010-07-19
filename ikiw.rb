# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'msgpack'

module Storage

  def self.get_path(key)
    filename = [key].pack('m').tr('+/', '-_')
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

  def to_h
    {
      :title   => title,
      :content => content,
    }
  end

  def to_msgpack
    to_h.to_msgpack
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
  mime_type = case ext
              when 'html'
                'application/xhtml+xml'
              when 'json'
                'application/json'
              end
  return 404 unless mime_type
  if (path[-1].chr == '/' and params[:captures][2])
    return 404
  end
  if path == '/'
    key = path
  else
    key = path.sub(/\/$/, '')
  end
  data = storage[key] || {}
  page = Page.new(data["title"] || '', data["content"] || '')

  content_type mime_type, :charset => 'utf-8'
  haml :page, :locals => {:page => page}
end

put /^([^.]+)(\.([^.\/]+?))?$/ do
  path = params[:captures][0]
  if params[:captures][2]
    if path[-1].chr == '/'
      return 404
    else
      return 405
    end
  end
  if path == '/'
    key = path
  else
    key = path.sub(/\/$/, '')
  end
  if params[:title] and params[:content]
    storage[key] = Page.new(params[:title], params[:content])
  elsif !params[:title] and !params[:content]
    storage[key] = nil
  else
    return 422
  end
  headers 'Location' => request.url
  201
end
