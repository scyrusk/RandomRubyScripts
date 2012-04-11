# author: Sauvik Das
# Ill-documented Poker simulator. Runs poker games as many times as you want and reports the results.
SPADES = (1..13)
HEARTS = (14..26)
CLUBS = (27..39)
DIAMONDS = (40..52)

class Hand
  def self.add_item(key,value)
      @hash ||= {}
      @hash[key]=value
  end

  def self.get(key)
      @hash[key]
  end    

  def self.each
      @hash.each {|key,value| yield(key,value)}
  end

  Hand.add_item :HIGH_CARD, 1
  Hand.add_item :PAIR, 2
  Hand.add_item :TWO_PAIR, 3
  Hand.add_item :TRIPS, 4
  Hand.add_item :STRAIGHT, 5
  Hand.add_item :FLUSH, 6
  Hand.add_item :FULL_HOUSE, 7
  Hand.add_item :FOURS, 8
  Hand.add_item :STRAIGHT_FLUSH, 9


  def self.getWinningHand(hands)
    retVal = 0
    best = hands[0]
    hands.each.each_with_index do |hand,i|
      if Hand.get(hand[0]) > Hand.get(best[0])
        best = hand
        retVal = i
      elsif Hand.get(hand[0]) == Hand.get(best[0])
        best = tieBreak(best,hand)
        retVal = (best == hand ? i : retVal)
      end
    end
    retVal
  end

  def self.getBestHand(dealt,flop)
    #check backwards from best possible hand, to worst
    hands = makeAllHands(dealt,flop)
    best = [:HIGH_CARD,2]
    hands.each do |hand|
      currBest = findBest(hand)
      if Hand.get(currBest[0]) > Hand.get(best[0])
        best = currBest
      elsif Hand.get(currBest[0]) == Hand.get(best[0])
        best = tieBreak(best,currBest)
      end
    end
    best
  end

  def self.getCompValue(card)
    modded = card % 13 if card != nil
    modded = 13 if modded == 0 and card != nil #in the case of a king
    modded = 14 if modded == 1 and card != nil #in the case of an ace
    modded
  end

  def self.tieBreak(first,second)
    #Note, Ace and King handled as a special case in all tie breaks
    if first[0] == :TWO_PAIR
      firstHigh = (first[1][1][0] > first[1][1][1] ? first[1][1][0] : first[1][1][1])
      firstLow = (firstHigh == first[1][1][0] ? first[1][1][1] : first[1][1][0])
      secondHigh = ((second[1][1][0] > second[1][1][1] or second[0][0][0] == 1) ? second[1][1][0] : second[1][1][1])
      secondLow = (secondHigh == second[1][1][0] ? second[1][1][1] : second[1][1][0])
      if (firstHigh > secondHigh or (firstHigh == 1 and secondHigh != 1))
        return first
      elsif (secondHigh > firstHigh or (secondHigh == 1 and firstHigh != 1))
        return second
      else
        return first if (firstLow > secondLow or (firstLow == 1 and secondLow != 1))
        return second if (secondLow > firstLow or (secondLow == 1 and firstLow != 1))
        return (first[1][2] >= second[1][2] ? first : second)
      end
    elsif first[0] == :FULL_HOUSE
      first_trip = (first[1][1][0] == 1 ? 13 : first[1][1][0])
      second_trip = (second[1][1][0] == 1 ? 13 : second[1][1][0])
      first_pair = (first[1][1][1] == 1 ? 13 : first[1][1][1])
      second_pair = (second[1][1][1] == 1 ? 13 : second[1][1][1])

      if first_trip > second_trip
        return first
      elsif second_trip > first_trip
        return second
      else
        return (first_pair >= second_pair ? first : second)
      end
    elsif (first[0] == :PAIR or first[0] == :TRIPS or first[0] == :FOURS)
      first_num = (first[1][1] == 1 ? 13 : first[1][1])
      second_num = (second[1][1] == 1 ? 13 : second[1][1])
      if first_num > second_num
        return first
      elsif second_num > first_num
        return second
      else #if equal pairs
        first_kick = (first[1][2] == 1 ? 13 : first[1][2])
        second_kick = (second[1][2] == 1 ? 13 : second[1][2])
        return (first_kick >= second_kick ? first : second)
      end
    elsif first[0] == :HIGH_CARD
      first_high = (first[1] == 1 ? 13 : first[1])
      second_high = (second[1] == 1 ? 13 : second[1])
      return (first_high >= second_high ? first : second)
    else #bug here right now, need to FIX. For hands that don't use all 5 cards, still need to consider kicker
      first_high = (first[1][1] == 1 ? 13 : first[1][1])
      second_high = (second[1][1] == 1 ? 13 : second[1][1])
      return (first_high >= second_high ? first : second)
    end
  end

  #return tuple of hand type and the results of the hand
  def self.findBest(hand)
    hands = (['placeholder','placeholder'] + [self.isPair?(hand),self.isTwoPair?(hand),self.isTrips?(hand),self.isStraight?(hand),self.isFlush?(hand),self.isFullHouse?(hand),self.isFours?(hand),self.isSF?(hand)])
    if hands[Hand.get(:STRAIGHT_FLUSH)][0]
      [:STRAIGHT_FLUSH,hands[Hand.get(:STRAIGHT_FLUSH)]]
    elsif hands[Hand.get(:FOURS)][0]
      [:FOURS,hands[Hand.get(:FOURS)]]
    elsif hands[Hand.get(:FULL_HOUSE)][0]
      [:FULL_HOUSE,hands[Hand.get(:FULL_HOUSE)]]
    elsif hands[Hand.get(:FLUSH)][0]
      [:FLUSH,hands[Hand.get(:FLUSH)]]
    elsif hands[Hand.get(:STRAIGHT)][0]
      [:STRAIGHT,hands[Hand.get(:STRAIGHT)]]
    elsif hands[Hand.get(:TRIPS)][0]
      [:TRIPS,hands[Hand.get(:TRIPS)]]
    elsif hands[Hand.get(:TWO_PAIR)][0]
      [:TWO_PAIR,hands[Hand.get(:TWO_PAIR)]]
    elsif hands[Hand.get(:PAIR)][0]
      [:PAIR,hands[Hand.get(:PAIR)]]
    else
      [:HIGH_CARD,self.getHighCard(hand)]
    end
  end

  def self.getHighCard(hand)
    hand.inject { |max,n| (((max != 1 and n % 13 > max) or n % 13 == 1) ? n % 13 : n) }
  end

  def self.isSF?(hand)
    return [(isFlush?(hand)[0] and isStraight?(hand)[0]), Hand.getCompValue(hand.sort.last % 13)]
  end

  def self.isFlush?(hand)
    return [(hand.all? { |n| SPADES.member?(n) } or 
      hand.all? { |n| CLUBS.member?(n) } or
      hand.all? { |n| HEARTS.member?(n) } or
      hand.all? { |n| DIAMONDS.member?(n) }), Hand.getCompValue(hand.sort.last % 13)]
  end

  def self.isStraight?(hand)
    sorted = hand.sort {|a,b| a <=> b}
    return [sorted.each_cons(2).all? { |x,y| (y == x+1 or (y % 13 == 10 and x % 13 == 1))}, Hand.getCompValue(sorted.last % 13)]
  end
  
  def self.isPair?(hand)
    allPairs = []
    pickK(hand,2) do |n|
      allPairs = allPairs << n
    end
    allPairs.each do |x,y|
      cond = x % 13 == y % 13
      if cond
        kicker = hand.select { |card| card % 13 != x % 13 }.sort.last
        return true, Hand.getCompValue(x % 13), Hand.getCompValue(kicker)
      end
    end
    return false,-1
  end

  def self.isTrips?(hand)
    allTrips = []
    pickK(hand,3) do |n|
      allTrips = allTrips << n
    end
    allTrips.each do |x,y,z|
      cond = (x % 13 == y % 13 and x % 13 == z % 13)
      if cond
        kicker = hand.select { |card| card % 13 != x % 13 }.sort.last
        return cond, Hand.getCompValue(x % 13), Hand.getCompValue(kicker)
      end
    end
    return false, -1
  end

  def self.isFours?(hand)
    allFours = []
    pickK(hand,4) do |n|
      allFours = allFours << n
    end
    allFours.each do |x,y,z,u|
      cond = (x % 13 == y % 13 and x % 13 == z % 13 and x % 13 == u % 13)
      if cond
        kicker = hand.select { |card| card % 13 != x % 13 }.sort.last
        return cond, Hand.getCompValue(x % 13),Hand.getCompValue(kicker)
      end
    end
    return false,-1
  end

  def self.isFullHouse?(hand)
    trips = self.isTrips?(hand)
    if trips[0]
      dup = hand.dup.select { |n| Hand.getCompValue(n % 13) != Hand.getCompValue(trips[1] % 13) }
      pair = isPair?(dup)
      return true, [trips[1],pair[1]] if pair[0]
    end
    return false,-1
  end

  def self.isTwoPair?(hand)
    pair = self.isPair?(hand)
    if pair[0]
      dup = hand.dup.select { |n| Hand.getCompValue(n % 13) != Hand.getCompValue(pair[1] % 13) }
      second = isPair?(dup)
      kicker = hand.select { |card| (card % 13 != pair[1] % 13 and card % 13 != second[1] % 13) }[0]
      return true,[pair[1],second[1]],kicker if second[0]
    end
    return false,-1
  end

  def self.makeAllHands(dealt,flop)
    hands = []
    #enumerate all possibly qunitets of 7 cards comprising the hole and the flop
    pool = (dealt + flop).flatten
    pickK(pool,5) do |n|
      hands.push(n)
    end
    hands
  end

  def self.pickK(li, k)
    pickKHelper(li.sort {|a,b| a <=> b}, k) { |val| yield val.flatten}
  end

  def self.pickKHelper(li, k, level = 1)
    if level == k
      li.each do |el|
        yield el
      end
    else
      li.each do |el|
        pickKHelper(li.select() { |n| n > el }, k, level + 1) \
          {|val| yield([el] << val)}
      end
    end
  end

  def self.permutations li
    if li.length < 2
      yield li
    else
      li.each do |element|
        permutations(li.select() { |n| n != element }) \
          { |val| yield([element] << val)}
      end
    end
  end

  def self.numToCardVal(card)
    val = card % 13 
    case val
    when 2..10
      val.to_s
    when 1
      'Ace'
    when 11
      'Jack'
    when 12
      'Queen'
    when 0
      'King'
    end
  end

  def self.nameHand(dealt)
    temp = dealt.sort { |a,b| (a % 13) <=> (b % 13) }
    name = ""
    temp.each do |card|
      name =  name + "," + numToCardVal(card)
    end
    name[1...name.length]
  end
