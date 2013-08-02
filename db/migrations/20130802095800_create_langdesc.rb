Sequel.migration do
  change do
    create_table :langdesc do
      primary_key :factor_code, type: :text
      String :description, size: 140, null: false
    end
  end
end
