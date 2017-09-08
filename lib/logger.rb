module CrLogger
  LOG_LEVEL = 4
  def log(message, level = 3)
    puts message if level <= LOG_LEVEL
  end
end

  
