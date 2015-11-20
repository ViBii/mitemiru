# coding: utf-8

Dir.glob(File.join(Rails.root, 'db', 'seeds', '*.rb')) do |file|
  load(file)
end
