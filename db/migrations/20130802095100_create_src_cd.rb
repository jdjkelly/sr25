Sequel.migration do
  change do
    create_table :src_cd do
      primary_key :src_cd, type: :text
      String :srccd_desc, size: 60, null: false
    end
  end
end
