require 'rails_helper'

describe StatisticsController, type: :request do
  describe "#show" do
    it "redirects unauthorized users to sign in page" do
      get statistics_path

      expect(response).to redirect_to sign_in_path
    end
  end
end