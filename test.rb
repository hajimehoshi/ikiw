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
    {'title' => key, 'content' => key}
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
    Storage.last_key.should == '/'
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
    Storage.last_key.should == '/'
    Storage.last_value.title.should == 'TITLE'
    Storage.last_value.content.should == 'CONTENT'

    Storage.reset
    put '/'
    last_response.status.should == 201
    Storage.last_key.should == '/'
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
    Storage.last_key.should == '/foo'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo.html'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    Storage.last_key.should == '/foo'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo.json'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/json}
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
    Storage.last_key.should == '/foo'
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
    Storage.last_key.should == '/foo'
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
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/bar/baz.html'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/xhtml\+xml}
    Storage.last_key.should == '/foo/bar/baz'
    Storage.last_value.should be_nil

    Storage.reset
    get '/foo/bar/baz.json'
    last_response.should be_ok
    last_response.content_type.should =~ %r{^application/json}
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

end
