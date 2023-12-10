require 'open-uri'

Point = Struct.new(:x, :y) do
  def north
    Point.new(x, y - 1)
  end

  def south
    Point.new(x, y + 1)
  end

  def east
    Point.new(x + 1, y)
  end

  def west
    Point.new(x - 1, y)
  end
end
Pipe = Struct.new(:point, :type, :in_loop) do
  def connections
    @connections ||= case type
                     when 'F'
                       [point.south, point.east]
                     when 'J'
                       [point.north, point.west]
                     when '7'
                       [point.south, point.west]
                     when 'L'
                       [point.north, point.east]
                     when 'S'
                       [point.south, point.east] # by inspection!
                     when '|'
                       [point.north, point.south]
                     when '-'
                       [point.east, point.west]
                     else
                       []
                     end
  end

  def non_connections
    @non_connections ||= ([point.north, point.south, point.east, point.west] - connections)
  end
end

pipes = {}
open('input.txt').readlines(chomp: true).each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    point = Point.new(x + 1, y + 1)
    pipes[point] = Pipe.new(point, char, false)
  end
end

puts pipes.count

current_pipe = pipes.values.detect { |pipe| pipe.type == 'S' }
current_pipe.in_loop = true
pipe_loop = [current_pipe]
loop do
  possible_connections = current_pipe.connections.map { |c| pipes[c] }
  possible_connections = possible_connections.reject { |pipe| pipe.in_loop }
  current_pipe = possible_connections.detect do |pipe|
    pipe.connections.include?(current_pipe.point)
  end
  break if current_pipe.nil?
  current_pipe.in_loop = true
  pipe_loop << current_pipe
end

puts (pipe_loop.count / 2)

non_loop_pipes = pipes.values - pipe_loop
inside_pipes = []

non_loop_pipes.each do |pipe|
  point = pipe.point
  crossings = 0
  loop do
    point = Point.new(point.x - 1, point.y - 1)
    break if (point.x < 1 || point.y < 1)
    if pipes[point].in_loop
      crossings += 1 if pipes[point].type == 'F'
      crossings += 1 if pipes[point].type == 'S'
      crossings += 1 if pipes[point].type == 'J'
      crossings += 1 if pipes[point].type == '-'
      crossings += 1 if pipes[point].type == '|'
    end
  end
  if (crossings.odd?)
    inside_pipes << pipe
  end
end

puts inside_pipes.count