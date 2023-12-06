require 'open-uri'

Race = Struct.new(:time, :record)

# sample
races = [
  Race.new(7, 9),
  Race.new(15, 40),
  Race.new(30, 200),
]

# part 1
races = [
  Race.new(38, 234),
  Race.new(67, 1027),
  Race.new(76, 1157),
  Race.new(73, 1236),
]

# part 2
races = [
  Race.new(38677673, 234102711571236)
]

puts (races.map do |race|
  speed = 0
  distance = 0
  while (distance <= race.record) do
    speed += 1
    distance = speed * (race.time - speed)
  end

  lowest = speed

  speed = race.time
  distance = 0
  while (distance <= race.record) do
    speed -= 1
    distance = speed * (race.time - speed)
  end

  highest = speed

  (lowest..highest).count
end.inject(:*))