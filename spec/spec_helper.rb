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
