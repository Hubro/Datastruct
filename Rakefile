
desc "Runs the test suite"
task :test do
  exec "ruby", "-I", "lib",
    "-r", "minitest/autorun",
    "-r", "mocha/setup",
    "-r", "datastruct",
    "test/datastruct_test.rb"
end

desc "Builds the gem into pkg/"
task "build" do |t|
  system("mkdir -p pkg")
  system("gem build datastruct.gemspec")
  system("mv datastruct-*.gem pkg")
end

task :default do
  Rake::Task["test"].invoke
end
