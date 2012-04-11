# author: Sauvik Das
# rubyquiz Secret Santa

require_relative 'mailer'

###
#Note, the code expects input in the format of FIRSTNAME LASTNAME <email>newline
###
people = []
ARGF.each do |line|
  break if line =~ /exit/
  parts = line.squeeze.split
  people.push({:first => parts[0], :last => parts[1], :email => parts[2].gsub(/(<|>)/,'')})
end

santas = {}
taken = []
people.each do |person|
  valid = people.find_all { |peep| peep[:last] != person[:last] } - taken
  if valid.length > 0
    chosen = valid.sample(1)
    santas[person] = chosen[0]
    taken = taken + chosen
  else
    puts 'No valid santa for ' + person[:first]
  end
end

mailer = Mailer.new
santas.each do |santa,santee|
  msgstr = "Hello #{santa[:first]}!\n
  You are #{santee[:first]}'s secret santa. Go buy stuff."
  mailer.send_message(msgstr,santa[:email])
end
