-- $rake
-- $sqlite3 development.sqlite3 < .sql
ATTACH DATABASE 'db/mst_development.sqlite3' as mst;

-- .tables;
insert into floater_types select * from mst.floater_types;
insert into pairs select * from mst.pairs;

-- addtional
-- insert into xchanges select * from mst.xchanges;
-- insert into quotes select * from mst.quotes;
-- insert into rss_sources select * from mst.rss_sources;
-- insert into floaters select * from mst.floaters;

-- remaster
-- rm -rf mst_development.sqlite3
-- cp development.sqlite3 mst_development.sqlite3
-- ATTACH DATABASE 'mst_development.sqlite3' as mst;
-- delete from mst.sqlite_sequences where name in ('floater_types', 'pairs', 'ticker_symbols')
