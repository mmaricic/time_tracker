require 'rails_helper'

describe HomeController, type: :request do
  describe "#show" do
    it "redirects unauthorized users to sign in page" do
      get root_path

      expect(response).to redirect_to sign_in_path
    end
  end
end