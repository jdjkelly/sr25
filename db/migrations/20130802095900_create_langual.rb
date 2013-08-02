Sequel.migration do
  change do
    create_table :langual do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :factor_code, :langdesc, type: :text
    end
  end
end
