require 'open-uri'

Point = Struct.new(:x, :y)

@galaxies = []
@grid = {}
open('input.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    @grid[Point.new(x + 1, y + 1)] = char
    @galaxies << Point.new(x + 1, y + 1) if char == '#'
  end
end

max_x = @grid.keys.map(&:x).max
max_y = @grid.keys.map(&:y).max

@blank_columns = (1..max_x).select { |x| (1..max_y).all? { |y| @grid[Point.new(x, y)] == '.' } }
@blank_rows = (1..max_y).select { |y| (1..max_x).all? { |x| @grid[Point.new(x, y)] == '.' } }

def distance(expansion_factor)
  total_distance = 0
  @galaxies.product(@galaxies).reject { |a, b| a == b }.each do |galaxy_1, galaxy_2|
    min_x = [galaxy_1.x, galaxy_2.x].min
    max_x = [galaxy_1.x, galaxy_2.x].max
    min_y = [galaxy_1.y, galaxy_2.y].min
    max_y = [galaxy_1.y, galaxy_2.y].max
    distance = max_x + max_y - min_x - min_y
    distance += (expansion_factor - 1) * (min_x..max_x).select { |x| @blank_columns.include?(x) }.count
    distance += (expansion_factor - 1) * (min_y..max_y).select { |y| @blank_rows.include?(y) }.count

    total_distance += distance
  end
  total_distance
end

puts distance(2) / 2
puts distance(1_000_000) / 2