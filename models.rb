ActiveRecord::Base.establish_connection
class User < ActiveRecord::Base
    belongs_to :theater
    has_many :subscriptions
    has_many :movies, :through => :subscriptions
    has_secure_password
    validates :mail,
        presence: true,
        format: {with:/\A.+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/}
    validates :password,
        format: {with:/(?=.*?[a-z])(?=.*?[0-9])/},
        length: {in: 5..10}
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
