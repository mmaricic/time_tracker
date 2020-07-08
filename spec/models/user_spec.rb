require 'rails_helper'

describe User do
  it "validates name presence" do
    user = build(:user, name: "")
    
    expect(user.valid?).to be false
    expect(user.errors[:name]).not_to be_empty
  end

  it "validates name length" do
    user = build(:user, name: "a"*100)

    expect(user.valid?).to be false
    expect(user.errors[:name]).not_to be_empty
  end
end