require_relative 'question_follows'
require_relative 'replies'
require_relative 'users'
require_relative 'questions'

class QuestionLikes
  def self.likers_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_likes ON question_likes.user_id = users.id
    WHERE
      question_id = ?
    SQL
    return nil unless result.length > 0
    result.map { |el| User.new(el) }
  end

  def self.num_likes_for_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(question_likes.user_id) AS num
    FROM
      users
    JOIN
      question_likes ON question_likes.user_id = users.id
    WHERE
      question_id = ?
    SQL
    result.first['num']
  end

  def self.liked_questions_for_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    WHERE
      question_likes.user_id = ?
    SQL
    return nil unless result.length > 0
    result.map { |el| Question.new(el) }
  end

  def self.most_liked_questions(n)
    result = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    GROUP BY
      question_likes.question_id
    ORDER BY
      COUNT(question_likes.user_id) DESC
    LIMIT
      ?
    SQL
    return nil unless result.length > 0
    result.map { |el| Question.new(el) }
  end
end
