require_relative './db_connection'

module Searchable
  def where(params)
    key_string = params.map {|key,value| "#{key} = ?"}.join(" AND ")
    query  = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{key_string}
    SQL
    DBConnection.execute(query, *params.values)
  end
end
