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

create table uploaded_files(
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`created` int(10) unsigned NOT NULL,
	`file_name` varchar(1024) NOT NULL,
	`local_name` varchar(1024) NOT NULL,
	`size` int(10) unsigned NOT NULL
	`hash` char(128) DEFAULT NULL,
	`mime_type` varchar(16) NOT NULL,
	`user_id` int(10) unsigned,
	PRIMARY KEY (`id`),
	KEY `Hash` (`size`,`hash`) USING BTREE,
) ENGINE=InnoDB CHARACTER SET=utf8;

create table folders(
	`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
) ENGINE=InnoDB CHARACTER SET=utf8;

create table file_in_folder(
	`file_id` int(10) unsigned NOT NULL,
	`folder_id` int(10) unsigned NOT NULL,
	KEY `map` (`file_id`,`folder_id`) USING BTREE,
) ENGINE=InnoDB CHARACTER SET=utf8;

create table file_in_post(
	`file_id` int(10) unsigned NOT NULL,
	`post_id` int(10) unsigned NOT NULL,
	KEY `map` (`file_id`,`post_id`) USING BTREE,
) ENGINE=InnoDB CHARACTER SET=utf8;

create table file_in_comic_page(
	`file_id` int(10) unsigned NOT NULL,
	`page_id` int(10) unsigned NOT NULL,
	KEY `map` (`file_id`,`page_id`) USING BTREE,
) ENGINE=InnoDB CHARACTER SET=utf8;
