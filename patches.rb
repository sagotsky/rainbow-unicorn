class Object
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end 
end
