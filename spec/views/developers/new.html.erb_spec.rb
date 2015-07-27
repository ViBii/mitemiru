require 'rails_helper'

RSpec.describe "developers/new", type: :view do
  before(:each) do
    assign(:developer, Developer.new(
      :name => "MyString"
    ))
  end

  it "renders new developer form" do
    render

    assert_select "form[action=?][method=?]", developers_path, "post" do

      assert_select "input#developer_name[name=?]", "developer[name]"
    end
  end
end
