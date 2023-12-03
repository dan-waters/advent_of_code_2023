require 'open-uri'

lines = open('input.txt').readlines(chomp: true)

Coordinate = Struct.new(:x, :y) do
  def touches?(other)
    ((x - other.x).abs <= 1) && ((y - other.y).abs <= 1)
  end
end

numbers = []
symbols = []

lines.each_with_index do |line, row|
  number_matches = []

  line.scan(/\d+/) do |c|
    number_matches << [c, Regexp.last_match.offset(0)[0]]
  end

  number_matches.each do |match|
    start_index = match[1]
    end_index = start_index + match[0].length - 1
    coords = (start_index..end_index).map do |column|
      Coordinate.new(column + 1, row + 1)
    end
    numbers << [match[0].to_i, coords]
  end

  symbol_matches = []
  line.scan(/[^\d|^.]/) do |c|
    symbol_matches << [c, Regexp.last_match.offset(0)[0]]
  end

  symbol_matches.each do |match|
    column = match[1]
    symbols << [match[0], Coordinate.new(column + 1, row + 1)]
  end
end

puts(numbers.select do |number|
  number[1].any? do |coord|
    symbols.any? do |other_coord|
      coord.touches?(other_coord[1])
    end
  end
end.map(&:first).sum)

puts (symbols.select do |symbol|
  symbol[0] = '*'
end.sum do |symbol|
  touches = []
  numbers.each do |number|
    if number[1].any? {|coord| symbol[1].touches?(coord)}
      touches << number[0]
    end
  end
  touches.count == 2 ? touches.inject(:*) : 0
end)