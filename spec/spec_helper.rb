module TempFileHelper
  TEMP_DIR = File.expand_path('content', File.dirname(__FILE__))

  def create_temp_directory
    FileUtils.mkdir_p(TempFileHelper::TEMP_DIR)
  end

  def remove_temp_directory
    FileUtils.rm_r(TempFileHelper::TEMP_DIR, :force => true)
  end
  
  def temp_path(base)
    File.join(TempFileHelper::TEMP_DIR, base)
  end
end

module PageFactory
  include TempFileHelper

  def create_file(name, metadata = {})
    full_name = File.join(TEMP_DIR, name)
    metatext = metadata
      .select { |key, value| key != :content}
      .map { |key, value| "#{key}: #{value}" }.join("\n")
    content = metadata[:content] ? metadata[:content] : "Some stuff"
    contents =<<-EOF
#{metatext}

#{content}
EOF
    File.open(full_name, 'w') { |file| file.write(contents) }
    full_name
  end

  def create_page(name, metadata = {})
    full_name = create_file(name, metadata)
    Spandex::Page.from_filename(full_name, TEMP_DIR)
  end

end
