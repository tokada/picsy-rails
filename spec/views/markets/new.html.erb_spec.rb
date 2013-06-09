require 'spec_helper'

describe "markets/new" do
  before(:each) do
    assign(:market, stub_model(Market,
      :name => "MyString",
      :people_count => ""
    ).as_new_record)
  end

  it "renders new market form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", markets_path, "post" do
      assert_select "input#market_name[name=?]", "market[name]"
      assert_select "input#market_people_count[name=?]", "market[people_count]"
    end
  end
end
