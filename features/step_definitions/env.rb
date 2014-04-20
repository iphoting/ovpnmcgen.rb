Given /^I set the environment variable "(\w+)" to "([^"]*)"$/ do |var, value|
  ENV[var] = value
end