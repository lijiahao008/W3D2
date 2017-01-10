require_relative 'question_likes'
require_relative 'replies'
require_relative 'users'
require_relative 'questions'



class QuestionFollows
  def self.followers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON question_follows.user_id = users.id
    WHERE
      question_id = ?
    SQL
    return nil unless result.length > 0

    result.map { |el| User.new(el) }
  end

  def self.followed_questions_for_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    JOIN
      question_follows ON question_follows.question_id = questions.id
    WHERE
      question_follows.user_id = ?
    SQL
    return nil unless result.length > 0

    result.map { |el| Question.new(el) }
  end

  def self.most_followed_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    JOIN
      question_follows ON question_follows.question_id = questions.id
    GROUP BY
      question_follows.question_id
    ORDER BY
      COUNT(question_follows.user_id) DESC
    LIMIT
      ?
    SQL
    return nil unless result.length > 0
    result.map { |el| Question.new(el) }
  end
end
