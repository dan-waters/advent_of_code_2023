require 'open-uri'

patterns = open('input.txt').read.split("\n\n")

Point = Struct.new(:x, :y)

parsed_patterns = patterns.map do |pattern|
  new_pattern = {}
  pattern.split("\n").each_with_index do |line, y|
    line.chars.each_with_index do |char, x|
      new_pattern[Point.new(x + 1, y + 1)] = char
    end
  end
  new_pattern
end

def fold_across_column(pattern, column)
  left_pattern = pattern.select { |k, v| k.x <= column }
  right_pattern = pattern.select { |k, v| k.x > column }

  if column > pattern.keys.map(&:x).max / 2
    right_pattern = right_pattern.inject({}) do |h, kv|
      h[Point.new(2 * column + 1 - kv[0].x, kv[0].y)] = kv[1]
      h
    end
  else
    left_pattern = left_pattern.inject({}) do |h, kv|
      h[Point.new(2 * column + 1 - kv[0].x, kv[0].y)] = kv[1]
      h
    end
  end
  [left_pattern, right_pattern]
end

def matching_folds?(larger_fold, smaller_fold)
  smaller_fold.keys.all? do |key|
    smaller_fold[key] == larger_fold[key]
  end
end

def transpose(pattern)
  new_pattern = {}
  pattern.each do |point, char|
    new_pattern[Point.new(point.y, point.x)] = char
  end
  new_pattern
end

columns = 0
rows = 0
parsed_patterns.each do |pattern|
  max_column = pattern.keys.map(&:x).max - 1
  (1..max_column).each do |column|
    left, right = fold_across_column(pattern, column)
    match = left.keys.count > right.keys.count ? matching_folds?(left, right) : matching_folds?(right, left)
    if match
      columns += column
      break
    end
  end

  tranposed_pattern = transpose(pattern)
  max_row = tranposed_pattern.keys.map(&:x).max - 1
  (1..max_row).each do |row|
    left, right = fold_across_column(tranposed_pattern, row)
    match = left.keys.count > right.keys.count ? matching_folds?(left, right) : matching_folds?(right, left)
    if match
      rows += row
      break
    end
  end
end

puts columns + 100*rows




def almost_matching_folds?(larger_fold, smaller_fold)
  smaller_fold.keys.one? do |key|
    smaller_fold[key] != larger_fold[key]
  end
end

columns = 0
rows = 0
parsed_patterns.each do |pattern|
  max_column = pattern.keys.map(&:x).max - 1
  (1..max_column).each do |column|
    left, right = fold_across_column(pattern, column)
    match = left.keys.count > right.keys.count ? almost_matching_folds?(left, right) : almost_matching_folds?(right, left)
    if match
      columns += column
      break
    end
  end

  tranposed_pattern = transpose(pattern)
  max_row = tranposed_pattern.keys.map(&:x).max - 1
  (1..max_row).each do |row|
    left, right = fold_across_column(tranposed_pattern, row)
    match = left.keys.count > right.keys.count ? almost_matching_folds?(left, right) : almost_matching_folds?(right, left)
    if match
      rows += row
      break
    end
  end
end


puts columns + 100*rows