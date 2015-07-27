require 'rails_helper'

RSpec.describe "developers/show", type: :view do
  before(:each) do
    @developer = assign(:developer, Developer.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
