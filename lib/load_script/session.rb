require "logger"
require "pry"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      puts "user(s) are logging in"
      log_out
      session.visit host
      session.click_link("Log In")
      session.fill_in("email_address", with: email)
      session.fill_in("password", with: pw)
      session.click_link_or_button("Login")
    end

    def log_out
      puts "user(s) are logging out"

      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def new_request_title
      "#{Faker::Commerce.product_name} #{Time.now.to_i}"
    end

    def new_request_description
      "#{Faker::Company.catch_phrase} #{Time.now.to_i}"
    end

    def new_request_image
      @image ||= DefaultImages.random
    end

    def new_requested_by_date
      Faker::Time.between(7.days.ago, 3.days.ago)
    end

    def new_repayment_begin_date
      Faker::Time.between(3.days.ago, Time.now)
    end

    def categories
      ["blues", "rock", "jazz", "pop",
        "country", "metal", "edm", "reggae",
        "funk", "grunge", "indie", "punk",
        "r&b", "classical", "opera" ]
    end

    def actions
      [:sign_up_as_borrower, :sign_up_as_lender,
       :borrower_creates_LR, :lender_makes_loan,
       :browse_loan_requests, :browse_pages_of_LR,
       :view_individual_LR,
       :browse_category, :browse_pages_of_categories]
    end

    def sign_up_as_borrower(name = new_user_name)
      puts "signing up as borrower"

      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_lender(name = new_user_name)
      puts "signing up as lender"

      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def borrower_creates_LR
      puts "borrower(s) create loan requests"

      sign_up_as_borrower
      session.click_on("Create Loan Request")
      session.within("#loanRequestModal") do
        session.fill_in("loan_request_title", with: new_request_title)
        session.fill_in("loan_request_description", with: new_request_description)
        session.fill_in("loan_request_image_url", with: new_request_image)
        session.fill_in("loan_request_requested_by_date", with: new_requested_by_date)
        session.fill_in("loan_request_repayment_date", with: new_repayment_begin_date)
        session.select("blues", from: "loan_request_category")
        session.fill_in("loan_request_amount", with: "100")
        session.click_link_or_button("Submit")
      end
    end

    def view_individual_LR
      puts "user(s) are viewing individual loan request"

      log_in
      session.visit "#{host}/browse"
      session.all("a.lr-about").sample.click
    end

    def lender_makes_loan
      puts "lender(s) are making loan(s)"

      sign_up_as_lender
      view_individual_LR
      session.click_on("Contribute $25")
      session.click_on("Basket")
      session.click_on("Transfer Funds")
    end

    def browse_loan_requests
      puts "user(s) are browsing loan requests"

      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def browse_pages_of_LR
      puts "user(s) are browsing pages of loan requests"

      session.visit "#{host}/browse"
      session.all(".apple_pagination a").sample.click
    end

    def browse_category
      puts "user(s) are browsing a category"

      session.visit "#{host}/browse"
      categories = Category.all
      session.find("#category-dropdown").find("#{categories.sample.title}").select_option
    end

    def browse_pages_of_categories
      puts "user(s) are browsing pages of categories"

      browse_category
      session.all(".apple_pagination a").sample.click
    end

  end
end
