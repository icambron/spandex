require 'time'
require 'tilt'
require 'atom'

module Spandex
  class Page
    attr_reader :filename, :mtime, :base_path

    def initialize(filename, options = {})
      @filename = filename
      @mtime = Time.now
      @extension = options[:extension] || :md
      @metadata, @content = parse_file(options)
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
      @tags ||= metadata("tags", "categories") ? metadata("tags").split(",").map{|tag| tag.strip} : []
    end
    
    def to_atom_entry(root)
      unless date
        raise "Must have a date"
      end

      Atom::Entry.new do |entry|
        entry.title = title
        entry.updated = date
        entry.id = "#{root},#{@filename}"
        entry.links << Atom::Link.new(:href => "http://#{root}/#{@filename}")
        entry.content = Atom::Content::Html.new(body)
      end
    end
    
    private
  
    def metadata(*keys)
      keys.each do |key|
        return @metadata[key] if @metadata.has_key? key
      end
    end
    
    def parse_file(options)
      def metadata?(text)
        text.split("\n").first =~ /^[\w ]+:/
      end
      
      base_path = options[:base_path] || "content"

      contents = File.open(File.join(base_path, "#{filename}.#{@extension}")).read
      
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
