CREATE TABLE `admins` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `name_first` varchar(255) default NULL,
  `name_middle` varchar(255) default NULL,
  `name_last` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `time_zone` varchar(255) default 'Etc/UTC',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `visits_count` int(11) default NULL,
  `last_login_at` datetime default NULL,
  `password_reset_code` varchar(40) default NULL,
  `password_reset_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_admins_on_login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `assets` (
  `id` int(11) NOT NULL auto_increment,
  `parent_id` int(11) default NULL,
  `size` int(11) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `attachable_id` int(11) default NULL,
  `content_type` varchar(255) default NULL,
  `filename` varchar(255) default NULL,
  `thumbnail` varchar(255) default NULL,
  `checksum` varchar(255) default NULL,
  `attachable_type` varchar(255) default NULL,
  `is_duplicate` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `upload_ticket` varchar(255) default NULL,
  `length` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_assets_on_parent_id` (`parent_id`),
  KEY `index_assets_on_checksum` (`checksum`),
  KEY `index_assets_on_attachable_id_and_attachable_type` (`attachable_id`,`attachable_type`),
  KEY `index_assets_on_upload_ticket` (`upload_ticket`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `azoogle_accounts` (
  `id` int(11) NOT NULL auto_increment,
  `login_hash` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `azoogle_creatives` (
  `id` int(11) NOT NULL auto_increment,
  `azoogle_offer_id` int(11) default NULL,
  `sub_id` varchar(255) default NULL,
  `creative_type` varchar(255) default NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `data` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_azoogle_creatives_on_azoogle_offer_id_and_sub_id` (`azoogle_offer_id`,`sub_id`),
  KEY `index_azoogle_creatives_on_creative_type` (`creative_type`),
  KEY `index_azoogle_creatives_on_width_and_height` (`width`,`height`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `azoogle_offer_categories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_azoogle_offer_categories_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `azoogle_offers` (
  `id` int(11) NOT NULL auto_increment,
  `azoogle_account_id` int(11) default NULL,
  `offer_id` int(11) default NULL,
  `title` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `notices` varchar(255) default NULL,
  `open_date` date default NULL,
  `expiry_date` date default NULL,
  `amount` decimal(10,0) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_azoogle_offers_on_azoogle_account_id` (`azoogle_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(50) default '',
  `comment` text,
  `created_at` datetime NOT NULL,
  `commentable_id` int(11) NOT NULL default '0',
  `commentable_type` varchar(15) NOT NULL default '',
  `user_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_comments_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `favorites` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `favoriteable_id` int(11) default NULL,
  `favoriteable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_favorites_on_user_id` (`user_id`),
  KEY `index_favorites_on_favoriteable_type_and_favoriteable_id` (`favoriteable_type`,`favoriteable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hits` (
  `id` int(11) NOT NULL auto_increment,
  `hittable_type` varchar(255) default NULL,
  `kind` varchar(255) default NULL,
  `hittable_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_hits_on_hittable_id_and_hittable_type_and_kind` (`hittable_id`,`hittable_type`,`kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `images` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `description` varchar(255) default NULL,
  `profile_pic` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_images_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invite_emails` (
  `id` int(11) NOT NULL auto_increment,
  `email` varchar(255) default NULL,
  `delivered` tinyint(1) default NULL,
  `valid` tinyint(1) default NULL,
  `invite_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invites` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `friends` varchar(255) default NULL,
  `message` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` varchar(255) NOT NULL,
  `topic` varchar(255) default NULL,
  `data` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_messages_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL auto_increment,
  `uid` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL auto_increment,
  `country` varchar(255) default NULL,
  `state` varchar(255) default NULL,
  `zip` varchar(255) default NULL,
  `gender` varchar(255) default NULL,
  `university` varchar(255) default NULL,
  `dob` datetime default NULL,
  `start` datetime default NULL,
  `graduation` datetime default NULL,
  `receive_emails` tinyint(1) default NULL,
  `email_sent` tinyint(1) default NULL,
  `over_13` tinyint(1) default NULL,
  `terms` tinyint(1) default NULL,
  `user_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `classes` text,
  `website` varchar(255) default NULL,
  `city` varchar(255) default NULL,
  `bio` text,
  `paypal_email` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_profiles_on_paypal_email` (`paypal_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rates` (
  `id` int(11) NOT NULL auto_increment,
  `rate_name` varchar(255) default NULL,
  `rate` float default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ratings` (
  `id` int(11) NOT NULL auto_increment,
  `value` int(11) default '3',
  `user_id` int(11) default NULL,
  `rateable_id` int(11) default NULL,
  `rateable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_ratings_on_user_id` (`user_id`),
  KEY `index_ratings_on_rateable_id_and_rateable_type` (`rateable_id`,`rateable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `referrals` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(255) default NULL,
  `referrable_type` varchar(255) default NULL,
  `user_id` int(11) default NULL,
  `referrable_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_referrals_on_referrable_id_and_referrable_type` (`referrable_id`,`referrable_type`),
  KEY `index_referrals_on_code` (`code`),
  KEY `index_referrals_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) default NULL,
  `taggable_id` int(11) default NULL,
  `taggable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_taggings_on_tag_id` (`tag_id`),
  KEY `index_taggings_on_taggable_id_and_taggable_type` (`taggable_id`,`taggable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `is_category` tinyint(1) default '0',
  `description` varchar(255) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_tags_on_is_category` (`is_category`),
  KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `name_first` varchar(255) default NULL,
  `name_middle` varchar(255) default NULL,
  `name_last` varchar(255) default NULL,
  `crypted_password` varchar(40) default NULL,
  `salt` varchar(40) default NULL,
  `time_zone` varchar(255) default 'Etc/UTC',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `activation_code` varchar(40) default NULL,
  `activated_at` datetime default NULL,
  `visits_count` int(11) default NULL,
  `last_login_at` datetime default NULL,
  `password_reset_code` varchar(40) default NULL,
  `password_reset_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `videos` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `university` varchar(255) default NULL,
  `class_number` varchar(255) default NULL,
  `professor` varchar(255) default NULL,
  `subject` varchar(255) default NULL,
  `book_title` varchar(255) default NULL,
  `book_author` varchar(255) default NULL,
  `chapter` varchar(255) default NULL,
  `isbn` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `in_q` tinyint(1) default '0',
  `upload_ticket` varchar(255) default NULL,
  `approved` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_videos_on_user_id` (`user_id`),
  KEY `index_videos_on_in_q` (`in_q`),
  KEY `index_videos_on_upload_ticket` (`upload_ticket`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `schema_info` (version) VALUES (34)