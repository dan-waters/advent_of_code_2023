require 'open-uri'
$stdout.sync = true

Point = Struct.new(:x, :y)

grid = {}
open('input.txt').readlines(chomp: true).each.with_index do |line, y|
  line.chars.each.with_index do |char, x|
    grid[Point.new(x, y)] = char
  end
end

@max_x = grid.keys.map(&:x).max
@max_y = grid.keys.map(&:y).max

BEAM_CACHE = {}

def find_next_beams(current_point, direction, grid)
  if BEAM_CACHE[[current_point, direction]]
    return BEAM_CACHE[[current_point, direction]]
  else
    next_beam = []
    case direction
    when :east
      next_point = Point.new(current_point.x + 1, current_point.y)
      if next_point.x <= @max_x
        char = grid[next_point]
        case char
        when '|'
          next_beam = [[next_point, :north], [next_point, :south]]
        when '/'
          next_beam = [[next_point, :north]]
        when '\\'
          next_beam = [[next_point, :south]]
        else
          next_beam = [[next_point, direction]]
        end
      end
    when :west
      next_point = Point.new(current_point.x - 1, current_point.y)
      if next_point.x >= 0
        char = grid[next_point]
        case char
        when '|'
          next_beam = [[next_point, :north], [next_point, :south]]
        when '/'
          next_beam = [[next_point, :south]]
        when '\\'
          next_beam = [[next_point, :north]]
        else
          next_beam = [[next_point, direction]]
        end
      end
    when :north
      next_point = Point.new(current_point.x, current_point.y - 1)
      if next_point.y >= 0
        char = grid[next_point]
        case char
        when '-'
          next_beam = [[next_point, :east], [next_point, :west]]
        when '/'
          next_beam = [[next_point, :east]]
        when '\\'
          next_beam = [[next_point, :west]]
        else
          next_beam = [[next_point, direction]]
        end
      end
    when :south
      next_point = Point.new(current_point.x, current_point.y + 1)
      if next_point.y <= @max_y
        char = grid[next_point]
        case char
        when '-'
          next_beam = [[next_point, :east], [next_point, :west]]
        when '/'
          next_beam = [[next_point, :west]]
        when '\\'
          next_beam = [[next_point, :east]]
        else
          next_beam = [[next_point, direction]]
        end
      end
    end
    BEAM_CACHE[[current_point, direction]] = next_beam
    next_beam
  end
end

def energised_count_for_entry_point(entry_point, direction, grid)
  first_beam = find_next_beams(entry_point, direction, grid)
  beams = first_beam
  energised_points = []

  while beams.any? do
    current_point, direction = beams.shift
    next if energised_points.include?([current_point, direction])
    energised_points.push([current_point, direction])
    next_beams = find_next_beams(current_point, direction, grid)
    beams.push(*next_beams)
  end

  energised_points.map(&:first).uniq.count
end

puts energised_count_for_entry_point(Point.new(-1, 0), :east, grid)

max_east = (0..@max_y).map do |y|
  puts y
  energised_count_for_entry_point(Point.new(-1, y), :east, grid)
end.max

max_west = (0..@max_y).map do |y|
  puts y
  energised_count_for_entry_point(Point.new(@max_x + 1, y), :west, grid)
end.max

max_north = (0..@max_x).map do |x|
  puts x
  energised_count_for_entry_point(Point.new(x, -1), :south, grid)
end.max

max_south = (0..@max_x).map do |x|
  puts x
  energised_count_for_entry_point(Point.new(x, @max_y + 1), :east, grid)
end.max

puts [max_east, max_west, max_north, max_south].max