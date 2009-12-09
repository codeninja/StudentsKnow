module Markhov

  class SentenceGen
      def initialize(filename)
          text = File.open(filename,"r").read
          @words = Hash.new
          wordlist = text.split
          myindex = 1
          wordlist.each_with_index do |word, index|
            add(word, wordlist[index + 1]) if index <= wordlist.size - 2
          end
      end
  
	def word
		startword = @words.sort[rand(@words.size)][0].dup
		get(startword)
	end

	def sentence(sentencecount=1)
		  frequency = 10
		  keyword = word
		  count = 0
		  sentences = []
		  until count == sentencecount
			 sentence = ""
			 startword = @words.sort[rand(@words.size)][0].dup
			 word = get(startword)
			 until sentence.include?(".")
				sentence << word << " "
				if rand(frequency) == 1
				   word = keyword
				else
				   word = get(word)
				end
			 end
			 if sentence.length > 40 and sentence.downcase.include?(keyword.downcase)
				sentences.push(sentence.gsub(/[^a-zA-Z,\. ]/,'').gsub!(/^(\w)/){$1.upcase})
				count += 1
			 end
		  end
		  sentences.join('  ').gsub(/ +$/,'')
	end

	def paragraph(number=1)
		para = ""
		number.times do
			thispara = ""
			thispara << sentence((rand(3) + 1))
			para << (thispara + "
			
			")
		end
		para
	end

  private
  
      def add(word, next_word)
          @words[word] = Hash.new(0) if !@words[word]
          @words[word][next_word] += 1
      end
  
      def get(word)
          return "" if !@words[word]
          followers = @words[word]
          sum = followers.inject(0) {|sum,kv| sum += kv[1]}
          random = rand(sum)+1
          partial_sum = 0
          next_word = followers.find do |word, count|
              partial_sum += count
              partial_sum >= random
          end.first
          next_word
      end
        
  end
  
  class PersonGen
    attr_reader :names
    def initialize(filename)
      @names = YAML::load(File.open(filename,"r").read)
      @count = {
                :last => @names[:last].size,
                :female => @names[:female].size,
                :male => @names[:male].size }
    end
    
    def fullname(gender=nil,name_count=2)
      gender ||= [:male,:female][rand(2)]
      name = []
      name_count = 2 if name_count < 2
      (name_count - 1).times do
        name << name(gender).capitalize
      end
      name << name(:last).capitalize
      name.join(' ')
    end
    
    def name(gender)
      @names[gender][rand(@count[gender]).to_i]
    end

    
  end
  
end
