require 'open-uri'

lines = open('input.txt').readlines(chomp: true)

games = []
Sample = Struct.new(:red, :blue, :green)

Game = Struct.new(:id, :samples) do
  def is_possible?(total_red, total_blue, total_green)
    samples.all? do |sample|
      (total_red >= sample.red) && (total_blue >= sample.blue) & (total_green >= sample.green)
    end
  end

  def fewest_red
    samples.map(&:red).max
  end
  def fewest_blue
    samples.map(&:blue).max
  end
  def fewest_green
    samples.map(&:green).max
  end

  def power
    fewest_red*fewest_blue*fewest_green
  end
end

lines.each do |line|
  /Game (?<game_id>(\d+)): (?<cubes>(.+))/ =~ line
  game = Game.new(game_id.to_i, [])
  game_counts = cubes.split(';').map do |cube_count|
    red_count = cube_count.match(/(\d+) red/)[1].to_i rescue 0
    blue_count = cube_count.match(/(\d+) blue/)[1].to_i rescue 0
    green_count = cube_count.match(/(\d+) green/)[1].to_i rescue 0
    game.samples << Sample.new(red_count, blue_count, green_count)
  end
  games << game
end

puts games.select { |game| game.is_possible?(12, 14, 13) }.map(&:id).sum

puts games.map(&:power).sum