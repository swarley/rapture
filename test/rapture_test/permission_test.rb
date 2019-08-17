# frozen_string_literal: true

describe Rapture::Permissions do
  it "defines methods to detect permissions" do
    perms = Rapture::Permissions.new(0)

    assert(perms.respond_to? :send_messages)
    assert(perms.respond_to? :send_messages?)
  end

  it "correctly calculates if a permission is present" do
    mask = Rapture::PermissionFlags::SEND_MESSAGES | Rapture::PermissionFlags::ADD_REACTIONS

    perms = Rapture::Permissions.new(mask)

    assert(perms.send_messages)
    assert(perms.add_reactions?)
    refute(perms.kick_members)
    refute(perms.move_members?)
  end
end
