class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  before_create :set_initial_interaction_time

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    cart_items.sum { |item| item.total_price }
  end

  def set_initial_interaction_time
    self.last_interaction_at ||= Time.current
  end

  # marca o carrinho como abandonado se não houver interação nas últimas 3 horas
  def mark_as_abandoned
    threshold = 3.hours.ago
    if abandoned_at.nil? && last_interaction_at.present? && last_interaction_at < threshold
      update(abandoned_at: Time.current)
    end
  end

  # remove o carrinho se não houver interação há 7 dias ou mais
  # importante: usa last_interaction_at para decidir a remoção (comportamento exigido pelos testes)
  def remove_if_abandoned
    threshold = 7.days.ago
    destroy if last_interaction_at.present? && last_interaction_at <= threshold
  end

  def abandoned?
    abandoned_at.present?
  end
end
