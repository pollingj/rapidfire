module Rapidfire
  class AnswerGroup < ActiveRecord::Base
    belongs_to :question_group
    belongs_to :user, polymorphic: true
    has_many   :answers, inverse_of: :answer_group, autosave: true
    
    scope :submitted_between, lambda { |start_date, end_date| where('created_at >= ? AND created_at <=?', start_date, end_date)}


    if Rails::VERSION::MAJOR == 3
      attr_accessible :question_group, :user
    end
    
    def self.to_csv
      last_answer_set = all.last.answers
      
      CSV.generate do |csv|
        csv << last_answer_set.map { |a| a.question.question_text }
        all.order(:created_at).each do |group|
          csv << group.answers.map { |a| a.answer_text }
        #  group.answers.each do |answer|
        #    csv << [answer.question.question_text, answer.answer_text]#answer.attributes.values_at(*first_answer.column_names)
        #  end
        end
      end
    end
  end
end
