require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class

    if params[:class_name]
      @other_class = params[:class_name].singularize.camelize.constantize
    else
      @other_class = name.singularize.camelize.constantize
    end
    @other_class
  end

  def other_table
     other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :primary_key, :other_table, :foreign_key, :params

  def initialize(name, params)
    @name = name
    @params = params
    @primary_key = params[:primary_key] ? params[:primary_key] : :id
    @foreign_key = params[:foreign_key] ? params[:foreign_key] : (name.to_s + "_id") # issue ?
    p other_class
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :other_class, :primary_key, :other_table, :foreign_key

  def initialize(name, params)
    if params[:class_name]
      @other_class = params[:class_name].singularize.camelize.constantize
    else
      @other_class = name.to_s.singularize.camelize.constantize
    end
    @other_table = other_class.table_name
    @primary_key = params[:primary_key] ? params[:primary_key] : :id
    @foreign_key = params[:foreign_key] ? params[:foreign_key] : self.class.name.underscore.downcase + "_id"
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
      aps = BelongsToAssocParams.new(name, params)
      query = <<-SQL
          SELECT *
          FROM #{aps.other_table}
          WHERE #{aps.primary_key} = ?
          SQL

          p query

      f_key = self.send(aps.foreign_key)
      p f_key

      result = DBConnection.execute(query, f_key)
      p result

      aps.other_class.parse_all(result)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params)

    define_method(name) do
      query = <<-SQL
          SELECT *
          FROM #{aps.other_table_name}
          WHERE #{aps.primary_key} = ?
          SQL

      aps.other_class.parse_all(DBConnection.execute(query,self.send(aps.foreign_key)).first)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