end

class Simulator
  def initialize
    @deck = (1..52).to_a
    @winsByHand = {}
    @handFrequency = {}
  end

  def runNSims(players=5,n=1000000)
    @winsByHand = {}
    @handFrequency = {}
    n.times do |i|
      completion = [ n / 10, 2 * n / 10, 3 * n / 10, 4 * n / 10, 5 * n/10, 6 * n/ 10, 7 * n/ 10, 8* n/10, 9* n/10]
      if completion.include?(i)
        puts "#{i * 1.0 / n * 100}% done"
      end
      runSim(players)
    end
    puts ""
    @winsByHand.sort_by { |k,v| v[:wins] }.each do |k,v|
      puts "#{k} -- #{v[:wins]} win(s) out of #{@handFrequency[k]} appearences (#{v[:wins]*1.0/@handFrequency[k]*100}%)"
      v.select {|hand,wins| hand != :wins }.each do |hand,wins|
        puts "    ==> with #{wins} #{hand} win(s)"
      end
    end
  end

  def runSim(players,debug=false)
    activeDeck = @deck.dup.shuffle #shuffle deck
    #deal hands to n players one at a time
    hands = []
    (0...(players*2)).each do |i|
      hands[i%players] = (hands[i%players] == nil ? [activeDeck.pop] : hands[i%players] + [activeDeck.pop])
    end

    if debug
      hands.each do |hand|
        temp = hand.map { |card| Hand.numToCardVal(card) }
        puts "Player's pre-flop hand is: #{temp}"
      end
    end

    #simulate the flops
    flop = []
    activeDeck.pop #burn
    flop = (flop << activeDeck.pop(3)).flatten
    activeDeck.pop #burn
    flop = flop + [activeDeck.pop]
    activeDeck.pop #burn
    flop = flop + [activeDeck.pop]

    puts "Flop is #{flop.map {|card| Hand.numToCardVal(card)}}" if debug
    bestHands = []
    hands.each do |hand|
      hn = Hand.nameHand(hand)
      @handFrequency[hn] = (@handFrequency.has_key?(hn) ? @handFrequency[hn] + 1  : 1)
      bestHands.push(Hand.getBestHand(hand,flop))
    end

    winningHand = Hand.getWinningHand(bestHands)
    #puts "Best hand for this round was: #{bestHands[winningHand]}"
    name = Hand.nameHand(hands[winningHand])
    if @winsByHand.has_key?(name)
      @winsByHand[name][:wins] = @winsByHand[name][:wins] + 1
      if @winsByHand[name].has_key?(bestHands[winningHand][0])
        @winsByHand[name][bestHands[winningHand][0]] = @winsByHand[name][bestHands[winningHand][0]] + 1
      else
        @winsByHand[name][bestHands[winningHand][0]] = 1
      end
      #@winsByHand[name][bestHands[winningHand][0]] = (@winsByHand[name].has_key?(bestHands[winningHand][0]]) ? (@winsByHand[name][bestHands[winningHand][0]] + 1) : 1)
    else
      @winsByHand[name] = {:wins => 1, bestHands[winningHand][0] => 1}
    end
    #winsByHand[name] = (@winsByHand.has_key?(name) ? @winsByHand[name] + 1 : 1)
    #puts "#{name} wins the hand, bringing its total wins up to #{@winsByHand[name]}"
  end
