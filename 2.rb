# in general, this if-condition is useless here, since
# to get `status: 422` we need @infographic to be falsy and
# in a daily life it couldn't be falsy

# if `find` method couldn't find a record with id provided
# it raises `ActiveRecord::RecordNotFound` error

# but if we redefine `find` method like this (or any other way
# to return `nil` or `false`):

class Infographic < ApplicationRecord
  def self.find(id)
    Infographic.find_by(id: id)
  end
end

# it will return `nil` and thus we'll get `status: 422`
