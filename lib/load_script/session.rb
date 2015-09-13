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
      log_out
      session.visit host
      session.click_link("Log In")
      session.fill_in("email_address", with: email)
      session.fill_in("password", with: pw)
      session.click_link_or_button("Login")
    end

    def log_out
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

    def categories
      ["blues", "rock", "jazz", "pop", "country", "metal", "edm", "reggae", "funk", "grunge", "indie", "punk", "r&b", "classical", "opera" ]
    end

    def actions
      [:sign_up_as_lender, :sign_up_as_borrower,
       :lender_makes_loan, :borrower_creates_LR,
       :browse_loan_requests, :browse_pages_of_LR,
       :view_individual_LR,
       :browse_categories, :browse_pages_of_categories]
    end

    def sign_up_as_lender(name = new_user_name)
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

    def sign_up_as_borrower
      skip
    end

    def lender_makes_loan
      skip
    end

    def borrower_creates_LR
      skip
    end

    def browse_loan_requests
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def browse_pages_of_LR
      skip
    end

    def view_individual_LR
      skip
    end

    def browse_categories
      session.visit "#{host}/browse"
      categories = Category.all
      session.find("#category-dropdown").find("#{categories.sample.title}").select_option
    end

    def browse_pages_of_categories
      skip
    end

  end
end
