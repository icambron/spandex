require 'pathname'
require 'atom'

module Spandex
  class Finder

    class CaseInsensitiveHash < Hash
      def [](key)
        super(key.to_s.downcase)
      end
    end

    def initialize(base_dir, render_options = {})
      @base_dir = base_dir
      @render_options = render_options
    end

    def get(path)
      path = Page.pathify path
      load(Page.file_from_path(path, @base_dir), path)
    end

    def get_by_filename(filename)
      load(filename)
    end

    def all_pages
      roots = []
      @pages ||= CaseInsensitiveHash.new
      Dir.glob(File.join(@base_dir, "**/*"))
        .map{|path| Page.pathify(path)}
        .select{|path| Page.registered?(path)}
        .each{|path| load(path)}
      @pages.values
    end

    def all_articles
      all_pages
        .select{|page| page.date}
        .sort {|x, y| y.date <=> x.date }
    end

    def find_pages(conditions)
      find_inside(all_pages, conditions)
    end

    def find_articles(conditions)
      find_inside(all_articles, conditions)
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
      key = key.to_s
      return nil unless filename && key && File.exists?(filename)
      if @pages && @pages[key] && File.mtime(filename) < @pages[key].mtime
        @pages[key]
      else
        @pages ||= CaseInsensitiveHash.new
        page = Page.from_filename(filename, @base_dir, @render_options)
        @pages[key] = page
        page
      end
    end

    def find_inside(xs, conditions = {}) 
      output = xs
      conditions.each do |k, v|
        next unless v
        cond = case k
               when :tag then lambda {|p| p.tags.include?(v) }
               when :title then lambda {|p| p.title.match(v)}
               else lambda{|p| true}
               end
        output = output.select(&cond)
      end
      output
    end
    
  end
end
