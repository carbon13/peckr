# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/models/floater.rb"

class Threshold < Floater
  attr_accessor :current_xchange

  default_scope -> {thresholds}
end