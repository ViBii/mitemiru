require 'rails_helper'

RSpec.describe "redmine_keys/edit", type: :view do
  before(:each) do
    @redmine_key = assign(:redmine_key, RedmineKey.create!())
  end

  it "renders the edit redmine_key form" do
    render

    assert_select "form[action=?][method=?]", redmine_key_path(@redmine_key), "post" do
    end
  end
end
