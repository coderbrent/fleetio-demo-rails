class DashboardController < ApplicationController
  def index
    render component: 'Dashboard', props: { welcome_msg: 'Ok!' }
  end
end
