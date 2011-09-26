require File.expand_path('page_factory', File.dirname(__FILE__))
require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'spandex'
require 'atom'

describe Spandex::Finder do
  include PageFactory
  include TempFileHelper

  context "when getting all pages" do
  
    it "can find files" do
      create_file("lasers.md", "You know it's 18 when you throw your dice.")
      create_file("cheese.textile", "You've climbed that mountain not only once but twice.")
      make_finder.all_pages.size.should == 2
    end
    
    it "won't find repeated files roots" do
      create_file("stuff.md", "Some say you're a loner but I know your kind.")
      create_file("stuff.textile", "It's sad to see that's why I fake that I'm blind.")
      
      make_finder.all_pages.size.should == 1
    end
    
    it "caches the pages" do
      finder = make_finder
      create_file("stuff.md", "It only takes you a minute to show.")
      finder.all_pages
      
      create_file("more_stuff.md", "But you ain't got nothing but an empty soul.")
      finder.all_pages.size.should == 1
      
    end
  end

  context "when getting all articles" do
    
    it "only finds pages with dates" do
      create_file("stuff.md", "You don't float like butterfly or fight like Ali.", :date => "2011/5/25")
      create_file("more_stuff.md", "Dress like Prince but to the lowest degree.")
      
      results = make_finder.all_articles
      results.size.should == 1
      results[0].date.should == Date.civil(2011, 5, 25)
    end

    it "sorts by date descending" do
      create_file("stuff.md", "I like that you can't slow down.", :date => "1986/5/25")
      create_file("more_stuff.md", "Step back! 'Cause you ain't no one.", :date => "1982/5/25") 
      create_file("even_more_stuff.md", "You're living in a lie.", :date => "2011/5/25")

      results = make_finder.all_articles

      results.size.should == 3
      [Date.civil(2011,5,25), Date.civil(1986,5,25), Date.civil(1982,5,25)].each_with_index do |date, i|
        results[i].date.should == date
      end
      
    end
    
  end

  context "when generating an atom feed" do
    
    it "generates real atom content" do
      create_file("stuff.md", "You ain't nothing but a BFI", :date => "1986/5/25", :title => "BFI")
      create_file("more_stuff.md", "Leaving town on a two wheeler while your kids are home", :date => "1982/5/25")

      #generate and then reparse
      feed = make_finder.atom_feed(3, "The Sounds", "sounds.test.org", "articles.xml")
      ratom = Atom::Feed.load_feed(feed)

      ratom.entries.size.should == 2
      ratom.authors.first.name.should == "The Sounds"
      ratom.links.size.should == 2

      e = ratom.entries.first
      e.title.should == "BFI"
    
    end 

    it "should only show the top n articles" do
      create_file("stuff.md", "Giving up your love and life for some silver chrome", :date => "1986/5/25")
      create_file("more_stuff.md", "You're acting like a fool so take my advice.", :date => "1986/5/25")
      create_file("even_more_stuff.md", "It's not so hard to keep your eyes on the price.", :date => "1986/5/25")

      feed = make_finder.atom_feed(2, "The Sounds", "sounds.test.org", "articles.xml")
      ratom = Atom::Feed.load_feed(feed)

      ratom.entries.size.should == 2
    end

    it "only includes pages with dates" do
      create_file("stuff.md", "You don't float like butterfly or fight like Ali.", :date => "2011/5/25")
      create_file("more_stuff.md", "Dress like Prince but to the lowest degree.")

      feed = make_finder.atom_feed(2, "The Sounds", "sounds.test.org", "articles.xml")
      ratom = Atom::Feed.load_feed(feed)

      ratom.entries.size.should == 1
    end
    
  end

  context "when listing tags" do
    
    it "can list tags" do
      create_file("stuff.md",  "Excuses are all I ever get from you", :tags => "Sweedish, New Wave")
      create_file("more_stuff.md", "And we both know it's true", :tags => "Indie Rock") 
      
      tags = make_finder.tags
      tags.should == ["Sweedish", "New Wave", "Indie Rock"]
    end

    it "has unique tags" do
      create_file("stuff.md", "It's not me, it is you", :tags => "Sweedish, Indie Rock")
      create_file("more_stuff.md", "And nothing matters at all", :tags => "Indie Rock") 
      
      tags = make_finder.tags
      tags.should == ["Sweedish", "Indie Rock"]
    end
  end


  context "loading a specific page" do

    it "does in fact load it" do
      create_file("stuff.md", "It felt so right at the time")
      page = make_finder.get("stuff")
      page.should_not be_nil
    end

    it "finds the first file tilt knows" do
      create_file("stuff.snoogledoobers", "But we lost it all")
      create_file("stuff.md", "You committed a crime")
      page = make_finder.get("stuff")
      page.extension.should == "md"
    end

    it "doesn't have to exist" do
      page = make_finder.get("this/is/not/a/real/file")
      page.should be_nil
    end

  end

  context "when loading by filename" do
    it "does in fact load something" do
      create_file("stuff.md", "And did it matter to you")
      page = make_finder.get_by_filename(File.join(TEMP_DIR, "stuff.md"))
      page.should_not be_nil
    end

    it "doesn't have to exist" do
      page = make_finder.get_by_filename(File.join(TEMP_DIR, "this_is_not_a_file.md"))
      page.should be_nil
    end

  end

  before(:each) do
    create_temp_directory
  end
  
  after(:each) do
    remove_temp_directory
  end

  def make_finder
    Spandex::Finder.new(TEMP_DIR)
  end
  
end
