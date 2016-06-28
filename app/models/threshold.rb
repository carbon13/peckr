# encoding: utf-8

class Threshold < Floater
  default_scope -> { thresholds }

  def struck?(current_xchange)
    !!((value < current_xchange.rate && value > current_xchange.previous_rate) ||
       (value > current_xchange.rate && value < current_xchange.previous_rate))
  end
end
