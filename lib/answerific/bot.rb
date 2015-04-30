# General bot with a personality that can differentiate between
# personal questions ('how are you') and technical questions ('how
# big is Pluto')
class Answerific::Bot
  DEFAULT_NAME = 'bot'

  def initialize(opts = {})
    @miner = Answerific::Miner.new
    @name  = opts[:name].downcase || DEFAULT_NAME if opts[:name]
  end

  def answer(question)
    q = preprocess(question)

    case is_personal q
    when -1
      answer_technical q
    when 0
      answer_technical q, true
    when 1
      answer_personal q
    end
  end

  # Detects wheter a question is a personal question (often related to
  # feeling) or a technical questions
  # The main point is to consider keywords like 'you', 'your'
  #   Example: 'what is *your* name', 'how do *you* feel'
  # These keywords should not appear in technical questions
  # However, a question might be asked like this: 'How big are you?' which
  # is a technical question - the question should be converted to 'how big
  # is bot' and then treated as a technical question
  # Returns:
  #   -1 if question is technical
  #    0 if question is technical but in the form of a personal question
  #    1 if question is personal
  def is_personal(question)
    personal_keywords = %w(you your yours)
    technical_keywords = %w(where big size)

    count = -1
    if personal_keywords.any? { |k| question.include? k }
      count += 1
      count += 1 unless technical_keywords.any? { |k| question.include? k }
    end

    return count
  end

  def answer_personal(question)
    p "Answering personal"
    # TODO
  end

  def answer_technical(question, personal_in_disguise=false)
    if personal_in_disguise
      make_question_technical(question) if personal_in_disguise
      make_answer_personal(@miner.answer(make_question_technical(question)))
    else
      @miner.answer(question)
    end
  end

  # Takes a question asked in the form of a personal question
  # and converts it to a technical question
  # Example: how big are you? #=> how big is Pluto
  def make_question_technical(question)
    trans = {
      "your" => "#{@name}'s",
      "you" => @name,
      "are"  => "is" }

    question.gsub(/[[:word:]]+/).each do |word|
      trans[word] || word
    end
  end

  def make_answer_personal(answer)
    # TODO remove html encoding like '=&#39;
    hash = {
      "#{@name} is" => "I am",
      "#{@name} was" => "I was",
      "#{@name} has" => "I have",
      "#{@name} had" => "I had",
      "#{@name}&#39;s" => "my",
      "#{@name}" => "me"
    }
    hash.each { |k,v| answer.sub! k, v }

    answer
  end

  # === PREPROCESSING ===

  # Returns cleaned `input`
  def preprocess(input)
    clean(input)
  end

  # Cleans the string `input` by removing non alpha-numeric characters
  def clean(input)
    ret = input.downcase
    ret.gsub(/[^0-9a-z ]/i, '').strip
  end
end
