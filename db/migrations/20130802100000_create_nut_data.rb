Sequel.migration do
  change do
    create_table :nut_data do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text, index: true
      foreign_key :nutr_no, :nutr_def, type: :text, index: true
      foreign_key :deriv_cd, :deriv_cd, type: :text
      foreign_key :src_cd, :src_cd, type: :text
      Float :nutr_val,        size: [10, 3],  null: false
      Fixnum :nutr_data_pts,  size: 5,        null: false
      Float :std_error,       size: [8, 3],   null: true
      String :ref_ndb_no,     size: 5,        null: true
      String :add_nutr_mark,  size: 1,        null: true
      Fixnum :num_studies,    size: 2,        null: true
      Float :min,             size: [10, 3],  null: true
      Float :max,             size: [10, 3],  null: true
      Fixnum :df,             size: 4,        null: true
      Float :low_eb,          size: [10, 3],  null: true
      Float :up_eb,           size: [10, 3],  null: true
      String :stat_cmt,       size: 10,       null: true
      String :addmod_date,    size: 10,       null: true
      String :cc,             size: 1,        null: true
    end
  end
end
