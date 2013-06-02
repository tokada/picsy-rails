require 'spec_helper'

describe "propagations/show" do
  before(:each) do
    @propagation = assign(:propagation, stub_model(Propagation,
      :trade => nil,
      :actor_from => nil,
      :actor_to => nil,
      :amount => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/1.5/)
  end
end
