class MassObject
  def self.set_attrs(*attributes)
    @attributes = attributes
    attributes.each do |attr|
      attr_accessor attr
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    # correct?
    results.map do |hash|
      self.class.new(hash)
    end
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include? attr_name.to_sym
        self.send("#{attr_name}=", value) #MassObject.new.foo=('nar')
      else
        raise "mass assignment to unregistered attribue #{attr_name}"
      end
    end
  end
end
