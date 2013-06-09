require 'spec_helper'

describe "markets/show" do
  before(:each) do
    @market = assign(:market, stub_model(Market,
      :name => "Name",
      :people_count => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(//)
  end
end
