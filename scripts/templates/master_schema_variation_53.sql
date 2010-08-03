CREATE TABLE `allele` (
  `allele_id` int(10) unsigned NOT NULL auto_increment,
  `variation_id` int(10) unsigned NOT NULL default '0',
  `allele` varchar(255) default NULL,
  `frequency` float default NULL,
  `sample_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`allele_id`),
  KEY `variation_idx` (`variation_id`,`allele`(10))
) ENGINE=MyISAM AUTO_INCREMENT=2275886 DEFAULT CHARSET=latin1;

CREATE TABLE `allele_group` (
  `allele_group_id` int(10) unsigned NOT NULL auto_increment,
  `variation_group_id` int(10) unsigned NOT NULL default '0',
  `sample_id` int(10) unsigned default NULL,
  `name` varchar(255) default NULL,
  `source_id` int(10) unsigned default NULL,
  `frequency` float default NULL,
  PRIMARY KEY  (`allele_group_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `allele_group_allele` (
  `allele_group_id` int(10) unsigned NOT NULL default '0',
  `allele` varchar(255) NOT NULL default '',
  `variation_id` int(10) unsigned NOT NULL default '0',
  UNIQUE KEY `allele_group_id` (`allele_group_id`,`variation_id`),
  KEY `allele_idx` (`variation_id`,`allele_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `compressed_genotype_single_bp` (
  `sample_id` int(10) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(11) NOT NULL default '0',
  `seq_region_end` int(11) NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `genotypes` blob,
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `failed_description` (
  `failed_description_id` int(10) unsigned NOT NULL default '0',
  `description` text NOT NULL,
  PRIMARY KEY  (`failed_description_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `failed_variation` (
  `variation_id` int(10) unsigned NOT NULL default '0',
  `failed_description_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`variation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `flanking_sequence` (
  `variation_id` int(10) unsigned NOT NULL default '0',
  `up_seq` text,
  `down_seq` text,
  `up_seq_region_start` int(11) default NULL,
  `up_seq_region_end` int(11) default NULL,
  `down_seq_region_start` int(11) default NULL,
  `down_seq_region_end` int(11) default NULL,
  `seq_region_id` int(10) unsigned default NULL,
  `seq_region_strand` tinyint(4) default NULL,
  PRIMARY KEY  (`variation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000;

CREATE TABLE `httag` (
  `httag_id` int(10) unsigned NOT NULL auto_increment,
  `variation_group_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(255) default NULL,
  `source_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`httag_id`),
  KEY `variation_group_idx` (`variation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual` (
  `sample_id` int(10) unsigned NOT NULL default '0',
  `gender` enum('Male','Female','Unknown') NOT NULL default 'Unknown',
  `father_individual_sample_id` int(10) unsigned default NULL,
  `mother_individual_sample_id` int(10) unsigned default NULL,
  `individual_type_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual_genotype_multiple_bp` (
  `variation_id` int(10) unsigned NOT NULL default '0',
  `allele_1` varchar(255) default NULL,
  `allele_2` varchar(255) default NULL,
  `sample_id` int(10) unsigned default NULL,
  KEY `variation_idx` (`variation_id`),
  KEY `sample_idx` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual_population` (
  `individual_sample_id` int(10) unsigned NOT NULL default '0',
  `population_sample_id` int(10) unsigned NOT NULL default '0',
  KEY `individual_sample_idx` (`individual_sample_id`),
  KEY `population_sample_idx` (`population_sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual_type` (
  `individual_type_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` text,
  PRIMARY KEY  (`individual_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `meta` (
  `meta_id` int(10) unsigned NOT NULL auto_increment,
  `species_id` int(10) unsigned default '1',
  `meta_key` varchar(40) NOT NULL default '',
  `meta_value` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`meta_id`),
  UNIQUE KEY `species_key_value_idx` (`species_id`,`meta_key`,`meta_value`),
  KEY `species_value_idx` (`species_id`,`meta_value`)
) ENGINE=MyISAM AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;

CREATE TABLE `meta_coord` (
  `table_name` varchar(40) NOT NULL default '',
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  `max_length` int(11) default NULL,
  UNIQUE KEY `table_name` (`table_name`,`coord_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `phenotype` (
  `phenotype_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`phenotype_id`),
  UNIQUE KEY `name_idx` (`name`),
  UNIQUE KEY `description` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `population` (
  `sample_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `population_genotype` (
  `population_genotype_id` int(10) unsigned NOT NULL auto_increment,
  `variation_id` int(10) unsigned NOT NULL default '0',
  `allele_1` varchar(255) default NULL,
  `allele_2` varchar(255) default NULL,
  `frequency` float default NULL,
  `sample_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`population_genotype_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `sample_idx` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `population_structure` (
  `super_population_sample_id` int(10) unsigned NOT NULL default '0',
  `sub_population_sample_id` int(10) unsigned NOT NULL default '0',
  UNIQUE KEY `super_population_sample_id` (`super_population_sample_id`,`sub_population_sample_id`),
  KEY `sub_pop_sample_idx` (`sub_population_sample_id`,`super_population_sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `read_coverage` (
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(11) NOT NULL default '0',
  `seq_region_end` int(11) NOT NULL default '0',
  `level` tinyint(4) NOT NULL default '0',
  `sample_id` int(10) unsigned NOT NULL default '0',
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sample` (
  `sample_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `size` int(11) default NULL,
  `description` text,
  PRIMARY KEY  (`sample_id`),
  KEY `name_idx` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

CREATE TABLE `sample_synonym` (
  `sample_synonym_id` int(10) unsigned NOT NULL auto_increment,
  `sample_id` int(10) unsigned NOT NULL default '0',
  `source_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(255) default NULL,
  PRIMARY KEY  (`sample_synonym_id`),
  KEY `sample_idx` (`sample_id`),
  KEY `name` (`name`,`source_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `seq_region` (
  `seq_region_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`seq_region_id`),
  UNIQUE KEY `name_idx` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=22830 DEFAULT CHARSET=latin1;

CREATE TABLE `source` (
  `source_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `version` int(11) default NULL,
  PRIMARY KEY  (`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `tagged_variation_feature` (
  `variation_feature_id` int(10) unsigned NOT NULL default '0',
  `sample_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`variation_feature_id`,`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `tmp_individual_genotype_single_bp` (
  `variation_id` int(11) NOT NULL,
  `allele_1` varchar(255) default NULL,
  `allele_2` varchar(255) default NULL,
  `sample_id` int(11) default NULL,
  KEY `variation_idx` (`variation_id`),
  KEY `sample_idx` (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000;

CREATE TABLE `transcript_variation` (
  `transcript_variation_id` int(10) unsigned NOT NULL auto_increment,
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `variation_feature_id` int(10) unsigned NOT NULL default '0',
  `cdna_start` int(11) default NULL,
  `cdna_end` int(11) default NULL,
  `translation_start` int(11) default NULL,
  `translation_end` int(11) default NULL,
  `peptide_allele_string` varchar(255) default NULL,
  `consequence_type` set('ESSENTIAL_SPLICE_SITE','STOP_GAINED','STOP_LOST','COMPLEX_INDEL','FRAMESHIFT_CODING','NON_SYNONYMOUS_CODING','SPLICE_SITE','SYNONYMOUS_CODING','REGULATORY_REGION','WITHIN_MATURE_miRNA','5PRIME_UTR','3PRIME_UTR','INTRONIC','UPSTREAM','DOWNSTREAM','WITHIN_NON_CODING_GENE') NOT NULL,
  PRIMARY KEY  (`transcript_variation_id`),
  KEY `variation_idx` (`variation_feature_id`),
  KEY `transcript_idx` (`transcript_id`),
  KEY `consequence_type_idx` (`consequence_type`)
) ENGINE=MyISAM AUTO_INCREMENT=1924886 DEFAULT CHARSET=latin1;

CREATE TABLE `variation` (
  `variation_id` int(10) unsigned NOT NULL auto_increment,
  `source_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(255) default NULL,
  `validation_status` set('cluster','freq','submitter','doublehit','hapmap','failed') default NULL,
  `ancestral_allele` text,
  PRIMARY KEY  (`variation_id`),
  UNIQUE KEY `name` (`name`),
  KEY `source_idx` (`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1136269 DEFAULT CHARSET=latin1;

CREATE TABLE `variation_annotation` (
  `variation_annotation_id` int(10) NOT NULL auto_increment,
  `variation_id` int(10) unsigned NOT NULL,
  `phenotype_id` int(10) unsigned NOT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `study` varchar(30) default NULL,
  `study_type` set('GWAS') default NULL,
  `local_stable_id` varchar(255) default NULL,
  `associated_gene` varchar(255) default NULL,
  `associated_variant_risk_allele` varchar(255) default NULL,
  `variation_names` varchar(255) default NULL,
  `risk_allele_freq_in_controls` varchar(30) default NULL,
  `p_value` varchar(20) default NULL,
  PRIMARY KEY  (`variation_annotation_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `phenotype_idx` (`phenotype_id`),
  KEY `source_idx` (`source_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_feature` (
  `variation_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(11) NOT NULL default '0',
  `seq_region_end` int(11) NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `variation_id` int(10) unsigned NOT NULL default '0',
  `allele_string` text,
  `variation_name` varchar(255) default NULL,
  `map_weight` int(11) NOT NULL default '0',
  `flags` set('genotyped') default NULL,
  `source_id` int(10) unsigned NOT NULL default '0',
  `validation_status` set('cluster','freq','submitter','doublehit','hapmap') default NULL,
  `consequence_type` set('ESSENTIAL_SPLICE_SITE','STOP_GAINED','STOP_LOST','COMPLEX_INDEL','FRAMESHIFT_CODING','NON_SYNONYMOUS_CODING','SPLICE_SITE','SYNONYMOUS_CODING','REGULATORY_REGION','WITHIN_MATURE_miRNA','5PRIME_UTR','3PRIME_UTR','INTRONIC','UPSTREAM','DOWNSTREAM','WITHIN_NON_CODING_GENE','INTERGENIC') NOT NULL default 'INTERGENIC',
  PRIMARY KEY  (`variation_feature_id`),
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`),
  KEY `variation_idx` (`variation_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1147227 DEFAULT CHARSET=latin1;

CREATE TABLE `variation_group` (
  `variation_group_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `source_id` int(10) unsigned NOT NULL default '0',
  `type` enum('haplotype','tag') default NULL,
  PRIMARY KEY  (`variation_group_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_group_feature` (
  `variation_group_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(11) NOT NULL default '0',
  `seq_region_end` int(11) NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `variation_group_id` int(10) unsigned NOT NULL default '0',
  `variation_group_name` varchar(255) default NULL,
  PRIMARY KEY  (`variation_group_feature_id`),
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`),
  KEY `variation_group_idx` (`variation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_group_variation` (
  `variation_id` int(10) unsigned NOT NULL default '0',
  `variation_group_id` int(10) unsigned NOT NULL default '0',
  UNIQUE KEY `variation_group_id` (`variation_group_id`,`variation_id`),
  KEY `variation_idx` (`variation_id`,`variation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_synonym` (
  `variation_synonym_id` int(10) unsigned NOT NULL auto_increment,
  `variation_id` int(10) unsigned NOT NULL default '0',
  `source_id` int(10) unsigned NOT NULL default '0',
  `name` varchar(255) default NULL,
  `moltype` varchar(50) default NULL,
  PRIMARY KEY  (`variation_synonym_id`),
  UNIQUE KEY `name` (`name`,`source_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `source_idx` (`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3815 DEFAULT CHARSET=latin1;

