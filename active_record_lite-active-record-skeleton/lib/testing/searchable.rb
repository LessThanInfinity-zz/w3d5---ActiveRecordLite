#require_relative './db_connection'

module Searchable
  def where(params)
    key = params.map {|key| "{key} = ?"}.join(", ")
    params.values.join(",")
    query
  end
end