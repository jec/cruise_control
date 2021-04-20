# frozen_string_literal: true

RSpec.describe CruiseControl do
  subject(:cruise) { described_class.new(vehicle) }

  let(:vehicle) { build(:vehicle, speed: speed) }
  let(:speed) { 35 }

  describe "#on_off" do
    context "when off" do
      it "turns on" do
        cruise.on_off
        expect(cruise).to be_on
      end
    end

    context "when on" do
      it "turns off" do
        cruise.on_off
        cruise.on_off
        expect(cruise).to be_off
      end
    end

    context "when active" do
      it "turns off" do
        cruise.on_off
        cruise.on_off
        expect(cruise).to be_off
      end
    end

    context "when inactive" do
      it "turns off" do
        # Turn on CC.
        cruise.on_off
        # Engage CC at `speed`.
        cruise.set_accel
        # Cancel CC.
        cruise.cancel

        cruise.on_off
        expect(cruise).to be_off
        expect(cruise.requested_speed).to be_nil
      end
    end
  end

  describe "#set_accel" do
    context "when off" do
      it "does nothing" do
        cruise.set_accel
        expect(cruise).to be_off
      end
    end

    context "when on" do
      it "engages cruise control at the current speed" do
        cruise.on_off
        cruise.set_accel
        expect(cruise).to be_active
        expect(cruise.requested_speed).to eq speed
      end
    end

    context "when active" do
      it "increases vehicle speed" do
        cruise.on_off
        cruise.set_accel

        expect { cruise.set_accel }
          .to change(vehicle, :speed).by(1)
          .and(change(cruise, :requested_speed).by(1))
      end
    end

    context "when inactive" do
      it "engages cruise control at the current speed" do
        # Turn on CC.
        cruise.on_off
        # Engage CC at `speed`.
        cruise.set_accel
        # Cancel CC.
        cruise.cancel
        # Allow vehicle to slow down.
        vehicle.speed = speed - 10
        # Resume CC while inactive.
        cruise.set_accel

        expect(cruise).to be_active
        expect(vehicle.speed).to eq(speed - 10)
      end
    end
  end

  describe "#cancel" do
    context "when off" do
      it "does nothing" do
        cruise.cancel
        expect(cruise).to be_off
      end
    end

    context "when on" do
      it "does nothing" do
        cruise.on_off
        cruise.cancel
        expect(cruise).to be_on
      end
    end

    context "when active" do
      it "disengages cruise control" do
        # Turn on CC.
        cruise.on_off
        # Engage CC at `speed`.
        cruise.set_accel
        # Cancel CC.
        cruise.cancel

        expect(cruise).to be_inactive
      end
    end

    context "when inactive" do
      it "does nothing" do
        # Turn on CC.
        cruise.on_off
        # Engage CC at `speed`.
        cruise.set_accel
        # Cancel CC.
        cruise.cancel
        # Cancel while inactive.
        cruise.cancel

        expect(cruise).to be_inactive
      end
    end
  end

  describe "#res_coast" do
    context "when off" do
      it "does nothing" do
        cruise.res_coast
        expect(cruise).to be_off
      end
    end

    context "when on" do
      it "does nothing" do
        cruise.on_off
        cruise.res_coast
        expect(cruise).to be_on
      end
    end

    context "when active" do
      it "decreases vehicle speed" do
        cruise.on_off
        cruise.set_accel

        expect { cruise.res_coast }
          .to change(vehicle, :speed).by(-1)
          .and(change(cruise, :requested_speed).by(-1))
      end
    end

    context "when inactive" do
      it "engages cruise control at previously set speed" do
        # Turn on CC.
        cruise.on_off
        # Engage CC at `speed`.
        cruise.set_accel
        # Cancel CC.
        cruise.cancel
        # Allow vehicle to slow down.
        vehicle.speed = speed - 10
        # Resume CC while inactive.
        cruise.res_coast

        expect(cruise).to be_active
        expect(vehicle.speed).to eq speed
      end
    end
  end
end
