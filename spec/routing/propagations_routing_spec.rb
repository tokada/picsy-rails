require "spec_helper"

describe PropagationsController do
  describe "routing" do

    it "routes to #index" do
      get("/propagations").should route_to("propagations#index")
    end

    it "routes to #new" do
      get("/propagations/new").should route_to("propagations#new")
    end

    it "routes to #show" do
      get("/propagations/1").should route_to("propagations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/propagations/1/edit").should route_to("propagations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/propagations").should route_to("propagations#create")
    end

    it "routes to #update" do
      put("/propagations/1").should route_to("propagations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/propagations/1").should route_to("propagations#destroy", :id => "1")
    end

  end
end
