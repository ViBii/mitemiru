require 'rails_helper'

RSpec.describe "redmine_keys/index", type: :view do
  before(:each) do
    assign(:redmine_keys, [
      RedmineKey.create!(),
      RedmineKey.create!()
    ])
  end

  it "renders a list of redmine_keys" do
    render
  end
end
