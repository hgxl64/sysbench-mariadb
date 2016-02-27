-- workload to test effect of MDEV6150 (connect speed)
-- reconnects for each transaction
-- RO does a single SELECT 1
-- RW does the configured number of point selects
-- no BEGIN/COMMIT statements used


pathtest = string.match(test, "(.*/)") or ""

dofile(pathtest .. "common.lua")

function thread_init(thread_id)
   set_vars()
   db_disconnect()
end

function event(thread_id)
   db_connect()
   if oltp_read_only then
      rs = db_query("SELECT 1")
   else   
      local table_name
      table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)
      for i=1, oltp_point_selects do
         rs = db_query("SELECT c FROM ".. table_name .." WHERE id=" .. sb_rand(1, oltp_table_size))
      end
   end
   db_disconnect()
end

