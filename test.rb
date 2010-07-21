# -*- coding: undecided -*-
require 'ikiw'
require 'spec'
require 'rack/test'

set :environment, :test

module Storage

  def self.last_key
    @last_key
  end

  def self.last_value
    @last_value
  end

  def self.[](key)
    @last_key = key
    {'title' => "title of #{key}", 'content' => "content of #{key}"}
  end

  def self.[]=(key, value)
    @last_key = key
    @last_value = value
  end

  def self.reset
    @last_key = nil
    @last_value = nil
  end

end

describe 'ikiw' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'gets /' do
    Storage.reset
    get '/'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/index'
    Storage.last_value.should be_nil

    Storage.reset
    get '/index.html'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/index'
    Storage.last_value.should be_nil

    Storage.reset
    get '/.html'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

  it 'puts /' do
    Storage.reset
    put '/', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 201
    Storage.last_key.should == '/index'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/index', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 201
    Storage.last_key.should == '/index'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/'
    last_response.status.should == 201
    Storage.last_key.should == '/index'
    Storage.last_value.should be_nil # erase

    Storage.reset
    put '/', :title => 'TITLE'
    last_response.status.should == 422
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil

    Storage.reset
    put '/.html', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

  it 'gets /foo' do
    Storage.reset
    get '/foo'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/foo'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo.html'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/foo'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo.json'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/json}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/foo'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo.bar'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo.bar.baz'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/'
    last_response.should be_ok
    Storage.last_key.should == '/foo/index'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/index'
    last_response.should be_ok
    Storage.last_key.should == '/foo/index'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/.html'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

  it 'puts /foo' do
    Storage.reset
    put '/foo', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 201
    Storage.last_key.should == '/foo'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/foo.html', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 405
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil

    Storage.reset
    put '/foo/', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 201
    Storage.last_key.should == '/foo/index'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/foo/index', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 201
    Storage.last_key.should == '/foo/index'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/foo/.html', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

  it 'gets /foo/bar/baz' do
    Storage.reset
    get '/foo/bar/baz'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/bar/baz.html'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/bar/baz.json'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/json}
    last_response.body.should_not be_empty
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/bar.html/baz'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

  it 'puts /foo/bar/baz' do
    Storage.reset
    put '/foo/bar/baz', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 201
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/foo/bar/baz.html', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 405
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil

    Storage.reset
    put '/foo/bar.html/baz', :title => 'TITLE', :content => 'CONTENT'
    last_response.status.should == 404
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

  it 'gets json' do
    Storage.reset
    header 'Accept', 'application/json'
    get '/foo/bar/baz'
    last_response.status.should == 200
    last_response.content_type.should =~ %r{^application/json}
    body = last_response.body
    JSON.parse(body).should == {
      'title' => 'title of /foo/bar/baz',
      'content' => 'content of /foo/bar/baz',
    }
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil

    Storage.reset
    header 'Accept', 'application/xhtml+xml'
    get '/foo/bar/baz.json'
    last_response.status.should == 200
    last_response.content_type.should =~ %r{^application/json}
    body = last_response.body
    JSON.parse(body).should == {
      'title' => 'title of /foo/bar/baz',
      'content' => 'content of /foo/bar/baz',
    }
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil
  end

  it 'puts json' do
    Storage.reset
    data = '{"title": "TITLE", "content": "CONTENT"}'
    header 'Content-Type', 'application/json'
    header 'Content-Length', data.length
    put '/foo/bar/baz', {}, :input => data
    last_response.status.should == 201
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    data = '{"title": "TITLE", "content": "CONTENT"}'
    header 'Content-Type', 'application/x-www-form-urlencoded'
    header 'Content-Length', data.length
    put '/foo/bar/baz', {}, :input => data
    last_response.status.should == 201
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil # data isn't be read

    Storage.reset
    data = '{"title": "TITLE", "content": "CONTENT"}'
    header 'Content-Type', 'application/json'
    header 'Content-Length', data.length
    put '/foo/bar/baz.json', {}, :input => data
    last_response.status.should == 201
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    data = '{"title": "TITLE", "content": "CONTENT"}'
    header 'Content-Type', 'application/x-www-form-urlencoded'
    header 'Content-Length', data.length
    put '/foo/bar/baz.json', {}, :input => data
    last_response.status.should == 400
    Storage.last_key.should be_nil
    Storage.last_value.should be_nil
  end

end
