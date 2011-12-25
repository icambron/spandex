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
      paths = Pathname.glob(File.join(@base_dir, "#{path}.*"))
      file = paths.select{|path| Page.registered?(path)}.first
      load(file, path)
    end

    def get_by_filename(filename)
      load(filename)
    end

    def all_pages
      roots = []
      @pages ||= CaseInsensitiveHash.new
      Dir.glob(File.join(@base_dir, "**/*"))
        .map{|path| Pathname.new(path)}
        .select{|path| Page.registered?(path)}
        .each{|path| load(path)}
      @pages.values
    end

    def all_articles(include_drafts = false)
      find_articles(:include_drafts => include_drafts)
    end

    def find_articles(conditions)
      #require dates - definition of articles
      real_conds = {:has_date => true}
      
      #by default, don't include drafts
      real_conds[:draft] = false unless conditions[:include_drafts]
      real_conds.merge!(conditions.reject{|k| k == :include_drafts})

      #articles should be sorted by date descending
      find_pages(real_conds).sort {|x, y| y.date <=> x.date }
    end

    def find_pages(conditions)
      output = all_pages
      conditions.each do |k, v|
        next if v.nil?
        cond = case k
               when :has_date then lambda {|p| p.date}
               when :draft then lambda {|p| p.draft? == v}
               when :tag then lambda {|p| p.tags.include?(v) }
               when :title then lambda {|p| p.title.match(v)}
               else lambda{|p| true}
               end
        output = output.select(&cond)
      end
      output
    end

    def tags
      @tags ||= all_pages.map{|p| p.tags}.flatten.uniq
    end

    def atom_feed(count, title, author, root, path_to_xml)
      articles = all_articles.take(count)
      Atom::Feed.new do |f|
        f.id = root
        f.title = title
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
  end
end
