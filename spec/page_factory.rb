require File.expand_path('spec_helper', File.dirname(__FILE__))

module PageFactory
  include TempFileHelper

  def create_file(name, content, metadata = {})
    path = File.join(TEMP_DIR, name)
    metatext = metadata.map { |key, value| "#{key}: #{value}" }.join("\n")
    contents =<<-EOF
#{metatext}

#{content}
EOF
    File.open(path, 'w') { |file| file.write(contents) }
  end

  def create_page(name, content, metadata = {})
    create_file(name, content, metadata)
    Spandex::Page.from_filename(name, :base_path => TEMP_DIR)
  end

end
