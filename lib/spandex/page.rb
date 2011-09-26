require 'time'
require 'pathname'
require 'tilt'
require 'atom'

module Spandex
  class Page
    attr_reader :path, :mtime, :extension, :render_options

    def self.from_path(path, base_path, render_options = {})
      filename = file_from_path(path, base_path)
      if filename
        metadata, content = parse_file(filename)
        Page.new(path, content, filename.extname, metadata, render_options)
      else nil
      end
    end

    def self.from_filename(filename, base_path, render_options = {})
      pathname = Pathname.new(filename)
      return nil unless pathname.exist?

      path = path_from_file(pathname, base_path)
      metadata, content = parse_file(filename)

      Page.new(path, content, pathname.extname, metadata, render_options)
    end

    def self.mtime(path, base_path)
      file = file_from_path(path, base_path)
      if File.exists?(path)
        File.mtime(file) 
      else nil
      end
    end

    def self.file_from_path(path, base_path)
      paths = Pathname.glob(File.join(base_path, "#{path}.*"))
      pathname = paths.select{|path| registered?(path)}.first
    end

    def self.path_from_file(pathname, base_path)
      pathname = pathify(pathname)
      pathname.relative_path_from(pathify(base_path)).sub_ext('')
    end

    def self.registered?(pathname)
      pathname = pathify(pathname)
      Tilt.registered?(pathname.extname.sub(/^./, ''))
    end

    
    def title
      metadata("title") || "(Unknown Title)"
    end
    
    def date
      @date ||= metadata("date") ? DateTime.parse(metadata("date")) : nil
    end
    
    def body
      @rendered_body ||= Tilt[@extension].new(nil, 1, @render_options){@content}.render
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

    def initialize(path, content, extension, metadata, render_options = {})
      @path = path
      @content = content
      @metadata = metadata
      @extension = extension.sub(/^./, '')
      @mtime = Time.now
      @render_options = render_options
    end
  
    def metadata(*keys)
      keys.each do |key|
        return @metadata[key] if @metadata.has_key? key
      end
      nil
    end

    def self.pathify(path_or_string)
      path_or_string.is_a?(String) ? Pathname.new(path_or_string) : path_or_string
    end
    
    def self.parse_file(filename)
      def self.metadata?(text)
        text.split("\n").first =~ /^[\w ]+:/
      end

      contents = File.open(filename).read
      
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
