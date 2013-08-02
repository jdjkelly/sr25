Sequel.migration do
  change do
    create_table :deriv_cd do
      primary_key :deriv_cd, type: :text
      String :deriv_desc, size: 120, null: false
    end
  end
end
