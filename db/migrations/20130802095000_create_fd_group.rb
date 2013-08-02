Sequel.migration do
  change do
    create_table :fd_group do
      primary_key :fdgrp_cd, type: :text
      String :fdgrp_desc, size: 60, null: false
    end
  end
end
