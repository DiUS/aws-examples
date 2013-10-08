
--
-- !connect jdbc:hive2://localhost:10000 hive hive org.apache.hive.jdbc.HiveDriver
--

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=1000;

create external table if not exists indent_header_stage (
  indent_id int,
  buyer_id int,
  supplier_id int,
  indent_numb_prefix string,
  indent_numb int,
  indent_date timestamp,
  salesperson_id int,
  buyer_ref string,
  location_id int,
  payment_method_id int,
  payment_terms string,
  currency_code string,
  sampling_remarks string,
  other_remarks string,
  buyer_confirmed boolean,
  buyer_confirmation_ref string,
  supplier_confirmed boolean,
  supplier_confirmation_ref string
)
row format delimited
fields terminated by '\t'
stored as textfile
location 's3://aws-examples.dius.com.au/sources/indent_header.tsv.bz2';

create external table if not exists indent_header (
  indent_id int,
  buyer_id int,
  supplier_id int,
  indent_numb_prefix string,
  indent_numb int,
  indent_date timestamp,
  salesperson_id int,
  buyer_ref string,
  location_id int,
  payment_method_id int,
  payment_terms string,
  currency_code string,
  sampling_remarks string,
  other_remarks string,
  buyer_confirmed boolean,
  buyer_confirmation_ref string,
  supplier_confirmed boolean,
  supplier_confirmation_ref string
)
partitioned by (indent_year int, indent_month int)
row format serde 'org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe'
stored as rcfile
location '/user/cam/warehouse/indent/header';

insert overwrite table indent_header
partition(indent_year, indent_month)
select ihs.*, year(ihs.indent_date), month(ihs.indent_date)
from indent_header_stage ihs

create external table if not exists indent_item (
  item_id int,
  indent_id int,
  item_numb int,
  article string,
  design string,
  content string,
  weight string,
  finish string,
  width string,
  buyer_code string,
  colourway string,
  quantity int,
  unit_type_id int,
  sampling_quantity int,
  sampling_location_id int,
  sampling_remarks string,
  price float,
  price_type_id int,
  delivery_ex_id int,
  delivery_date timestamp,
  delivery_method_id int,
  other_remarks string
)
row format delimited
fields terminated by '\t'
stored as textfile
location 's3://aws-examples.dius.com.au/sources/indent_item.tsv.bz2';
