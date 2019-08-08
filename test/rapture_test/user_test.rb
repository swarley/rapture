# frozen_string_literal: true

describe Rapture::User do
  describe "#distinct" do
    it "combines a user's username and discriminator" do
      user = Rapture::User.from_h(username: "swarley", discriminator: "0001")
      assert_equal(
        "swarley#0001",
        user.distinct
      )
    end
  end
end
