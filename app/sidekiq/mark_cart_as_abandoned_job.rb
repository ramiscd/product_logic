class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_carts_as_abandoned
    remove_old_abandoned_carts
  end

  private

  def mark_carts_as_abandoned
    threshold = 3.hours.ago

    Cart.where(abandoned_at: nil)
        .where("last_interaction_at < ?", threshold)
        .update_all(abandoned_at: Time.current)
  end

  def remove_old_abandoned_carts
    threshold = 7.days.ago

    Cart.where("abandoned_at < ?", threshold)
        .find_each(&:destroy)
  end
end
