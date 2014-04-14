module Rapidfire
  class Answer < ActiveRecord::Base
    belongs_to :question
    belongs_to :answer_group, inverse_of: :answers
    
    scope :submitted_between, lambda { |start_date, end_date| where('created_at >= ? AND created_at <=?', start_date, end_date)}

    validates :question, :answer_group, presence: true
    validate  :verify_answer_text, :if => "question.present?"

    if Rails::VERSION::MAJOR == 3
      attr_accessible :question_id, :answer_group, :answer_text
    end

    private
    def verify_answer_text
      question.validate_answer(self)
    end
  end
end
