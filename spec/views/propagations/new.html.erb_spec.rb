require 'spec_helper'

describe "propagations/new" do
  before(:each) do
    assign(:propagation, stub_model(Propagation,
      :trade => nil,
      :actor_from => nil,
      :actor_to => nil,
      :amount => 1.5
    ).as_new_record)
  end

  it "renders new propagation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", propagations_path, "post" do
      assert_select "input#propagation_trade[name=?]", "propagation[trade]"
      assert_select "input#propagation_actor_from[name=?]", "propagation[actor_from]"
      assert_select "input#propagation_actor_to[name=?]", "propagation[actor_to]"
      assert_select "input#propagation_amount[name=?]", "propagation[amount]"
    end
  end
end
