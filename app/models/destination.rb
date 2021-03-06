class Destination < ActiveRecord::Base
  belongs_to :user
  has_many :periods, -> { order(last_day: :desc) }, dependent: :destroy

  validates_presence_of :zone

  def policy
    Policy.new(citizenship: user.citizenship, destination: zone)
  end

  def countdown
    VisaCountdown.new(periods: periods.map { |period| {first_day: period.first_day, last_day: period.last_day} },
                      latest_entry: latest_entry,
                      length_of_stay: policy.length,
                      window_of_stay: policy.window) if policy.length != policy.window
  end

  def to_s
    zone
  end
end

# == Schema Information
#
# Table name: destinations
#
#  id           :integer          not null, primary key
#  latest_entry :date
#  zone         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
# Indexes
#
#  index_destinations_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
