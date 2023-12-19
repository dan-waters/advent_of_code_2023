require 'open-uri'

strings = open('input.txt').readline(chomp: true).split(',')

totals = strings.map do |string|
  total = 0
  string.each_byte do |a|
    total = total + a
    total = (total % 256)
    total = total * 17
    total = total % 256
  end
  total
end

puts totals.sum

def box_from_label(label)
  total = 0
  label.each_byte do |a|
    total = total + a
    total = (total % 256)
    total = total * 17
    total = total % 256
  end
  total
end

Lens = Struct.new(:label, :focal_length)

boxes = []
(1..256).each do |i|
  boxes.push([])
end

strings.map do |string|
  lens = Lens.new(*string.split(/[-=]/))
  box = boxes[box_from_label(lens.label)]
  if string.match?(/-/)
    old_lens = box.detect { |existing_lens| lens.label == existing_lens.label }
    box.delete(old_lens) if old_lens
  end
  if string.match?(/=/)
    old_lens = box.detect { |existing_lens| lens.label == existing_lens.label }
    if old_lens
      box[box.index(old_lens)] = lens
    else
      box.push(lens)
    end
  end
end

focusing_power = 0

boxes.each_with_index do |box, index|
  box.each_with_index do |lens, slot|
    focusing_power += (index + 1) * (slot + 1) * lens.focal_length.to_i
  end
end

puts focusing_power