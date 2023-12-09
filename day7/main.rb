require 'open-uri'

CARD_ORDER = 'AKQT98765432J'.reverse
HAND_ORDER = [:five, :four, :full_house, :three, :two_pair, :pair, :high].reverse

Hand = Struct.new(:raw_cards) do
  include Comparable

  def cards
    @cards ||= raw_cards.chars
  end

  def groups
    @groups ||= cards.tally.sort_by { |k, v| -v }.to_h
  end

  def non_joker_groups
    groups.reject{|k,v| k == 'J'}
  end

  def type
    joker_count = (groups['J'] || 0)
    @type ||= if joker_count == 5 || (non_joker_groups.values.first + joker_count) == 5
      :five
    elsif (non_joker_groups.values.first + joker_count) == 4
      :four
    elsif (non_joker_groups.values.first + joker_count) == 3 && non_joker_groups.values[1] == 2
      :full_house
    elsif (non_joker_groups.values.first + joker_count) == 3 && non_joker_groups.values[1] == 1
      :three
    elsif non_joker_groups.values.first == 2 && (non_joker_groups.values[1] + joker_count) == 2
      :two_pair
    elsif (non_joker_groups.values.first + joker_count) == 2 && non_joker_groups.values[1] == 1
      :pair
    else
      :high
    end
  end

  def <=>(other)
    if type != other.type
      return HAND_ORDER.index(type) <=> HAND_ORDER.index(other.type)
    else
      cards.each_with_index do |card, index|
        other_card = other.cards[index]
        if card != other.cards[index]
          return CARD_ORDER.index(card) <=> CARD_ORDER.index(other_card)
        end
      end
    end
  end
end

input = open('input.txt').readlines(chomp: true)

rounds = input.map do |line|
  hand, bid = line.split
  [Hand.new(hand), bid.to_i]
end

sum = 0

rounds.sort_by{|s|s[0]}.each_with_index { |s, i| sum += s[1]*(i+1) }

puts sum