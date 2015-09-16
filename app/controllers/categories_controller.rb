class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @categories = Category.all
    @category = Category.includes(:loan_requests).find(params[:id])
    @loan_requests = @category.loan_requests.paginate(:page => params[:page], :per_page => 12)
  end

end
