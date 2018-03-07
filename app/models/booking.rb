class Booking < ApplicationRecord
  belongs_to :client
  belongs_to :timeslot

  monetize :total_price_cents

  enum status: [:booked, :confirmed, :paid, :cancelled]
  enum channel_source: [:direct, :gege_online, :gege_call_center, :airbnb,
    :tripadvisor, :booking_com]

  before_validation :calculate_total_price

  validates :total_pax, numericality: { greater_than_or_equal_to: 1 }
  validates :adults, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :children, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: true
  validates :status, presence: true
  validates :channel_source, presence: true
  validate :timeslot_not_overbooked

  def total_pax
    adults + children
  end


  def calculate_total_price
    adults_price = self.timeslot.activity.adult_price * self.adults
    children_price = self.timeslot.activity.child_price * self.children
    self.total_price = adults_price + children_price
  end

  def timeslot_not_overbooked
    capacity = timeslot.activity.capacity
    participants = timeslot.total_participants
    unless participants < capacity
      remaining = capacity - participants
      errors.add(:adults, "Il ne reste plus que #{remaining} place(s) au total")
      errors.add(:children, "Il ne reste plus que #{remaining} place(s) au total")
    end
  end
end

# class Booking < ApplicationRecord
#   belongs_to :client

#   validate :min_pers
#   validates :adults, presence: true, numericality: { greater_than_or_equal_to: 0 }
#   validates :children, presence: true, numericality: { greater_than_or_equal_to: 0 }
#   validates :total_price, presence: true, numericality: true
#   validates :status, presence: true

#   def min_pers
#     if adults + children == 0
#       errors.add(:adults, "Votre réservation doit compter au minimum 1 personne")
#     end
#   end
# end
