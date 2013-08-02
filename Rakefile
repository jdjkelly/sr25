require "pp"
require "rubygems"
require "bundler/setup"
require "sequel"

DB = Sequel.connect(ENV["DB"])
total_time = 0

namespace :db do
  task :seed => [:drop_tables, :create_tables, :import_data] do
    puts "Seeding took #{total_time} seconds"
  end

  task :create_tables do
    DB.create_table :fd_group do
      primary_key :fdgrp_cd, type: :text
      String :fdgrp_desc, size: 60, null: false
    end

    DB.create_table :src_cd do
      primary_key :src_cd, type: :text
      String :srccd_desc, size: 60, null: false
    end

    DB.create_table :food_des do
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
    DB.run("ALTER TABLE food_des ADD tsv TSVector")
    DB.run("CREATE TRIGGER TS_tsv BEFORE INSERT OR UPDATE ON food_des FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger(tsv, 'pg_catalog.english', long_desc)")
    DB.run("CREATE INDEX tsv_GIN ON food_des USING GIN(tsv)")

    DB.create_table :nutr_def do
      primary_key :nutr_no, type: :text
      String :units,    size: 7,  null: false
      String :tagname,  size: 20, null: true
      String :nutrdesc, size: 60, null: false
      String :num_dec,  size: 1,  null: false
      Fixnum :sr_order, size: 6,  null: false
    end
    DB.run("CREATE INDEX nutr_no_idx ON nutr_def(nutr_no)")

    DB.create_table :data_src do
      primary_key :datasrc_id, type: :text
      String :authors, size: 255, null: true
      String :title, size: 255, null: true
      String :year, size: 4, null: true
      String :journal, size: 135, null: true
      String :vol_city, size: 16, null: true
      String :issue_state, size: 5, null: true
      String :start_page, size: 5, null: true
      String :end_page, size: 5, null: true
    end

    DB.create_table :datsrcln do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :nutr_no, :nutr_def, type: :text
      foreign_key :datasrc_id, :data_src, type: :text
    end

    DB.create_table :deriv_cd do
      primary_key :deriv_cd, type: :text
      String :deriv_desc, size: 120, null: false
    end

    DB.create_table :footnote do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :nutr_no, :nutr_def, type: :text
      String :footnt_no,  size: 4,    null: false
      String :footnt_typ, size: 1,    null: false
      String :footnt_txt, size: 200,  null: false
    end

    DB.create_table :langdesc do
      primary_key :factor_code, type: :text
      String :description, size: 140, null: false
    end

    DB.create_table :langual do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :factor_code, :langdesc, type: :text
    end

    DB.create_table :nut_data do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      foreign_key :nutr_no, :nutr_def, type: :text
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
    DB.run("CREATE INDEX ndb_no_idx ON nut_data(ndb_no)")

    DB.create_table :weight do
      primary_key :id
      foreign_key :ndb_no, :food_des, type: :text
      String :seq,          size: 2,      null: false
      Float :amount,        size: [5, 3], null: false
      String :msre_desc,    size: 84,     null: false
      Float :gm_weight,     size: [7, 1], null: false
      Fixnum :num_data_pts, size: 3,      null: true
    end
  end

  task :drop_tables do
    DB.drop_table?(:datsrcln,
                   :footnote,
                   :langual,
                   :nut_data,
                   :weight,
                   :data_src,
                   :langdesc,
                   :deriv_cd,
                   :nutr_def,
                   :food_des,
                   :src_cd,
                   :fd_group)
  end

  task :import_data => [:fd_group,
                        :src_cd,
                        :food_des,
                        :data_src,
                        :nutr_def,
                        :datsrcln,
                        :deriv_cd,
                        :footnote,
                        :langdesc,
                        :langual,
                        :nut_data,
                        :weight] do; end

  task :data_src do
    data_src = DB[:data_src]

    File.open("sr25/DATA_SRC.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:datasrc_id] = r[0].strip
        record[:authors] = string_or_null(r[1])
        record[:title] = string_or_null(r[2])
        record[:year] = string_or_null(r[3])
        record[:journal] = string_or_null(r[4])
        record[:vol_city] = string_or_null(r[5])
        record[:issue_state] = string_or_null(r[6])
        record[:start_page] = string_or_null(r[7])
        record[:end_page] = string_or_null(r[8])
        data_src.insert(record)
      end
      DB.run "VACUUM data_src"
      total_time += Time.now - start
      puts "DATA_SRC imported in #{Time.now - start} seconds"
    end
  end

  task :datsrcln do
    datsrcln = DB[:datsrcln]

    File.open("sr25/DATSRCLN.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:ndb_no] = r[0].strip
        record[:nutr_no] = r[1].strip
        record[:datasrc_id] = r[2].strip
        datsrcln.insert(record)
      end
      DB.run "VACUUM datsrcln"
      total_time += Time.now - start
      puts "DATSRCLN imported in #{Time.now - start} seconds"
    end
  end

  task :deriv_cd do
    deriv_cd = DB[:deriv_cd]

    File.open("sr25/DERIV_CD.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:deriv_cd] = r[0].strip
        record[:deriv_desc] = r[1].strip
        deriv_cd.insert(record)
      end
      DB.run "VACUUM deriv_cd"
      total_time += Time.now - start
      puts "DERIV_CD imported in #{Time.now - start} seconds"
    end
  end

  task :fd_group do
    fd_group = DB[:fd_group]

    File.open("sr25/FD_GROUP.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:fdgrp_cd] = r[0].strip
        record[:fdgrp_desc] = r[1].strip
        fd_group.insert(record)
      end
      DB.run "VACUUM fd_group"
      total_time += Time.now - start
      puts "FD_GROUP imported in #{Time.now - start} seconds"
    end
  end

  task :food_des do
    food_des = DB[:food_des]
    
    File.open("sr25/FOOD_DES.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:ndb_no] = r[0].strip
        record[:fdgrp_cd] = r[1].strip
        record[:long_desc] = r[2].strip
        record[:shrt_desc] = r[3].strip
        record[:comname] = string_or_null(r[4])
        record[:manufacname] = string_or_null(r[5])
        record[:survey] = boolean_or_null(r[6])
        record[:ref_desc] = string_or_null(r[7])
        record[:refuse] = fixnum_or_null(r[8])
        record[:sciname] = string_or_null(r[9])
        record[:n_factor] = float_or_null(r[10])
        record[:pro_factor] = float_or_null(r[11])
        record[:fat_factor] = float_or_null(r[12])
        record[:cho_factor] = float_or_null(r[13])
        food_des.insert(record)
      end
      DB.run "VACUUM food_des"
      total_time += Time.now - start
      puts "FOOD_DES imported in #{Time.now - start} seconds"
    end
  end

  task :footnote do
    footnote = DB[:footnote]
    
    File.open("sr25/FOOTNOTE.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:ndb_no] = r[0].strip
        record[:footnt_no] = r[1].strip
        record[:footnt_typ] = r[2].strip
        record[:nutr_no] = string_or_null(r[3])
        record[:footnt_txt] = r[4].strip
        footnote.insert(record)
      end
      DB.run "VACUUM footnote"
      total_time += Time.now - start
      puts "FOOTNOTE imported in #{Time.now - start} seconds"
    end
  end

  task :langdesc do
    langdesc = DB[:langdesc]

    File.open("sr25/LANGDESC.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:factor_code] = r[0].strip
        record[:description] = r[1].strip
        langdesc.insert(record)
      end
      DB.run "VACUUM langdesc"
      total_time += Time.now - start
      puts "LANG_DESC imported in #{Time.now - start} seconds"
    end
  end

  task :langual do
    langual = DB[:langual]

    File.open("sr25/LANGUAL.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:ndb_no] = r[0].strip
        record[:factor_code] = r[1].strip
        langual.insert(record)
      end
      DB.run "VACUUM langual"
      total_time += Time.now - start
      puts "LANGUAL imported in #{Time.now - start} seconds"
    end
  end

  task :nut_data do
    nut_data = DB[:nut_data]
      
    File.open("sr25/NUT_DATA.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:ndb_no] = r[0].strip
        record[:nutr_no] = r[1].strip
        record[:nutr_val] = float_or_null(r[2])
        record[:nutr_data_pts] = fixnum_or_null(r[3])
        record[:std_error] = float_or_null(r[4])
        record[:src_cd] = string_or_null(r[5])
        record[:deriv_cd] = string_or_null(r[6])
        record[:ref_ndb_no] = string_or_null(r[7])
        record[:add_nutr_mark] = string_or_null(r[8])
        record[:num_studies] = fixnum_or_null(r[9])
        record[:min] = float_or_null(r[10])
        record[:max] = float_or_null(r[11])
        record[:df] = fixnum_or_null(r[12])
        record[:low_eb] = float_or_null(r[13])
        record[:up_eb] = float_or_null(r[14])
        record[:stat_cmt] = string_or_null(r[15])
        record[:addmod_date] = string_or_null(r[16])
        record[:cc] = string_or_null(r[17])
        nut_data.insert(record)
      end
      DB.run "VACUUM nut_data"
      total_time += Time.now - start
      puts "NUT_DATA imported in #{Time.now - start} seconds"
    end
  end

  task :nutr_def do
    nutr_def = DB[:nutr_def]

    File.open("sr25/NUTR_DEF.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:nutr_no] = r[0].strip
        record[:units] = r[1].strip
        record[:tagname] = string_or_null(r[2])
        record[:nutrdesc] = r[3].strip
        record[:num_dec] = r[4].strip
        record[:sr_order] = fixnum_or_null(r[5])
        nutr_def.insert(record)
      end
      DB.run "VACUUM nutr_def"
      total_time += Time.now - start
      puts "NUTR_DEF imported in #{Time.now - start} seconds"
    end
  end

  task :src_cd do
    src_cd = DB[:src_cd]

    File.open("sr25/SRC_CD.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        record = {}
        record[:src_cd] = r[0].strip
        record[:srccd_desc] = r[1].strip
        src_cd.insert(record)
      end
      DB.run "VACUUM src_cd"
      total_time += Time.now - start
      puts "SRC_CD imported in #{Time.now - start} seconds"
    end
  end

  task :weight do
    weight = DB[:weight]
    
    File.open("sr25/WEIGHT.txt", "r") do |f|
      start = Time.now
      f.each do |l|
        l.gsub!(/~/, "")
        r = l.split("^")
        r.pop
        record = {}
        record[:ndb_no] = r[0].strip
        record[:seq] = r[1].strip
        record[:amount] = r[2].to_f
        record[:msre_desc] = r[3].strip
        record[:gm_weight] = r[4].to_f
        record[:num_data_pts] = fixnum_or_null(r[5])
        weight.insert(record)
      end
      DB.run "VACUUM weight"
      total_time += Time.now - start
      puts "WEIGHT imported in #{Time.now - start} seconds"
    end
  end
end

def string_or_null(s)
  s = s.strip
  s.empty? ? nil : s
end

def fixnum_or_null(n)
  n = n.strip
  n.to_i || nil
end

def float_or_null(n)
  n = n.strip
  n.to_f || nil
end

def boolean_or_null(s)
  s = s.strip.downcase
  s == "y" ? true : false
end
