require_relative 'question_follows'
require_relative 'question_likes'
require_relative 'replies'
require_relative 'questions'


class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless result.length > 0

    User.new(result.first)

  end

  def self.find_by_name(fname,lname)
    result = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless result.length > 0

    User.new(result.first)
  end

  def save
    if @id
      update
      return
    else
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def update
    raise "#{self} not in database" unless @id

    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
     UPDATE
       users
     SET
       fname = ?, lname = ?
     WHERE
       id = ?
   SQL
  end

  def authored_questions
    Question.find_by_user_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollows.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(id)
  end

  def average_karma
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        COUNT(question_likes.user_id) / CAST(COUNT(DISTINCT(title)) AS FLOAT ) as num --COUNT(DISTINCT(question_likes.question_id))--*--users.fname--, (CAST( SUM(question_likes.user_id) as FLOAT) / CAST(COUNT(question_likes.question_id) as FLOAT)) as avg
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id

      WHERE
        questions.user_id = ?
    SQL
    return nil unless result.length > 0

    result.first['num']
  end

  attr_accessor :fname, :lname
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end
