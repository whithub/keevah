class AddIndexToJoinTable < ActiveRecord::Migration
  def change
    add_index :loan_requests_categories, [:loan_request_id, :category_id], name: 'load_req_compound'
    add_index :loan_requests_contributors, [:loan_request_id, :user_id], name: 'load_req_contrib_compound'

    add_index :orders, :user_id
  end
end
