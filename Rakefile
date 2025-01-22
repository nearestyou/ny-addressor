require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
  t.libs << "test"
end

desc "Run all tests"
task default: :test
