require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'spandex'
require 'atom'
require 'redcarpet'

describe Spandex::Page do
  include PageFactory
  include TempFileHelper

  context "when parsing a file" do
    it "determines the extension" do 
      page = create_page("test.md", "Oh my love we gotta save ourselves")
      page.extension.should=="md"
    end
    
    it "can have a title" do
      page = create_page("test.md", "If we wanna safe the world", :title => "The Best of Me")
      page.title.should == "The Best of Me"
    end

    it "can have a tag" do
      page = create_page("test.md", "Don't give in to your hate", :tags => "sappy")
      page.tags.should have(1).tags
      page.tags.should == ["sappy"]
    end
    
    it "can have multiple tags" do
      page = create_page("test.md", "When you know you can change", :tags => "sappy,slightly trite")
      page.tags.should == ['sappy', 'slightly trite']
    end

    it "can have multiple tags with weird spacing" do
      page = create_page("test.md", "It's hitting home when you feel so strange", :tags => " sappy  , slightly trite ")
      page.tags.should == ['sappy', 'slightly trite']
    end
    
    it "can also have tags called 'categories'" do
      page = create_page("test.md", "I wanna say those words", :categories => "sappy,slightly trite")
      page.tags.should have(2).tags
    end

    it "can parse the body" do
      page = create_page("test.md", "But it's not that easy")
      page.body.should == Redcarpet::Markdown.new(Redcarpet::Render::HTML).render("But it's not that easy")
    end

    it "pass in rendering options" do
      text = "```\nI smile but it doesn't make things right```"
      create_file("test.md", text)
      page = Spandex::Page.from_filename(File.join(TEMP_DIR, "test.md"), TEMP_DIR, :fenced_code_blocks => true) 
      page.render_options.should have_key(:fenced_code_blocks)
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
      page.body.should == markdown.render(text)
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
  end

  before(:each) do
    create_temp_directory
  end
  
  after(:each) do
    remove_temp_directory
  end
end
