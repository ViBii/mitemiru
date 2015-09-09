require 'rails_helper'

RSpec.describe "redmine_keys/show", type: :view do
  before(:each) do
    @redmine_key = assign(:redmine_key, RedmineKey.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
