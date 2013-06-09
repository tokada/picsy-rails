require 'spec_helper'

describe "markets/index" do
  before(:each) do
    assign(:markets, [
      stub_model(Market,
        :name => "Name",
        :people_count => ""
      ),
      stub_model(Market,
        :name => "Name",
        :people_count => ""
      )
    ])
  end

  it "renders a list of markets" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
