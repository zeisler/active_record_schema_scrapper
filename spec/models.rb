load_after = []
Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |file|
  begin
    require file
  rescue NameError
    load_after << file
  end
end

load_after.each do |file|
  require file
end