# author: Sauvik Das
# rubyquiz Solitaire encryption
DEBUG = false

class String
  NUMERIZE_SUBTRACT = 64
  def discard
    self.gsub(/(\W|\d)/,'')
  end

  def blockify(n)
    blocks = []
    self.chars.each_with_index do |c,i|
      blocks[i/n] = (i%n == 0 ? '' + c.to_s : blocks[i/n] + c.to_s)
    end
    blocks = blocks.map { |block| block.ljust(n,'X') }
  end

  def numerize
    self.upcase.each_byte.map { |c| c - NUMERIZE_SUBTRACT }
  end

  def self.denumerize(block)
    (block.class == [].class ? block.map { |c| (c + NUMERIZE_SUBTRACT).chr }.join : (block + NUMERIZE_SUBTRACT).chr)
  end
end

class SolitaireEncrypt
  BLOCK_SIZE = 5

  def initialize
    @deck = [(1..52).to_a, 'A', 'B'].flatten 
  end

  def reshuffle(k=1)
    @deck = [(1..52).to_a, 'A', 'B'].flatten 
  end

  def sanitize(s)
    temp = s.discard
    temp.upcase!
  end

  def encrypt(s)
    reshuffle
    puts sanitize(s)
    blocks = sanitize(s).blockify(BLOCK_SIZE)
    keystream = generateKeystream(blocks.length * BLOCK_SIZE)

    numerizedBlocks = blocks.map { |block| block.numerize } 
    numerizedKeystream = keystream.map { |block| block.numerize}

    merged = []
    numerizedBlocks.each.each_with_index do |block,i|
      merged[i] = []
      block.each.each_with_index do |val,j|
        merged[i] << (val+numerizedKeystream[i][j] - (val+numerizedKeystream[i][j] > 26 ? 26 : 0))
      end
    end
    merged = merged.map { |block| String.denumerize(block) }.join
  end

  def decrypt(s)
    reshuffle
    blocks = s.blockify(BLOCK_SIZE)
    keystream = generateKeystream(blocks.length * BLOCK_SIZE)


    numerizedBlocks = blocks.map { |block| block.numerize } 
    numerizedKeystream = keystream.map { |block| block.numerize}

    merged = []
    numerizedBlocks.each.each_with_index do |block,i|
      merged[i] = []
      block.each.each_with_index do |val,j|
        merged[i] << (val > numerizedKeystream[i][j] ? val-numerizedKeystream[i][j] : val + 26 - numerizedKeystream[i][j])
      end
    end
    merged = merged.map { |block| String.denumerize(block) }.join
  end

  def generateKeystream(n)
    generated = ''
    generated = generated + generate while generated.length < n
    generated.blockify(BLOCK_SIZE)
  end

  def generate
    moveCard
    moveCard('B',2)
    tripleCut
    countCut
    indexVal = (@deck[0].class == "".class ? 53 : @deck[0])
    charVal = String.denumerize(@deck[indexVal] - (@deck[indexVal] > 26 ? 26 : 0)) if @deck[indexVal].class == 1.class

    puts "After count cut" if DEBUG
    puts @deck.to_s if DEBUG
    puts charVal if charVal and DEBUG
    puts "" if DEBUG
    return (charVal ? charVal : '')
  end

  def moveCard(card='A',numPos=1)
    currIndex = @deck.index(card)
    #newIndex = ((currIndex == @deck.length - 1 and numPos == 1) ? numPos : (currIndex + numPos) % @deck.length)
    newIndex = (currIndex + numPos) % @deck.length
    newIndex = 1 if newIndex == 0
    @deck.delete_at(currIndex)
    @deck.insert(newIndex,card)
    puts 'After moving ' + card + " #{numPos} position" if DEBUG
    puts @deck.to_s if DEBUG
  end

  def tripleCut
    puts "Before triple cut" if DEBUG
    puts @deck.to_s if DEBUG
    topIndex,bottomIndex = (@deck.index('A') < @deck.index('B') ? [@deck.index('A'),@deck.index('B')] : [@deck.index('B'),@deck.index('A')])
    topVals = @deck[(0...topIndex)] unless topIndex == 0
    bottomVals = @deck[(bottomIndex+1...@deck.length)] unless bottomIndex == @deck.length - 1

    topTimes,bottomTimes = [topIndex,@deck.length - 1 - bottomIndex]
    topTimes.times { @deck.delete_at(0) }
    bottomTimes.times { @deck.pop }
    @deck = bottomVals + @deck if bottomVals
    @deck = @deck + topVals if topVals
    @deck.flatten
  end

  def countCut
    val = (@deck.last.class == "".class ? 53 : @deck.last)
    puts "After triple cut" if DEBUG
    puts @deck.to_s if DEBUG
    val.times do 
      @deck.insert(@deck.length-1,@deck[0])
      @deck.delete_at(0)
    end
  end
end

testString = "Code in ruby, live longer!"
encrypter = SolitaireEncrypt.new
estr = encrypter.encrypt(testString)
dstr = encrypter.decrypt(estr)

puts estr
puts dstr
