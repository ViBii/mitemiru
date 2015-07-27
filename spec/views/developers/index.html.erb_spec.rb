require 'rails_helper'

RSpec.describe "developers/index", type: :view do
  before(:each) do
    assign(:developers, [
      Developer.create!(
        :name => "Name"
      ),
      Developer.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of developers" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
