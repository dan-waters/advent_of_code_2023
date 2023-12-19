require 'open-uri'

workflows = {}
open('workflows.txt').readlines(chomp: true).each do |workflow|
  workflow = workflow[..-2]
  name, instructions = workflow.split('{')
  instructions = instructions.split(',').map do |instruction|
    if instruction.include?(':')
      condition, destination = instruction.split(':')
      if condition.include?('>')
        property, value = condition.split('>')
        condition = { property: property.to_sym, op: :>=, value: value.to_i + 1 }
      elsif condition.include?('<')
        property, value = condition.split('<')
        condition = { property: property.to_sym, op: :<=, value: value.to_i - 1 }
      end
    else
      condition = nil
      destination = instruction
    end
    { condition: condition, destination: destination }
  end
  workflows[name] = instructions
end

parts = open('parts.txt').readlines(chomp: true).map do |part|
  eval(part.gsub('=', ':'))
end

accepted_parts = []
rejected_parts = []

parts.each do |part|
  current_instructions = workflows['in']
  destination = nil
  loop do
    current_instructions.each do |instruction|
      condition = instruction[:condition]
      if condition.nil? || part[condition[:property]].send(condition[:op], condition[:value])
        destination = instruction[:destination]
        break
      end
    end
    case destination
    when 'A'
      accepted_parts << part
      break
    when 'R'
      rejected_parts << part
      break
    else
      current_instructions = workflows[destination]
    end
  end
end

puts accepted_parts.flat_map(&:values).sum

part = { x: (1..4000), m: (1..4000), a: (1..4000), s: (1..4000) }

accepted_part_ranges = []
rejected_part_ranges = []

part_queue = [part]
while part_queue.any? do
  part = part_queue.shift
  current_instructions = workflows['in']
  destination = nil
  loop do
    current_instructions.each do |instruction|
      condition = instruction[:condition]
      if condition.nil?
        destination = instruction[:destination]
        break
      else
        property = condition[:property]
        if part[property].include?(condition[:value])
          existing_range = part[property]
          new_part = part.dup
          case condition[:op]
          when :>=
            part[property] = (condition[:value]..existing_range.last)
            new_part[property] = (existing_range.first..condition[:value] - 1)
          when :<=
            part[property] = (existing_range.first..condition[:value])
            new_part[property] = (condition[:value]+1..existing_range.last)
          end
          part_queue << new_part
          destination = instruction[:destination]
          break
        elsif part[property].first.send(condition[:op], condition[:value])
          destination = instruction[:destination]
          break
        end
      end
    end
    case destination
    when 'A'
      accepted_part_ranges << part
      break
    when 'R'
      rejected_part_ranges << part
      break
    else
      current_instructions = workflows[destination]
    end
  end
end

puts accepted_part_ranges.map(&:values).map{|c| c.map(&:count).inject(:*)}.sum