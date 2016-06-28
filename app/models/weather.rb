# encoding: utf-8
class Weather
  # state_machine :initial => :calm do
  #   state :calm
  #   state :windy
  #   state :stormy

  #   event :up do
  #     transition :to => :windy,   :from => [:calm]
  #     transition :to => :stormy,  :from => [:windy]
  #   end

  #   event :down do
  #     transition :to => :windy, :from => [:stormy]
  #     transition :to => :calm,  :from => [:windy]
  #   end
  # end
end

weather = Weather.new
#weather.state
