# frozen_string_literal: true

class CruiseControl
  attr_accessor :requested_speed

  # @return [Vehicle]
  attr_reader :vehicle

  state_machine :state, initial: :off do
    after_transition %i[on inactive] => :active, do: :engage
    after_transition active: :active, do: :increment_speed
    after_transition any => :off, do: :reset_speed

    event :on_off do
      transition off: :on
      transition %i[on inactive] => :off
    end

    event :set_accel do
      transition %i[on active inactive] => :active
    end

    event :cancel do
      transition active: :inactive
    end

    event :res_coast do
      transition %i[inactive active] => :active
    end
  end

  # @param vehicle [Vehicle]
  def initialize(vehicle)
    super()
    @vehicle = vehicle
  end

  # @return [Integer]
  def current_speed
    vehicle.speed
  end

  private

  # @return [void]
  def engage(transition)
    case transition.event
    when :set_accel
      self.requested_speed = current_speed
    when :res_coast
      vehicle.speed = requested_speed
    end
  end

  # @return [void]
  def reset_speed(_)
    self.requested_speed = nil
  end

  STEPS = Hash.new(0).merge!(set_accel: 1, res_coast: -1)

  # @return [void]
  def increment_speed(transition)
    step = STEPS[transition.event]
    self.requested_speed += step
    vehicle.speed += step
  end
end
