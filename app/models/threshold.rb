# encoding: utf-8
class Threshold < Floater
  attr_accessor :current_xchange

  default_scope -> { thresholds }

  def hit?
    (self.value < current_xchange.rate && self.value > current_xchange.rate - current_xchange.change) ||
    (self.value > current_xchange.rate && self.value < current_xchange.rate - current_xchange.change)
  end

  def message
    message =  "TH: #{self.value}/#{self.pair_id}, TR: #{current_xchange.rate - current_xchange.change} -> #{current_xchange.rate}"
  end
end