# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle, class: Vehicle do
    skip_create

    speed { 35 }
  end
end