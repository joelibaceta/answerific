require 'spec_helper'

describe Answerific do

  describe Answerific::Bot do
    let(:bot) { Answerific::Bot.new name: 'Pluto' }

    context '.is_personal' do
      it 'detects personal questions' do
        questions = ['how are you', 'i like you', 'you are smart']
        questions.each { |q| expect(bot.is_personal(q)).to eq 1 }
      end

      it 'detects technical questions' do
        questions = ['where is the Kuiper belt', 'what is Pluto?']
        questions.each { |q| expect(bot.is_personal(q)).to eq(-1) }
      end

      it 'detects technical questions posed as personal questions' do
        questions = ['where are you', 'how big are you']
        questions.each { |q| expect(bot.is_personal(q)).to eq 0 }
      end
    end

    context '.answer_personal_question' do

    end

    context '.make_technical_quesiton' do
      it do
        question = 'how big are you'
        expected = 'how big is pluto'
        expect(bot.make_question_technical(question)).to eq expected
      end
    end

    context '.make_answer_personal' do
      it do
        answer = 'pluto is pluto\'s orbit, pluto has pluto'
        expected = 'I am my orbit, I have me'
        expect(bot.make_answer_personal(answer)).to eq expected
      end
    end

    context '.preprocess' do
      let(:test_string) { '""  an invalid string!!?>: A 2nd one!) ' }
      it 'downcases and removes non-alpha numeric characters' do
        expect(bot.preprocess(test_string)).to eq('an invalid string a 2nd one')
      end
    end

  end

  describe Answerific::Miner
  let(:miner) { Answerific::Miner.new }

  context '.select_response' do
    it do
      results = ['pluto is an object', 'pluto (planet) is small', 'Pluto has a big mass']
      query = 'pluto is'

      expected = results[0..1]
      expect(miner.select_responses(results, query)).to eq expected
    end
  end

  context '.parse_wh_question' do
    it { expect(miner.parse_wh_question('where is the sun')).to eq 'the sun is' }
  end

  context '.parse_yes_no_question' do
    it {expect(miner.parse_yes_no_question('is pluto made of ice')).to eq 'pluto made of ice'}
  end

  context '.parse_declarative_question' do
    it { expect(miner.parse_declarative_question('tell me what is pluto')).to eq 'what is pluto' }
  end

  context '.broad_question_type' do
    it 'type is wh-question' do
      expect(miner.broad_question_type('what is')).to eq 'wh'
      expect(miner.broad_question_type('where is Jupiter?')).to eq 'wh'
      expect(miner.broad_question_type('which planet do you prefer')).to eq 'wh'
    end

    it 'type is yes-no question' do
      expect(miner.broad_question_type('do you think')).to eq 'yes-no'
      expect(miner.broad_question_type('have you ever met Jupiter?')).to eq 'yes-no'
      expect(miner.broad_question_type('was I alive when you were born?')).to eq 'yes-no'
    end

    it 'type is declarative question' do
      expect(miner.broad_question_type('tell me')).to eq 'declarative'
    end
  end

  context '.split_at_dot' do
    let(:test_string) { "it is c. archibald. yes, i assure you! it's him? yep." }

    it {
      expected = ["it is c. archibald", "yes, i assure you", "it's him", "yep"]
      expect(miner.split_at_dot(test_string)).to eq expected
    }
  end
end
