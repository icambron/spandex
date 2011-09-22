require File.expand_path('page_factory', File.dirname(__FILE__))
require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'spandex'
require 'atom'

describe Spandex::Page do
  include PageFactory

  content_path = TempFileHelper::TEMP_DIR
  
  it "can have a title" do
    page = create_page("test", "test_content", :title => "hello!")
    page.title.should == "hello!"
  end

  it "can have a tag" do
    page = create_page("test", "test_content", :tags => "lasers")
    page.tags.should have(1).tags
    page.tags[0].should == "lasers"
  end

  it "can have multiple tags" do
    page = create_page("test", "test_content", :tags => "lasers,goats")
    page.tags.should have(2).tags
  end

  it "can parse the body" do
    page = create_page("test", "test_content")
    page.body.should == "<p>test_content</p>\n"
  end

  it "can have a date" do
    page = create_page("test", "test_content", :date => "2011/5/25")
    page.date.should == Date.civil(2011, 5, 25)
  end

  it "produces good atom output" do
    page = create_page("test", "test_content", :title => "hello!", :date => "2011/5/25")
    entry = page.to_atom_entry("http://test.org")
    entry.title.should == "hello!"
  end

  before(:each) do
    create_temp_directory
  end
  
  after(:each) do
    remove_temp_directory
  end
end
