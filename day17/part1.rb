require 'open-uri'

LEFT_TURNS = { north: :west, west: :south, south: :east, east: :north }
RIGHT_TURNS = { north: :east, east: :south, south: :west, west: :north }

Point = Struct.new(:x, :y) do
  def neighbour(direction)
    case direction
    when :north
      Point.new(x, y - 1)
    when :south
      Point.new(x, y + 1)
    when :west
      Point.new(x - 1, y)
    when :east
      Point.new(x + 1, y)
    end
  end
end
Step = Struct.new(:point, :direction, :num_steps_in_direction)
State = Struct.new(:cost, :step) do
  def neighbours(grid)
    neighbours = []

    left_direction = LEFT_TURNS[step.direction]
    left_point = step.point.neighbour(left_direction)
    new_cost = grid[left_point]
    unless new_cost.nil?
      neighbours << State.new(cost + new_cost, Step.new(left_point, left_direction, 1))
    end

    right_direction = RIGHT_TURNS[step.direction]
    right_point = step.point.neighbour(right_direction)
    new_cost = grid[right_point]
    unless new_cost.nil?
      neighbours << State.new(cost + new_cost, Step.new(right_point, right_direction, 1))
    end

    if step.num_steps_in_direction < 3
      straight_ahead = step.point.neighbour(step.direction)
      new_cost = grid[straight_ahead]
      unless new_cost.nil?
        neighbours << State.new(cost + new_cost, Step.new(straight_ahead, step.direction, step.num_steps_in_direction + 1))
      end
    end

    neighbours
  end
end

grid = {}

open('input.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    grid[Point.new(x, y)] = char.to_i
  end
end

costs = {}
queue = []
start = Point.new(0, 0)
starting_directions = [:east, :south]
starting_directions.each do |direction|
  state = State.new(0, Step.new(start, direction, 0))
  costs[state.step] = 0
  queue << state
end

steps = 0
while queue.any? do
  steps += 1
  current = queue.shift
  current.neighbours(grid).each do |neighbour|
    if costs[neighbour.step].nil? || costs[neighbour.step] > neighbour.cost
      costs[neighbour.step] = neighbour.cost
      index = queue.bsearch_index { |p| costs[p.step] > neighbour.cost } || queue.size
      queue.insert(index, neighbour)
    end
  end
end

ending = grid.keys.max_by { |p| p.x + p.y }

puts steps
puts costs.select { |k, v| k.point == ending }.values.min