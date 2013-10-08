create table artists (
  id integer constraint artist_pk primary key,
  name varchar(255),
  numb_aliases integer
);

create table time (
  id integer constraint time_pk primary key,
  year integer,
  decade integer
);

create table artist_facts (
  artist_id integer,
  time_id integer,
  release_count integer,
  constraint artist_releases_artist_id foreign key (artist_id) references artists (id)
);
