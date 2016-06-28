# encoding: utf-8

class Velocity < Floater
  default_scope -> { velocity }

  def struck?(current_xchange)
    !!(change_per_minutes(current_xchange) > value)
  end

  def change_per_minutes(current_xchange)
    current_xchange.change / ((current_xchange.created_at - current_xchange.previous.created_at).to_i) * 60
  end
end
