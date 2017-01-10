require 'sqlite3'
require 'singleton'
require 'byebug'
require_relative 'question_follows'
require_relative 'question_likes'
require_relative 'users'
require_relative 'replies'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body
  attr_reader :id, :user_id

  def self.find_by_id(id)
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless result.length > 0

    Question.new(result.first)
  end

  def self.find_by_user_id(user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    return nil unless result.length > 0

    result.map { |el| Question.new(el) }
  end


  def followers
    QuestionFollows.followers_for_question_id(id)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def save
    if @id
      update
      return
    else
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
        INSERT INTO
          questions (title, body, user_id)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def update
    raise "#{self} not in database" unless @id

    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
     UPDATE
       questions
     SET
       title = ?, body = ?, user_id = ?
     WHERE
       id = ?
   SQL
  end

  def author
    User.find_by_id(user_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def most_followed(n)
    QuestionFollows.most_followed_questions(n)
  end

  def likers
    QuestionLikes.likers_for_question_id(id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(id)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end

end
