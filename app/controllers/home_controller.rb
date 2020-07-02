class HomeController < ApplicationController
    before_action :require_login
    
    def show
        render :show
    end
end