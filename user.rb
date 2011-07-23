class User

  attr_accessor :username, :avatar_url, :foursquare, :gowalla, :twitter,
    :service_name, :service_url, :spot, :lat, :lng, :updated_at, :city

  def initialize(attrs)
    attrs.each do |k, v|
      send("#{k}=", v)
    end
  end

  def to_hash
    Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
  end

  def valid?
    self.lat and self.lng and self.updated_at and self.updated_at > (Time.now - 604800) # 1 week
  end

end