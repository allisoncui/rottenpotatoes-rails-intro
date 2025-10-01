class Movie < ActiveRecord::Base
  def self.all_ratings
    distinct.order(:rating).pluck(:rating)
  end

  def self.with_ratings(ratings_list)
    return all unless ratings_list.present?
    where('UPPER(rating) IN (?)', Array(ratings_list).map { |r| r.to_s.upcase })
  end
end
