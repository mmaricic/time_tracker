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

  context "returns first name" do
    it "when full name given" do
      user = create(:user, name: "John Doe")

      expect(user.first_name).to eq("John")
    end

    it "when only one word given" do
      user = create(:user, name: "John")

      expect(user.first_name).to eq("John")
    end
  end
  
  context "returns initials" do
    it "when user provides first and last name" do
      user = create(:user, name: "John Doe")

      expect(user.initials).to eq("JD")
    end

    it "when user has middle name" do
      user = create(:user, name: "John Unknown Doe")

      expect(user.initials).to eq("JU")
    end

    it "when user provides only one word" do
      user = create(:user, name: "Johnatan")

      expect(user.initials).to eq("JO")
    end   
  end
end