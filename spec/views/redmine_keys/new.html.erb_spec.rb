require 'rails_helper'

RSpec.describe "redmine_keys/new", type: :view do
  before(:each) do
    assign(:redmine_key, RedmineKey.new())
  end

  it "renders new redmine_key form" do
    render

    assert_select "form[action=?][method=?]", redmine_keys_path, "post" do
    end
  end
end
