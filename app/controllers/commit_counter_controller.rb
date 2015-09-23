class CommitCounterController < ApplicationController
  def index
    @developer = Developer.all;
  end
end
