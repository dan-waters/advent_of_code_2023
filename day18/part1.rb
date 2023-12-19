require 'open-uri'

Instruction = Struct.new(:direction, :distance, :colour)

instructions = open('input.txt').readlines(chomp: true).map do |line|
  direction, distance, colour = line.split
  Instruction.new(direction, distance.to_i, colour)
end

Point = Struct.new(:x, :y) do
  def neighbour(direction)
    case direction
    when 'U'
      Point.new(x, y - 1)
    when 'D'
      Point.new(x, y + 1)
    when 'L'
      Point.new(x - 1, y)
    when 'R'
      Point.new(x + 1, y)
    end
  end

  def neighbours
    [Point.new(x, y - 1), Point.new(x, y + 1), Point.new(x - 1, y), Point.new(x + 1, y)]
  end
end

current = Point.new(0, 0)
dug_tiles = []

instructions.each do |instruction|
  instruction.distance.times do
    next_tile = current.neighbour(instruction.direction)
    dug_tiles << next_tile
    current = next_tile
  end
end

@min_x = dug_tiles.map(&:x).min
@max_x = dug_tiles.map(&:x).max
@min_y = dug_tiles.map(&:y).min
@max_y = dug_tiles.map(&:y).max

@grid = {}
(@min_y..@max_y).each do |y|
  (@min_x..@max_x).each do |x|
    @grid[Point.new(x, y)] = nil
  end
end

# fill in dug tiles
dug_tiles.each do |point|
  @grid[point] = true
end

# flood fill from each edge

def flood_fill(point)
  points = [point]
  while points.any? do
    current = points.shift
    if @grid[current].nil?
      @grid[current] = false
      current.neighbours.select{|x| in_bounds(x) && @grid[x].nil?}.each do |neighbour|
        points << neighbour unless points.include?(neighbour)
      end
    end
  end
end

def in_bounds(point)
  point.x.between?(@min_x, @max_x) && point.y.between?(@min_y, @max_y)
end

@grid.keys.select { |p| p.x == @min_x }.each do |point|
  flood_fill(point)
end
@grid.keys.select { |p| p.x == @max_x }.each do |point|
  flood_fill(point)
end
@grid.keys.select { |p| p.y == @min_y }.each do |point|
  flood_fill(point)
end
@grid.keys.select { |p| p.y == @max_y }.each do |point|
  flood_fill(point)
end

@grid.select{|k, v| v.nil?}.keys.each do |point|
  @grid[point] = true
end

puts @grid.select{|k, v| v  }.count