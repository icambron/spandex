require File.expand_path('page_factory', File.dirname(__FILE__))
require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'spandex'
require 'atom'

describe Spandex::Page do
  include PageFactory
  include TempFileHelper

  context "when parsing a file" do
    it "determines the extension" do 
      page = create_page("test.md", "test_content")
      page.extension.should=="md"
    end
    
    it "can have a title" do
      page = create_page("test.md", "test_content", :title => "hello!")
      page.title.should == "hello!"
    end

    it "can have a tag" do
      page = create_page("test.md", "test_content", :tags => "lasers")
      page.tags.should have(1).tags
      page.tags[0].should == "lasers"
    end
    
    it "can have multiple tags" do
      page = create_page("test.md", "test_content", :tags => "lasers,goats")
      page.tags.should == ['lasers', 'goats']
    end

    it "can have multiple tags with weird spacing" do
      page = create_page("test.md", "test_content", :tags => " lasers  , goats ")
      page.tags.should == ['lasers', 'goats']
    end
    
    it "can also have tags called 'categories'" do
      page = create_page("test.md", "test_content", :categories => "lasers,goats")
      page.tags.should have(2).tags
    end

    it "can parse the body" do
      page = create_page("test.md", "test_content")
      page.body.should == "<p>test_content</p>\n"
    end

    it "can have a date" do
      page = create_page("test.md", "test_content", :date => "2011/5/25")
      page.date.should == Date.civil(2011, 5, 25)
    end

    it "can omit the date" do
      page = create_page("test.md", "test_content")
      page.date.should be_nil
    end

    it "produces good atom output" do
      page = create_page("test.md", "test_content", :title => "hello!", :date => "2011/5/25")
      entry = page.to_atom_entry("http://test.org")
      entry.title.should == "hello!"
    end

    it "doesn't have to exist" do
      page = Spandex::Page.from_filename(File.join(TEMP_DIR, "this_is_not_a_file.md"), TEMP_DIR)
      page.should be_nil
    end

  end

  context "when supplying a path with no extension" do

    it "does something" do
      create_file("test.md", "test_content")
      page = Spandex::Page.from_path("test", TEMP_DIR)
      page.should_not be_nil
    end

    it "finds the first file tilt knows" do
      create_file("test.snoogledoobers", "test_content")
      create_file("test.md", "test_content")
      page = Spandex::Page.from_path("test", TEMP_DIR)
      page.extension.should == "md"
    end

    it "doesn't have to exist" do
      page = Spandex::Page.from_path("this/is/not/a/real/file", TEMP_DIR)
      page.should be_nil
    end

  end

  before(:each) do
    create_temp_directory
  end
  
  after(:each) do
    remove_temp_directory
  end
end
