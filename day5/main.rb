require 'open-uri'

input = open('input.txt').read.split("\n\n")

Map = Struct.new(:dest, :source, :len) do
  def in_map?(value)
    value >= source && value < source + len
  end

  def output(value)
    if in_map?(value)
      dest + value - source
    else
      value
    end
  end
end

def parse_map(map_line)
  lines = map_line.split("\n")
  map = []
  lines[1..].each do |line|
    dest, source, len = line.split.map(&:to_i)
    map << Map.new(dest, source, len)
  end
  map
end

seeds = input[0].split(':')[1].split.map(&:to_i)

maps = input[1..].map do |line|
  parse_map(line)
end

locations = seeds.map do |seed|
  location = seed
  maps.each do |map|
    map_to_use = map.detect do |inner_map|
      inner_map.in_map?(location)
    end
    if map_to_use
      location = map_to_use.output(location)
    end
  end
  location
end

puts locations.min

Range = Struct.new(:from, :length) do
  # remember: this is exclusive
  def to
    @to ||= from + length
  end

  def intersects?(other)
    from < other.to && other.from < to
  end

  def intersect(other)
    new_from = [from, other.from].max
    new_to = [to, other.to].min
    new_len = new_to - new_from
    intersection = Range.new(new_from, new_len)
    smaller_other = nil
    larger_other = nil
    if from < new_from
      smaller_other = Range.new(from, new_from - from)
    end
    if to > intersection.to
      larger_other = Range.new(intersection.to, to - intersection.to)
    end
    [intersection, smaller_other, larger_other]
  end

  def bump(factor)
    Range.new(from + factor, length)
  end
end

ranges = []

seeds.each_slice(2) do |slice|
  ranges << Range.new(slice[0], slice[1])
end

RangeMap = Struct.new(:source_range, :dest_range) do
  def bumping_factor
    dest_range.from - source_range.from
  end
end

range_maps = input[1..].map do |line|
  lines = line.split("\n")
  map = []
  lines[1..].each do |line|
    dest, source, len = line.split.map(&:to_i)
    map << RangeMap.new(Range.new(source, len), Range.new(dest, len))
  end
  map
end

range_maps.each_with_index do |array_of_range_maps, index|
  ranges_to_check = ranges
  ranges_after_mapping = []

  while (ranges_to_check.any?) do
    range_to_check = ranges_to_check.shift

    if overlapping_range = array_of_range_maps.detect { |range_map| range_map.source_range.intersects?(range_to_check) }
      intersection, smaller, larger = range_to_check.intersect(overlapping_range.source_range)
      ranges_after_mapping << intersection.bump(overlapping_range.bumping_factor)
      ranges_to_check << smaller unless smaller.nil?
      ranges_to_check << larger unless larger.nil?
    else
      ranges_after_mapping << range_to_check
    end
  end

  ranges = ranges_after_mapping
end

puts ranges.map(&:from).min