end

def testHands
  sf = Hand.isSF?([4,5,6,7,8])
  puts "The hand was a(n) #{Hand.numToCardVal(sf[1])} high straight flush" if sf[0]

  pair = Hand.isPair?([1,14,6,7,8])
  puts "The hand was a(n) #{Hand.numToCardVal(pair[1])} pair" if pair[0]

  trips = Hand.isTrips?([13,26,39,7,8])
  puts "The hand was a(n) #{Hand.numToCardVal(trips[1])} trip" if trips[0]

  fours = Hand.isFours?([10,11,24,7,20])
  puts "The hand was a #{Hand.numToCardVal(fours[1])} four of a kind!" if fours[0]

  fullHouse = Hand.isFullHouse?([1,14,27,2,15])
  puts "The hand was a #{Hand.numToCardVal(fullHouse[1][0])} trip--#{Hand.numToCardVal(fullHouse[1][1])} pair full house" if fullHouse[0]

  twoPairs = Hand.isTwoPair?([1,14,2,15,8])
  puts "The hand was a two pair with #{Hand.numToCardVal(twoPairs[1][0])}s and #{Hand.numToCardVal(twoPairs[1][1])}s"
end

deck = (1..52).to_a
counter = 0

#testHands

#Hand.makeAllHands([2,3],[4,5,6,7,8]).each do |hand|
#  counter = counter + 1
#  puts "Hand #{counter} is #{hand}"
#end

sim = Simulator.new
sim.runNSims(5, 10000) #first parameter is number of players, second is number of simulations

#Hand.pickThree([4,5,6,7,8]) { |n|
#  counter = counter + 1
#  puts "Turn #{counter} yields #{n}"
#}
