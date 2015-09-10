require './db/small_seed'
require './db/enormous_seed'

if Rails.env.production?
  EnormousSeed::Seed.new.run
else
  SmallSeed::Seed.new.run
end


