#!/bin/bash
cd `dirname $0`
mysql -u root -p peckr_development < utils_import_floater_types.sql
mysql -u root -p peckr_development < utils_import_pairs.sql
mysql -u root -p peckr_development < utils_import_rss_sources.sql
mysql -u root -p peckr_development < utils_import_ticker_symbols.sql