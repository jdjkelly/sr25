Sequel.migration do
  change do
    create_table :food_des do
      primary_key :ndb_no, type: :text
      foreign_key :fdgrp_cd, :fd_group, type: :text
      String :long_desc,    size: 200,    null: false
      String :shrt_desc,    size: 60,     null: false
      String :comname,      size: 100,    null: true
      String :manufacname,  size: 65,     null: true
      TrueClass :survey,                  null: true
      String :ref_desc,     size: 135,    null: true
      Fixnum :refuse,       size: 2,      null: true
      String :sciname,      size: 65,     null: true
      Float :n_factor,      size: [4, 2], null: true
      Float :pro_factor,    size: [4, 2], null: true
      Float :fat_factor,    size: [4, 2], null: true
      Float :cho_factor,    size: [4, 2], null: true
    end

    # enable full text search and auto-update trigger
    DB.run("ALTER TABLE food_des ADD tsv TSVector")
    DB.run("CREATE TRIGGER TS_tsv BEFORE INSERT OR UPDATE ON food_des FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger(tsv, 'pg_catalog.english', long_desc)")
    DB.run("CREATE INDEX tsv_long_desc ON food_des USING GIN(tsv)")
  end
end
