module Rapidfire
  class QuestionGroupResults < Rapidfire::BaseService
    attr_accessor :question_group

    # extracts question along with results
    # each entry will have the following:
    # 1. question type and question id
    # 2. question text
    # 3. if aggregatable, return each option with value
    # 4. else return an array of all the answers given
    #def extract(start_date, end_date, users)
    def extract(answer_groups)
      @question_group.questions.collect do |question|
        results =
          case question
          when Rapidfire::Questions::Select, Rapidfire::Questions::Radio,
            Rapidfire::Questions::Checkbox
            answers = get_answer_groups_answers(answer_groups, question).map { |text| text.split(',') }.flatten
            answers.inject(Hash.new(0)) { |total, e| total[e] += 1; total }

          when Rapidfire::Questions::Short, Rapidfire::Questions::Date,
            Rapidfire::Questions::Long, Rapidfire::Questions::Numeric
            get_answer_groups_answers(answer_groups, question)
          end

        QuestionResult.new(question: question, results: results)
      end
    end
  
  
    def extract_old(start_date, end_date)
      @question_group.questions.collect do |question|
        results =
          case question
          when Rapidfire::Questions::Select, Rapidfire::Questions::Radio,
            Rapidfire::Questions::Checkbox
            if start_date.blank? || end_date.blank?
              answers = question.answers.map(&:answer_text).map { |text| text.split(',') }.flatten
            else
              question.answers.submitted_between(start_date, end_date).length
              answers = question.answers.submitted_between(start_date, end_date).map(&:answer_text).map { |text| text.split(',') }.flatten
            end
            
            answers.inject(Hash.new(0)) { |total, e| total[e] += 1; total }

          when Rapidfire::Questions::Short, Rapidfire::Questions::Date,
            Rapidfire::Questions::Long, Rapidfire::Questions::Numeric
            if start_date.blank? || end_date.blank?
              question.answers.pluck(:answer_text)
            else
              question.answers.submitted_between(start_date, end_date).pluck(:answer_text)
            end
          end

        QuestionResult.new(question: question, results: results)
      end
    end
  
  
    private
  
    def get_answer_groups_answers(answer_groups, question)
      found_answers = []
      answer_groups.each do |answer_group|
        found_answers << answer_group.answers.select {|a| a.question_id == question.id }
      end
    
      found_answers.map { |a| a.first.answer_text }
    end
  end
end
