# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/models/floater.rb"

class Threshold < Floater
  default_scope -> { thresholds }

  def struck?(current_xchange)
    !!((self.value < current_xchange.rate && self.value > (current_xchange.rate - current_xchange.change)) ||
      (self.value > current_xchange.rate && self.value < (current_xchange.rate - current_xchange.change)))
  end
end