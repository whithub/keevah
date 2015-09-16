class CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def show
    @categories = Category.all
    @category = Category.find(params[:id])

    last_loan_request = LoanRequest.last
    @loan_requests = Rails.cache.fetch("category-#{params[:id]}-page-#{params[:page] || 1}-#{last_loan_request.created_at}") do
      @category.loan_requests.paginate(:page => params[:page], :per_page => 12)
    end
  end

end
