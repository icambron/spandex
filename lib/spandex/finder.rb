require 'pathname'
require 'atom'

module Spandex
  class Finder

    class CaseInsensitiveHash < Hash
      def [](key)
        super(key.to_s.downcase)
      end
    end

    def initialize(base_dir)
      @base_dir = base_dir
    end

    def get(path)
      load(Page.file_from_path(path, @base_dir), path)
    end

    def get_by_filename(filename)
      load(filename)
    end

    def all_pages
      roots = []
      Dir.glob(File.join(@base_dir, "**/*"))
        .map{|path| Pathname.new(path)}
        .each{|path| load(path)}
      @pages.values
    end

    def all_articles
      all_pages
        .select{|page| page.date}
        .sort {|x, y| y.date <=> x.date }
    end

    def tags
      @tags ||= all_pages.map{|p| p.tags}.flatten.uniq
    end

    def atom_feed(count, author, root, path_to_xml)
      articles = all_articles.take(count)
      Atom::Feed.new do |f|
        f.id = root
        f.links << Atom::Link.new(:href => "http://#{root}#{path_to_xml}", :rel => "self")
        f.links << Atom::Link.new(:href => "http://#{root}", :rel => "alternate")
        f.authors << Atom::Person.new(:name => author)
        f.updated = articles[0].date if articles[0]
        articles.each do |post|
          f.entries << post.to_atom_entry(root)
        end  
      end.to_xml
    end

    private

    def load(filename, key = Page.path_from_file(filename, @base_dir))
      return nil unless filename && key && File.exists?(filename)
      if @pages && @pages[key] && File.mtime(filename) < @pages[key].mtime
        @pages[key]
      else
        @pages ||= CaseInsensitiveHash.new
        page = Page.from_filename(filename, @base_dir)
        @pages[key] = page
        page
      end
    end
    
  end
end
