ActiveRecord::Base.establish_connection
class User < ActiveRecord::Base
    belongs_to :theater
    has_many :subscriptions
    has_many :movies, :through => :subscriptions
    validates :mail,
        format: {with:/\A.+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/},
        allow_blank: true
end

class Theater < ActiveRecord::Base
    has_many :users
end

class Movie < ActiveRecord::Base
    has_many :subscriptions
    has_many :users, :through => :subscriptions
end

class Subscription < ActiveRecord::Base
    belongs_to :movie , foreign_key: :movie_id
    belongs_to :user
end

class Today < ActiveRecord::Base
end
