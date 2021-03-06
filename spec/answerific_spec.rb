require 'spec_helper'

describe Answerific do
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
    let(:test_string) { "it is c. archibald. yes! in 2005? in 5." }

    it {
      expected = ["it is c. archibald", "yes", "in 2005", "in 5"]
      expect(miner.split_at_dot(test_string)).to eq expected
    }
  end

  context '.preprocess' do
    let(:test_string) { '""  an invalid string!!?>: A 2nd one!) ' }
    it 'downcases and removes non-alpha numeric characters' do
      expect(miner.preprocess(test_string)).to eq('an invalid string a 2nd one')
    end
  end
end
