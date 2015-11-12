# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/models/floater.rb"

class Threshold < Floater
  default_scope -> { thresholds }

  def struck?(current_xchange)
    !!((value < current_xchange.rate && value > current_xchange.previous_rate) ||
       (value > current_xchange.rate && value < current_xchange.previous_rate))
  end
end
