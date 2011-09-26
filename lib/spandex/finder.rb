require 'pathname'
require 'atom'

module Spandex
  class Finder

    def initialize(base_dir)
      @base_dir = base_dir
    end

    def get(path)
      Page.from_path(path, @base_dir)
    end

    def get_by_filename(filename)
      Page.from_filename(filename, @base_dir)
    end

    def all_pages
      unless @pages
        @pages = []
        roots = []
        Dir.glob(File.join(@base_dir, "**/*"))
        .map{|path| Pathname.new(path)}
        .select{|path| Page.registered?(path)}
        .each do |path|
          no_extension = path.sub_ext('')
          unless roots.include?(no_extension)
            roots << no_extension
            @pages << Page.from_filename(path, @base_dir) 
          end
        end
      end
      @pages
    end

    def all_articles
      all_pages
        .select{|page| page.date}
        .sort { |x, y| y.date <=> x.date }
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
    
  end
end
