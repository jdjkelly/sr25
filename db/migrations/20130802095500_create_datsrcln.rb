Sequel.migration do
  change do
    create_table :datsrcln do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :nutr_no, :nutr_def, type: :text
      foreign_key :datasrc_id, :data_src, type: :text
    end
  end
end
