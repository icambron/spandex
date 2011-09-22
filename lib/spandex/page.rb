require 'time'
require 'pathname'
require 'tilt'
require 'atom'

module Spandex
  class Page
    attr_reader :filename, :mtime, :base_path, :extension

    def self.from_path(path, options)
      glob = "#{path}.*"
      glob = File.join(options[:base_path], glob) if options[:base_path]
      paths = Pathname.glob(glob)
      path_name = paths
        .select{|path| Tilt.registered?(path.extname.sub(/^./, ''))}
        .first
      if path_name
        metadata, content = parse_file("#{path}#{path_name.extname}", options)
        Page.new(path, content, path_name.extname, metadata, options)
      else nil
      end
    end

    def self.from_filename(filename, options)
      path_name = Pathname.new(filename)
      path = path_name.sub_ext('')

      metadata, content = parse_file(filename, options)

      Page.new(path, content, path_name.extname, metadata, options)
    end
    
    def title
      metadata("title") || "(Unknown Title)"
    end
    
    def date
      @date ||= metadata("date") ? DateTime.parse(metadata("date")) : nil
    end
    
    def body
      @rendered_body ||= Tilt[@extension].new{@content}.render
    end
    
    def tags
      @tags ||= metadata("tags", "categories") ? metadata("tags", "categories").split(",").map{|tag| tag.strip} : []
    end
    
    def to_atom_entry(root)
      unless date
        raise "Must have a date"
      end

      Atom::Entry.new do |entry|
        entry.title = title
        entry.updated = date
        entry.id = "#{root},#{@path}"
        entry.links << Atom::Link.new(:href => "http://#{root}/#{@path}")
        entry.content = Atom::Content::Html.new(body)
      end
    end
    
    private

    def initialize(path, content, extension = "md", metadata = {}, options = {})
      @path = path
      @content = content
      @metadata = metadata
      @extension = extension.sub(/^./, '')
      @mtime = Time.now
    end
  
    def metadata(*keys)
      keys.each do |key|
        return @metadata[key] if @metadata.has_key? key
      end
    end
    
    def self.parse_file(filename, options)
      def self.metadata?(text)
        text.split("\n").first =~ /^[\w ]+:/
      end
      
      base_path = options[:base_path] || "content"

      contents = File.open(File.join(base_path, filename)).read
      
      first_paragraph, remaining = contents.split(/\r?\n\r?\n/, 2)
      metadata = {}
      if metadata?(first_paragraph)
        first_paragraph.split("\n").each do |line|
          key, value = line.split(/\s*:\s*/, 2)
          metadata[key.downcase] = value.chomp
        end
      end
      markup = metadata?(first_paragraph) ? remaining : contents
      return metadata, markup
    end
  end
end
