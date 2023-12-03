require 'open-uri'

lines = open('input.txt').readlines(chomp: true)

regex = /(?=(one|two|three|four|five|six|seven|eight|nine|\d))/
numbers = %w[one two three four five six seven eight nine]

calibration_values = lines.map do |line|
  first_number = line.scan(regex).first.first
  first_number = numbers.include?(first_number) ? (numbers.index(first_number) + 1).to_s : first_number
  last_number = line.scan(regex).last.first
  last_number = numbers.include?(last_number) ? (numbers.index(last_number) + 1).to_s : last_number
  (first_number+last_number).to_i
end

puts calibration_values.sum