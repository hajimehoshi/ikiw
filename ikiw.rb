# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'msgpack'
require 'json'

module Storage

  def self.get_path(key)
    filename = [key].pack('m').tr('+/', '-_').gsub("\n", '')
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

  def to_json
    {
      :title   => title,
      :content => content,
    }.to_json
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

get /\/\./ do
  404
end

get /^([^.]+)(\.([^.\/]+?))?$/ do
  path = params[:captures][0]
  ext = params[:captures][2]
  if ext
    type = ext
  else
    if request.accept.include?('application/xhtml+xml') or
        request.accept.include?('text/html')
      type = 'html'
    elsif request.accept.include?('application/json') or
        request.accept.include?('text/json')
      type = 'json'
    else
      type = 'html'
    end
  end
  mime_type = {
    'html' => 'application/xhtml+xml',
    'json' => 'application/json',
  }[type]
  return 404 unless mime_type
  key = path.sub(/\/$/, '/index')
  data = storage[key] || {}
  page = Page.new(data["title"] || key, data["content"] || '')

  content_type mime_type, :charset => 'utf-8'
  case type
  when 'html'
    haml :page, :locals => {:page => page}
  when 'json'
    page.to_json
  end
end

put /\/\./ do
  404
end

put /^([^.]+)(\.([^.\/]+?))?$/ do
  path = params[:captures][0]
  ext = params[:captures][2]
  return 405 if ext and ext == 'html'
  data = {
    :title   => params[:title],
    :content => params[:content],
  }
  case request.content_type
  when 'application/x-www-form-urlencoded'
    return 400 if ext
  when 'application/json', 'text/json'
    return 400 if ext and ext != 'json'
    json_data = JSON.parse(request.body.string)
    return 422 unless json_data.kind_of?(Hash)
    data = {}
    json_data.each do |key, value|
      data[key.intern] = value
    end
  end
  key = path.sub(/\/$/, '/index')
  return 422 if !data[:title] ^ !data[:content]
  if data[:title] and data[:content]
    storage[key] = Page.new(data[:title], data[:content])
  else
    storage[key] = nil
  end
  headers 'Location' => request.url
  201
end
