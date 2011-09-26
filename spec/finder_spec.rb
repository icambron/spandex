require File.expand_path('page_factory', File.dirname(__FILE__))
require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'spandex'
require 'atom'

describe Spandex::Finder do
  include PageFactory
  include TempFileHelper

  context "when getting all pages" do
  
    it "can find files" do
      finder = Spandex::Finder.new(TEMP_DIR) 
      create_page("lasers.md", "You know it's 18 when you throw your dice.")
      create_page("cheese.textile", "You've climbed that mountain not only once but twice.")
      finder.all_pages.size.should == 2
    end
    
    it "won't find repeated files roots" do
      finder = Spandex::Finder.new(TEMP_DIR) 
      create_page("stuff.md", "Some say you're a loner but I know your kind.")
      create_page("stuff.textile", "It's sad to see that's why I fake that I'm blind.")
      
      finder.all_pages.size.should == 1
    end
    
    it "caches the pages" do
      finder = Spandex::Finder.new(TEMP_DIR) 
      create_page("stuff.md", "It only takes you a minute to show.")
      finder.all_pages
      
      create_page("more_stuff.md", "But you ain't got nothing but an empty soul.")
      finder.all_pages.size.should == 1
      
    end
  end

  context "when getting all articles" do
    
    it "only finds pages with dates" do
      create_page("stuff.md", "You don't float like butterfly or fight like Ali.", :date => "2011/5/25")
      create_page("more_stuff.md", "Dress like Prince but to the lowest degree.")
      
      results = Spandex::Finder.new(TEMP_DIR).all_articles
      results.size.should == 1
      results[0].date.should == Date.civil(2011, 5, 25)
    end

    it "sorts by date descending" do
      create_page("stuff.md", "I like that you can't slow down.", :date => "1986/5/25")
      create_page("more_stuff.md", "Step back! 'Cause you ain't no one.", :date => "1982/5/25") 
      create_page("even_more_stuff.md", "You're living in a lie.", :date => "2011/5/25")

      results = Spandex::Finder.new(TEMP_DIR).all_articles

      results.size.should == 3
      [Date.civil(2011,5,25), Date.civil(1986,5,25), Date.civil(1982,5,25)].each_with_index do |date, i|
        results[i].date.should == date
      end
      
    end
    
  end

  context "when generating an atom feed" do
    
    it "generates real atom content" do
      create_page("stuff.md", "You ain't nothing but a BFI", :date => "1986/5/25", :title => "BFI")
      create_page("more_stuff.md", "Leaving town on a two wheeler while your kids are home", :date => "1982/5/25")

      #generate and then reparse
      feed = Spandex::Finder.new(TEMP_DIR).atom_feed(3, "The Sounds", "sounds.test.org", "articles.xml")
      ratom = Atom::Feed.load_feed(feed)

      ratom.entries.size.should == 2
      ratom.authors.first.name.should == "The Sounds"
      ratom.links.size.should == 2

      e = ratom.entries.first
      e.title.should == "BFI"
    
    end 

    it "should only show the top n articles" do
      create_page("stuff.md", "Giving up your love and life for some silver chrome", :date => "1986/5/25")
      create_page("more_stuff.md", "You're acting like a fool so take my advice.", :date => "1986/5/25")
      create_page("even_more_stuff.md", "It's not so hard to keep your eyes on the price.", :date => "1986/5/25")

      feed = Spandex::Finder.new(TEMP_DIR).atom_feed(2, "The Sounds", "sounds.test.org", "articles.xml")
      ratom = Atom::Feed.load_feed(feed)

      ratom.entries.size.should == 2
    end

    it "only includes pages with dates" do
      create_page("stuff.md", "You don't float like butterfly or fight like Ali.", :date => "2011/5/25")
      create_page("more_stuff.md", "Dress like Prince but to the lowest degree.")

      feed = Spandex::Finder.new(TEMP_DIR).atom_feed(2, "The Sounds", "sounds.test.org", "articles.xml")
      ratom = Atom::Feed.load_feed(feed)

      ratom.entries.size.should == 1
    end
    
  end

  context "when listing tags" do
    
    it "can list tags" do
      create_page("stuff.md", "I like that you can't slow down.", :tags => "Sweedish, New Wave")
      create_page("more_stuff.md", "Step back! 'Cause you ain't no one.", :tags => "Indie Rock") 
      
      tags = Spandex::Finder.new(TEMP_DIR).tags
      tags.should == ["Sweedish", "New Wave", "Indie Rock"]
    end

    it "has unique tags" do
      create_page("stuff.md", "I like that you can't slow down.", :tags => "Sweedish, Indie Rock")
      create_page("more_stuff.md", "Step back! 'Cause you ain't no one.", :tags => "Indie Rock") 
      
      tags = Spandex::Finder.new(TEMP_DIR).tags
      tags.should == ["Sweedish", "Indie Rock"]
    end
  end

  before(:each) do
    create_temp_directory
  end
  
  after(:each) do
    remove_temp_directory
  end
  
end
