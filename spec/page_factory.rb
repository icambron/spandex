require File.expand_path('spec_helper', File.dirname(__FILE__))

module PageFactory
  include TempFileHelper

  def create_file(name, content, metadata = {})
    full_name = File.join(TEMP_DIR, name)
    metatext = metadata.map { |key, value| "#{key}: #{value}" }.join("\n")
    contents =<<-EOF
#{metatext}

#{content}
EOF
    File.open(full_name, 'w') { |file| file.write(contents) }
    full_name
  end

  def create_page(name, content, metadata = {})
    full_name = create_file(name, content, metadata)
    Spandex::Page.from_filename(full_name, TEMP_DIR)
  end

end
