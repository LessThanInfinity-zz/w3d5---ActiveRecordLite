require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)

  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    # name = :human, params = {}
    define_method(name) do
      other_class = params[:class_name] ? params[:class_name] : name.to_s.camelize.constantize
      primary_key = params[:primary_key] ? params[:primary_key] : :id

      other_table_name = other_class.constantize.table_name
      foreign_key = params[:foreign_key] ? params[:foreign_key] : (name.to_s + "_id") # issue here?
      foreign_key = self.send(foreign_key)
      query = <<-SQL
      SELECT *
      FROM #{other_table_name}
      WHERE #{primary_key} = #{foreign_key}
      SQL

      p query

      result = DBConnection.execute(query)
      p result

      other_class.constantize.parse_all(result)
    end
  end

  def has_many(name, params = {})

    define_method(name) do
      if params[:class_name]
        other_class = params[:class_name].singularize.camelize.constantize
      else
        other_class = name.singularize.camelize.constantize
      end

      primary_key = params[:primary_key] ? params[:primary_key] : :id
      other_table_name = other_class.table_name
      foreign_key = params[:foreign_key] ? params[:foreign_key] : self.class.name.underscore.downcase + "_id"

      query = <<-SQL
      SELECT *
      FROM #{other_table_name}
      WHERE #{primary_key} = #{foreign_key}
      SQL

      other_class.parse_all(DBConnection.execute(query).first)

    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
