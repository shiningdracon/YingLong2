create table comics(
	id int(10) unsigned NOT NULL AUTO_INCREMENT,
	title varchar(50) NOT NULL DEFAULT '',
	author varchar(50) NOT NULL DEFAULT '',
	poster varchar(200) NOT NULL DEFAULT '',
	page_count int(10) unsigned NOT NULL DEFAULT 0,
	description TEXT,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET=utf8;

create table pages(
	id int(10) unsigned NOT NULL AUTO_INCREMENT,
	comic_id int(10) unsigned NOT NULL,
	`index` int(10) unsigned NOT NULL,
	title varchar(50) NOT NULL DEFAULT '',
	poster varchar(200) NOT NULL DEFAULT '',
	description TEXT,
	content TEXT,
	PRIMARY KEY (`id`, comic_id, `index`)
) ENGINE=InnoDB CHARACTER SET=utf8;

create table chapters(
	id int(10) unsigned NOT NULL AUTO_INCREMENT,
	comic_id int(10) unsigned NOT NULL,
	page_id int(10) unsigned NOT NULL,
	title varchar(50) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET=utf8;

create table comments(
	id int(10) unsigned NOT NULL AUTO_INCREMENT,
	page_id int(10) unsigned NOT NULL,
	poster varchar(200) NOT NULL DEFAULT '',
	content TEXT,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET=utf8;

create table files(
	page_id int(10) unsigned NOT NULL,
	filename varchar(1024) NOT NULL,
	localname varchar(1024) NOT NULL,
	mimetype varchar(16) NOT NULL,
	size int(10) unsigned NOT NULL
) ENGINE=InnoDB CHARACTER SET=utf8;
