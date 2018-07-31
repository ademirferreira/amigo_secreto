require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
  end

  describe "POST create a member" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
      campaign = create(:campaign)
      @member = attributes_for(:member, campaign_id: campaign.id)
    end

    it "With valid attributes" do
      expect{ post :create, params: {member: @member} }.to change(Member, :count).by(1)
    end

    it "With invalid attributes" do
      @member[:campaign_id] = nil
      post :create, params: { member: @member }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE #destroy" do
    it "Returns http success" do      
      campaign = create(:campaign, user: @current_user)
      member = create(:member, campaign_id: campaign.id)
      delete :destroy, params: {id: member.id}, format: :json
      expect(response).to be_success
    end
  end

  describe "PUT #update" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
      campaign = create(:campaign, user: @current_user)
      @member = create(:member, campaign_id: campaign.id)
      @member_attributes = attributes_for(:member, campaign_id: campaign.id)

      put :update, params: { id: @member.id, member: @member_attributes }
    end
    
    it "Returns http success" do
      expect(response).to be_success
    end

    it "Member should be updated" do      
      @member.reload
      expect(@member.email).to eq(@member_attributes[:email])
    end
  end

  describe "GET #opened" do
    before(:each) do
      campaign = create(:campaign, user: @current_user)
      @member = create(:member, campaign_id: campaign.id)
      @member.set_pixel
    end

    it "Return https success" do
      get :opened, params: { token: @member.token }, format: :json
      expect(response).to be_success
    end

    context "With a valid token" do

      it "Open should be true" do
        get :opened, params: { token: @member.token }, format: :json
        @member.reload
        expect(@member.open).to be(true)
      end

      it "Open should be false" do
        token = @member.token
        @member.set_pixel
        get :opened, params: { token: token }, format: :json
        @member.reload
        expect(@member.open).to be(false)
      end

    end
  end

end