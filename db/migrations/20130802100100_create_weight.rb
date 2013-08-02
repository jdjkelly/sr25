Sequel.migration do
  change do
    create_table :weight do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      String :seq,          size: 2,      null: false
      Float :amount,        size: [5, 3], null: false
      String :msre_desc,    size: 84,     null: false
      Float :gm_weight,     size: [7, 1], null: false
      Fixnum :num_data_pts, size: 3,      null: true
    end
  end
end
