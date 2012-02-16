-- table structure for tcl pastebin
-- by leprechau@EFnet
-- 
-- 
-- create a database called `pastebin`
-- and import this sql syntax to create the table
--
-- ----------------------------------------------

CREATE TABLE `pastebin` (
  `pid` int(11) NOT NULL auto_increment,
  `poster` varchar(24) default NULL,
  `posted` datetime default NULL,
  `code` text,
  `parent_pid` int(11) default '0',
  `lang` varchar(24) default 'None',
  `description` varchar(84) default 'None',
  `channel` varchar(100) default 'None',
  PRIMARY KEY  (`pid`),
  FULLTEXT KEY `code` (`code`),
  FULLTEXT KEY `code_2` (`code`)
) TYPE=MyISAM AUTO_INCREMENT=1 ;