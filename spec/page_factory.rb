require File.expand_path('spec_helper', File.dirname(__FILE__))

module PageFactory
  include TempFileHelper

  def create_page(name, content, metadata = {})
    content_base = TempFileHelper::TEMP_DIR
    path = filename(content_base, name)
    metatext = metadata.map { |key, value| "#{key}: #{value}" }.join("\n")
    contents =<<-EOF
#{metatext}

#{content}
EOF
    File.open(path, 'w') { |file| file.write(contents) }

    Spandex::Page.new(name, :base_path => content_base)
  end

  private

  def filename(directory, basename, extension = :md)
    File.join(directory, "#{basename}.#{extension}")
  end

end
