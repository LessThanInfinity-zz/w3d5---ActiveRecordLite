require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
#require './active_support/inflector'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    table = DBConnection.execute("SELECT * FROM #{@table_name}")
    table.each {|row| self.new(row)}

  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL,id)
      SELECT * FROM #{@table_name}
      WHERE id = ?
      SQL
      self.new(result.first)
  end

  def create
    attr_names = self.class.attributes.join(", ")
    question_marks = self.class.attributes.map {|name| '?'}.join(",")

    query = <<-SQL
            INSERT INTO #{self.class.table_name} (#{attr_names})
            VALUES (#{question_marks})
            SQL

    DBConnection.execute(query, *self.attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_names = self.class.attributes.map {|attr| "#{attr} = ?"}.join(", ")
    query = <<-SQL
            UPDATE #{self.class.table_name}
            SET #{attr_names}
            WHERE id = #{self.id}
            SQL

    DBConnection.execute(query, *self.attribute_values)
  end

  def save
    id.nil? ? create : update
  end

  def attribute_values
    self.class.attributes.map {|attr| send(attr)}
  end
end
