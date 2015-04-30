require "answerific/version"
require "google-search"

module Answerific

  # General bot with a personality that can differentiate between
  # personal questions ('how are you') and technical questions ('how
  # big is Pluto')
  class Bot
    DEFAULT_NAME = 'bot'

    def initialize(opts = {})
      @miner = Answerific::Miner.new
      @name  = opts[:name].downcase || DEFAULT_NAME
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

  # Miner bot that answers questions by extracting information from the web
  # Currently only supports Google Search
  class Miner

    # Answers `question` by querying Google
    # Assumes `question` is downcase, only contains alpha numeric characters
    #   (i.e. has been preprocessed by Answerific::Bot.preprocess)
    # Returns a string containing the response or nil if none is found
    def answer(question) 
      p 'Answering ' + question
      return nil if !question || question.empty?
      mine(parse(question))
    end

    # === SELECT RESPONSE ===

    def process_google_results(results, query)
      candidates = select_responses(results, query)
      select_best_response(candidates)
    end

    # Returns a single response from the list of responses
    # TODO how to select the best? right now, return the first one
    def select_best_response(responses)
      responses.sample
    end

    # Returns the responses from `results` that have a the words in `query`
    def select_responses(results, query)
      sentences = results.map { |r| split_at_dot(r) }.flatten
      query_words = query.split ' '

      # Select the responses, only keeping the sentence that contain the search query
      selected = sentences.select do |sentence|
        query_words.all? { |w| sentence.include? w }  # contains all query words
      end

      return selected
    end

    # === EXTRACT INFO ===

    def mine(query)
      results = []

      Google::Search::Web.new(query: query).each do |r|
        results << clean_google_result(r.content)
      end

      process_google_results(results, query)
    end

    # === PARSE AND REARRANGE === (prepare for search engines)

    def parse(question)
      type = broad_question_type question
      parsed = ''

      case type
      when 'wh'
        parsed = parse_wh_question question
      when 'yes-no'
        parsed = parse_yes_no_question question
      when 'declarative'
        parsed = parse_declarative_question question
      end

      return parsed
    end

    # TODO consider verb permutations
    # TODO consider wh-word: where is the sun => the sun is [located]
    # Parses the wh-question `question` by removing the wh-word and moving the main verb at the end
    # Assumptions:
    #   * wh-word is at the beginning
    #   * main verb follows the wh-word
    #       (TODO not accurate for which/whose but should be ok for the others)
    # Example:
    #   question: 'where is the Kuiper belt'
    #   returns : 'the Kuiper belt is'
    def parse_wh_question(question)
      words = question.split ' '
      parsed = words[2..-1] << words[1]
      parsed.join " "
    end

    # Returns an array of permutations of the main verb in the question without the wh-word
    # Parses the wh-question `question` by removing the wh-word
    # Assumptions:
    #   * wh-word is at the beginning
    #   * main verb follows the wh-word
    #       (TODO not accurate for which/whose but should be ok for the others)
    # Example:
    #   question: 'where is the Kuiper belt'
    #   returns : ['is the Kuiper belt',
    #               'the is Kuiper belt',
    #               'the Kuiper is belt',
    #               'the Kuiper belt is']
    # def parse_wh_question(question)

    # end

    # Returns `question` without the yes-no verb
    # Example:
    #   question: 'is pluto closer to the sun than saturn'
    #   returns : 'pluto closer to the sun than saturn'
    def parse_yes_no_question(question)
      words = question.split ' '
      return words[1..-1].join ' '
    end

    # Returns `question` without the declarative statement
    # Example:
    #   question: 'tell me what is Pluto'
    #   returns : 'what is Pluto'
    def parse_declarative_question(question)
      declarative_expressions = [ 'tell me', 'I want to know' ]
      return question.gsub(/^#{Regexp.union(*declarative_expressions)}/, '').strip
    end

    # === DETECT TYPE OF QUESTION ===

    def broad_question_type(question)
      return 'wh' if is_wh_question question
      return 'yes-no' if is_yes_no_question question
      return 'declarative'
    end

    # Returns true if question starts with a wh-question word
    def is_wh_question(question)
      wh_words = %w(who where when why what which how)
      return /^#{Regexp.union(*wh_words)}/ === question
    end

    # Returns true if question starts with a yes-no question expression
    def is_yes_no_question(question)
      yes_no_words = %w(am are is was were have has do does did can could should may)
      return /^#{Regexp.union(*yes_no_words)}/ === question
    end

    # === OTHER FORMATTING ===

    def clean_google_result(string)
      string
      .downcase
      .gsub(/[^\.]+\.{3,}/, '')                 # remove incomplete sentences
      .gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, '')  # html tags
      .gsub(/\w{3} \d{1,2}, \d{4} \.{3} /, '')  # dates (27 Jan, 2015)
      .gsub("\n",'')                            # new lines
      .strip
    end

    def split_at_dot(string)
      re = /([a-z]{2})[\.\?!] ?/i  # regex to match *aa. where a is any letter
      string.split(re).each_slice(2).map(&:join)
    end
  end
end
