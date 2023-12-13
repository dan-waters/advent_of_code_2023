require 'open-uri'

SpringRepair = Struct.new(:pattern, :counts) do
  def regex
    @regex_pattern ||= begin
                         regex_pattern = '^\.*'
                         regex_pattern += counts.map { |count| "(?<!\#)\\\#{#{count}}(?!\#)" }.join('\.+')
                         regex_pattern += '\.*$'
                         Regexp.new(regex_pattern)
                       end
  end

  def permutations
    chars = pattern.chars
    question_mark_count = chars.select { |char| char == '?' }.count
    (0..2 ** question_mark_count - 1).map do |i|
      new_pattern_chars = pattern.chars
      new_pattern = ''
      q_index = 0
      while new_pattern_chars.any? do
        char = new_pattern_chars.shift
        if char == '?'
          char = ((i >> q_index) & 1 == 1) ? '.' : '#'
          q_index += 1
        end
        new_pattern += char
      end
      new_pattern
    end
  end
end

repairs = open('input.txt').readlines(chomp: true).map do |line|
  pattern, counts = line.split(' ')
  counts = counts.split(',').map(&:to_i)
  SpringRepair.new(pattern, counts)
end

matching_count = 0

repairs.each do |repair|
  #matching_count += repair.permutations.select{|p| p.match?(repair.regex)}.count
end
puts matching_count

repairs = open('input.txt').readlines(chomp: true).map do |line|
  pattern, counts = line.split(' ')
  pattern = ([pattern] * 5).join('?')
  counts = counts.split(',').map(&:to_i) * 5
  SpringRepair.new(pattern, counts)
end

matching_count = 0
CACHE = {}
def count_matches(spring, groupings)
  trimmed_spring = spring.sub(/^\.*/, '').sub(/\.*$/, '')

  if memo = CACHE[[trimmed_spring, groupings]]
    return memo
  end

  if trimmed_spring.chars.none?
    if groupings.none?
      CACHE[[trimmed_spring, groupings]] = 1
      return 1
    else
      CACHE[[trimmed_spring, groupings]] = 0
      return 0
    end
  end

  if groupings.one?
    if trimmed_spring.match?(/^[#?]{#{groupings.first}}$/)
      CACHE[[trimmed_spring, groupings]] = 1
      return 1
    end
  end

  if groupings.any? && trimmed_spring.length < groupings.sum
    CACHE[[trimmed_spring, groupings]] = 0
    return 0
  end

  case trimmed_spring.chars.first
  when '?'
    CACHE[[trimmed_spring, groupings]] = count_matches(trimmed_spring.sub(/^\?/, '#'), groupings) + count_matches(trimmed_spring.sub(/^\?/, '.'), groupings)
    return CACHE[[trimmed_spring, groupings]]
  when '#'
    if trimmed_spring.match?(/^[#?]{#{groupings.first}}[?.$]/)
      CACHE[[trimmed_spring, groupings]] = count_matches(trimmed_spring[groupings.first + 1..] || '', groupings[1..])
      return CACHE[[trimmed_spring, groupings]]
    else
      CACHE[[trimmed_spring, groupings]] = 0
      return 0
    end
  end
end

repairs.each do |repair|
  matching_count += count_matches(repair.pattern, repair.counts)
end

puts matching_count