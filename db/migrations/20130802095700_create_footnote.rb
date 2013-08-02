Sequel.migration do
  change do
    create_table :footnote do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :nutr_no, :nutr_def, type: :text
      String :footnt_no,  size: 4,    null: false
      String :footnt_typ, size: 1,    null: false
      String :footnt_txt, size: 200,  null: false
    end
  end
end
