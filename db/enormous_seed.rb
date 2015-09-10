require 'populator'
require 'faker'

module EnormousSeed
  class Seed
    def run
      # create_known_users
      # create_borrowers(32000)
      # create_lenders(202000)
      # create_categories
      # create_loan_requests_for_each_borrower(502000)
      create_orders(52000)
    end

    def lenders
      @lenders ||= User.where(role: 0)
    end

    def borrowers
      @borrowers ||= User.where(role: 1)
    end

    def orders
      Order.all
    end

    def loan_request_ids
      @loan_requests ||= LoanRequest.pluck(:id)
    end

    def create_known_users
      User.create(name: "Jorge", email: "jorge@example.com", password: "password")
      User.create(name: "Rachel", email: "rachel@example.com", password: "password")
      User.create(name: "Josh", email: "josh@example.com", password: "password", role: 1)
    end

    def create_lenders(quantity)
      User.populate(quantity) do |user|
        user.name = Faker::Name.name
        user.email = Faker::Internet.email
        user.password_digest = "$2a$10$8ip.78OpyOKZrGysQA3urO65VZ.6VbpbXr6JXyKRMKajQyzN4wdLq"
        user.role = 0
        puts "created lender #{user.name}"
      end
    end

    def create_borrowers(quantity)
      User.populate(quantity) do |user|
        user.name = Faker::Name.name
        user.email = Faker::Internet.email
        user.password_digest = "$2a$10$8ip.78OpyOKZrGysQA3urO65VZ.6VbpbXr6JXyKRMKajQyzN4wdLq"
        user.role = 1
        puts "created borrower #{user.name}"
      end
    end

    def create_categories
      categories = ["blues", "rock", "jazz", "pop", "country", "metal", "edm", "reggae", "funk", "grunge", "indie", "punk", "r&b", "classical", "opera" ]
      categories.each do |cat|
        Category.create(title: cat, description: cat + " stuff")
      end
    end

    def create_loan_requests_for_each_borrower(quantity)
      brw = borrowers
      categories = Category.all

      LoanRequest.populate(quantity) do |loan_request|
        loan_request.title = Faker::Commerce.product_name
        loan_request.description = Faker::Company.catch_phrase
        loan_request.amount = 200
        loan_request.status = [0, 1].sample
        loan_request.requested_by_date = Faker::Time.between(7.days.ago, 3.days.ago)
        loan_request.repayment_begin_date = Faker::Time.between(3.days.ago, Time.now)
        loan_request.repayment_rate = 1
        loan_request.contributed = 0
        loan_request.repayed = 0
        loan_request.user_id = brw.sample.id

        LoanRequestsCategory.populate(2) do |lr_category|
          lr_category.loan_request_id = loan_request.id
          lr_category.category_id = categories.sample.id
        end

      end
    end

    def create_orders(quantity)
      possible_donations = %w(25, 50, 75, 100, 125, 150, 175, 200)
      quantity.times do
        lender = lenders.sample
        request_id = loan_request_ids.sample
        order = Order.create(cart_items:
                            { "#{request_id}" => possible_donations.sample },
                            user_id: lender.id)
        order.update_contributed(lender)
        puts "Created Order by Lender #{lender.name}"
      end
    end
  end
end
