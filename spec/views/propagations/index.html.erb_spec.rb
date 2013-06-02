require 'spec_helper'

describe "propagations/index" do
  before(:each) do
    assign(:propagations, [
      stub_model(Propagation,
        :trade => nil,
        :actor_from => nil,
        :actor_to => nil,
        :amount => 1.5
      ),
      stub_model(Propagation,
        :trade => nil,
        :actor_from => nil,
        :actor_to => nil,
        :amount => 1.5
      )
    ])
  end

  it "renders a list of propagations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
