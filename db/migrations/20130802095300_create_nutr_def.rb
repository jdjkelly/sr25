Sequel.migration do
  change do
    create_table :nutr_def do
      primary_key :nutr_no, type: :text, index: true
      String :units,    size: 7,  null: false
      String :tagname,  size: 20, null: true
      String :nutrdesc, size: 60, null: false
      String :num_dec,  size: 1,  null: false
      Fixnum :sr_order, size: 6,  null: false
    end
  end
end
