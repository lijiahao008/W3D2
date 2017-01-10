require_relative 'question_follows'
require_relative 'question_likes'
require_relative 'users'
require_relative 'questions'


class Reply
  attr_accessor :title, :body
  attr_reader :id, :question_id, :user_id, :parent_id

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless result.length > 0

    Reply.new(result.first)
  end

  def self.find_by_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless result.length > 0

    result.map { |el| Reply.new(el) }
  end

  def self.find_by_question_id(question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless result.length > 0

    result.map { |el| Reply.new(el) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
  end

  def save
    if @id
      update
      return
    else
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @question_id, @parent_id, @user_id)
        INSERT INTO
          replies (title, body, question_id, parent_id, user_id)
        VALUES
          (?, ?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def update
    raise "#{self} not in database" unless @id

    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @question_id, @parent_id, @user_id, @id)
     UPDATE
       replies
     SET
       title = ?, body = ?, question_id = ?, parent_id = ?, user_id = ?
     WHERE
       id = ?
   SQL
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    return nil if parent_id == nil
    Reply.find_by_id(parent_id)
  end

  def child_replies
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    return nil unless result.length > 0

    result.map { |el| Reply.new(el) }
  end
end
