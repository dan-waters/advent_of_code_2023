require 'open-uri'

INSTRUCTION = 'LR'

Node = Struct.new(:name, :next_nodes) do
  def find_next(instruction)
    next_nodes[INSTRUCTION.index(instruction)]
  end

  def left(nodes)
    @left ||= nodes.detect{|node| node.name == next_nodes[0]}
  end

  def right(nodes)
    @right ||= nodes.detect{|node| node.name == next_nodes[1]}
  end
end

left_right = open('input.txt').readline(chomp: true)
nodes = open('input.txt').readlines(chomp: true)[2..].map do |node|
  name, next_nodes = node.split(' = ')
  /\((?<left_node>.{3}), (?<right_node>.{3})\)/ =~ next_nodes
  Node.new(name, [left_node, right_node])
end

steps = 0
current_node = nodes.detect { |node| node.name == 'AAA' }

until current_node.name == 'ZZZ' do
  next_node = current_node.find_next(left_right[steps % left_right.length])
  current_node = nodes.detect { |node| node.name == next_node }
  steps += 1
end

puts steps

current_nodes = nodes.select { |node| node.name[2] == 'A' }

lcm = current_nodes.inject(1) do |m, node|
  steps = 0
  until node.name[2] == 'Z' do
    next_node = node.find_next(left_right[steps % left_right.length])
    node = nodes.detect { |node| node.name == next_node }
    steps += 1
  end
  m.lcm(steps)
end

puts lcm