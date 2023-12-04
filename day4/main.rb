require 'open-uri'

lines = open('input.txt').readlines(chomp: true)

Card = Struct.new(:id, :winning_numbers, :my_numbers) do
  def score
    if match_count > 0
      2 ** (match_count - 1)
    else
      0
    end
  end

  def match_count
    winning_numbers.intersection(my_numbers).count
  end
end

cards = lines.map do |line|
  card, numbers = line.split(':')
  winning_numbers, my_numbers = numbers.split('|').map(&:split)
  Card.new(card, winning_numbers, my_numbers)
end

puts cards.map(&:score).sum

cards = lines.map do |line|
  card, numbers = line.split(':')
  winning_numbers, my_numbers = numbers.split('|').map(&:split)
  Card.new(card.split[1].to_i, winning_numbers.map(&:to_i), my_numbers.map(&:to_i))
end

cards.each do |card|
  if card.match_count > 0
    (card.id + 1..card.id + card.match_count).each do |id|
      copy = cards.detect{|card| card.id == id}
      cards << copy
    end
  end
end

puts cards.count