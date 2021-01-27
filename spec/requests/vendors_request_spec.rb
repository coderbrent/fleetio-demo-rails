require 'rails_helper'

RSpec.describe "Vendors", type: :request do
  it 'returns all vendors' do
    get 'http://localhost:3000/vendors/all'
    
    expect(response).to have_http_status(:success)
  end
end
