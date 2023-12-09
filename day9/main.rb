require 'open-uri'

lines = open('input.txt').readlines(chomp: true)

Sequence = Struct.new(:numbers) do
  def expansion
    differences = [numbers]
    until differences.last.all? { |x| x == 0 } do
      new_differences = []
      differences.last.each_cons(2) do |pair|
        new_differences << pair[1] - pair[0]
      end
      differences << new_differences
    end
    differences
  end

  def prediction
    rows = expansion.reverse.map { |a| a.dup }
    rows.each_cons(2) do |previous_row, next_row|
      next_row << next_row.last + previous_row.last
    end
    rows.last.last
  end

  def back_prediction
    rows = expansion.reverse.map { |a| a.dup }
    rows.each_cons(2) do |previous_row, next_row|
      next_row.unshift(next_row.first - previous_row.first)
    end
    rows.last.first
  end
end

sequences = lines.map do |line|
  numbers = line.split.map(&:to_i)
  Sequence.new(numbers)
end

puts sequences.map(&:prediction).sum
puts sequences.map(&:back_prediction).sum

# other solutions - part 2 with reverse

sequences = lines.map do |line|
  numbers = line.split.map(&:to_i)
  Sequence.new(numbers.reverse)
end
puts "reverse: #{sequences.map(&:prediction).sum}"

# other solutions - adding up like pascal's triangle

sequences = lines.map do |line|
  numbers = line.split.map(&:to_i)
  Sequence.new(numbers)
end

puts "pascal part 1: #{sequences.map(&:expansion).map { |a| a.map { |a2| a2.last }.sum }.sum}"
puts "pascal part 2: #{sequences.map(&:expansion).map { |a| a.map { |a2| a2.first }.reverse.inject(0) { |sum, x| -(sum - x) } }.sum}"