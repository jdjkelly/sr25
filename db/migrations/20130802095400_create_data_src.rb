Sequel.migration do
  change do
    create_table :data_src do
      primary_key :datasrc_id, type: :text
      String :authors, size: 255, null: true
      String :title, size: 255, null: true
      String :year, size: 4, null: true
      String :journal, size: 135, null: true
      String :vol_city, size: 16, null: true
      String :issue_state, size: 5, null: true
      String :start_page, size: 5, null: true
      String :end_page, size: 5, null: true
    end
  end
end
