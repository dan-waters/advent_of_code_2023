require 'open-uri'

columns = []

open('input.txt').readlines(chomp: true).each do |line|
  line.chars.each_with_index do |char, char_index|
    columns[char_index] ||= []
    columns[char_index].push char
  end
end

total_score = 0

columns.each do |column|
  score = column.length
  column.each_with_index do |char, i|
    if char == '#'
      score = column.length - i - 1
    end
    if char == 'O'
      total_score += score
      score -= 1
    end
  end
end

puts total_score

Point = Struct.new(:x, :y)

rocks = {}
open('input.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    rocks[Point.new(x, y)] = char if %w[O #].include?(char)
  end
end

@max_x = rocks.keys.map(&:x).max
@max_y = rocks.keys.map(&:y).max

def score(rocks)
  height = @max_y + 1
  total = 0
  rocks.each do |k,v|
    total += height - k.y if v == 'O'
  end
  total
end

def roll_north(rocks)
  new_rocks = rocks.select { |k, v| v == '#' }
  # hoping the keys are in order...
  rocks.select { |k, v| v == 'O' }.sort_by { |k, v| k.y }.each do |k, v|
    if k.y == 0
      new_rocks[k] = v
    else
      current_position = k
      position_above = Point.new(k.x, k.y - 1)
      rock_above = new_rocks[position_above]
      until current_position.y == 0 || rock_above == '#' || rock_above == 'O'
        current_position = position_above
        position_above = Point.new(position_above.x, position_above.y - 1)
        rock_above = new_rocks[position_above]
      end
      new_rocks[current_position] = v
    end
  end
  new_rocks
end

def roll_west(rocks)
  new_rocks = rocks.select { |k, v| v == '#' }
  # hoping the keys are in order...
  rocks.select { |k, v| v == 'O' }.sort_by { |k, v| k.x }.each do |k, v|
    if k.x == 0
      new_rocks[k] = v
    else
      current_position = k
      position_left = Point.new(k.x - 1, k.y)
      rock_left = new_rocks[position_left]
      until current_position.x == 0 || rock_left == '#' || rock_left == 'O'
        current_position = position_left
        position_left = Point.new(position_left.x - 1, position_left.y)
        rock_left = new_rocks[position_left]
      end
      new_rocks[current_position] = v
    end
  end
  new_rocks
end

def roll_south(rocks)
  new_rocks = rocks.select { |k, v| v == '#' }
  # hoping the keys are in order...
  rocks.select { |k, v| v == 'O' }.sort_by { |k, v| -k.y }.each do |k, v|
    if k.y == @max_y
      new_rocks[k] = v
    else
      current_position = k
      position_below = Point.new(k.x, k.y + 1)
      rock_below = new_rocks[position_below]
      until current_position.y == @max_y || rock_below == '#' || rock_below == 'O'
        current_position = position_below
        position_below = Point.new(position_below.x, position_below.y + 1)
        rock_below = new_rocks[position_below]
      end
      new_rocks[current_position] = v
    end
  end
  new_rocks
end

def roll_east(rocks)
  new_rocks = rocks.select { |k, v| v == '#' }
  # hoping the keys are in order...
  rocks.select { |k, v| v == 'O' }.sort_by { |k, v| -k.x }.each do |k, v|
    if k.x == @max_x
      new_rocks[k] = v
    else
      current_position = k
      position_right = Point.new(k.x + 1, k.y)
      rock_right = new_rocks[position_right]
      until current_position.x == @max_x || rock_right == '#' || rock_right == 'O'
        current_position = position_right
        position_right = Point.new(position_right.x + 1, position_right.y)
        rock_right = new_rocks[position_right]
      end
      new_rocks[current_position] = v
    end
  end
  new_rocks
end

def cycle(rocks)
  roll_east(roll_south(roll_west(roll_north(rocks))))
end

puts score(roll_north(rocks))

ROCK_CACHE = [rocks]

(1..1_000_000_000).each do |i|
  new_rocks = cycle(rocks)
  if ROCK_CACHE.include?(new_rocks)
    @cycle_start = ROCK_CACHE.index(new_rocks)
    @cycle_length = i - @cycle_start
    break
  end
  ROCK_CACHE << new_rocks
  rocks = new_rocks
end

SHORT_ROCK_CACHE = ROCK_CACHE[@cycle_start..@cycle_start + @cycle_length - 1]

@index = (1_000_000_000 - @cycle_start) % @cycle_length

puts "cycle length #{@cycle_length} at index #{@cycle_start}, looking at index #{@index}"
rocks = SHORT_ROCK_CACHE[@index]

puts score(rocks)