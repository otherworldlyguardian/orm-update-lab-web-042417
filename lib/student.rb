require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name, @grade, @id = name, grade, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    test = DB[:conn].execute("SELECT id FROM students DESC LIMIT 1")[0]
    @id = test[0]
    update if self.name != test[1]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.id)
  end

  def self.create(name, grade)
    self.new(name, grade).save
  end


end
