require 'open-uri'

Instruction = Struct.new(:direction, :distance)

instructions = open('input.txt').readlines(chomp: true).map do |line|
  colour = line.split[2]
  distance = colour[2..6].to_i(16)
  direction = colour[7]
  Instruction.new(direction, distance.to_i)
end

Point = Struct.new(:x, :y)

current = Point.new(0, 0)
vertices = [current]
boundary_length = 0

instructions.each do |instruction|
  next_vertex = case instruction.direction
                when '0'
                  Point.new(current.x + instruction.distance, current.y)
                when '1'
                  Point.new(current.x, current.y + instruction.distance)
                when '2'
                  Point.new(current.x - instruction.distance, current.y)
                when '3'
                  Point.new(current.x, current.y - instruction.distance)
                end
  vertices << next_vertex
  boundary_length += instruction.distance
  current = next_vertex
end

area = 0

vertices.each_cons(2) do |v1, v2|
  area += (v1.y + v2.y) * (v1.x - v2.x)
end

area = area/2

interior_points = area - boundary_length/2 + 1

puts interior_points + boundary_length
