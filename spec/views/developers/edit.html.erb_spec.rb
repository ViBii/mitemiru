require 'rails_helper'

RSpec.describe "developers/edit", type: :view do
  before(:each) do
    @developer = assign(:developer, Developer.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit developer form" do
    render

    assert_select "form[action=?][method=?]", developer_path(@developer), "post" do

      assert_select "input#developer_name[name=?]", "developer[name]"
    end
  end
end
