module CrLogger
  LOG_LEVEL = 3
  def log(message, level = 3)
    puts message if level <= LOG_LEVEL
  end
end

  
