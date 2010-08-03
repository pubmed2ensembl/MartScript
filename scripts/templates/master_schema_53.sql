CREATE TABLE `alt_allele` (
  `alt_allele_id` int(10) unsigned NOT NULL auto_increment,
  `gene_id` int(10) unsigned NOT NULL default '0',
  UNIQUE KEY `gene_idx` (`gene_id`),
  UNIQUE KEY `allele_idx` (`alt_allele_id`,`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `analysis` (
  `analysis_id` smallint(5) unsigned NOT NULL auto_increment,
  `created` datetime NOT NULL default '0000-00-00 00:00:00',
  `logic_name` varchar(40) NOT NULL default '',
  `db` varchar(120) default NULL,
  `db_version` varchar(40) default NULL,
  `db_file` varchar(120) default NULL,
  `program` varchar(80) default NULL,
  `program_version` varchar(40) default NULL,
  `program_file` varchar(80) default NULL,
  `parameters` text,
  `module` varchar(80) default NULL,
  `module_version` varchar(40) default NULL,
  `gff_source` varchar(40) default NULL,
  `gff_feature` varchar(40) default NULL,
  PRIMARY KEY  (`analysis_id`),
  UNIQUE KEY `logic_name` (`logic_name`),
  KEY `logic_name_idx` (`logic_name`)
) ENGINE=MyISAM AUTO_INCREMENT=54 DEFAULT CHARSET=latin1;

CREATE TABLE `analysis_description` (
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `description` text,
  `display_label` varchar(255) default NULL,
  `displayable` tinyint(1) NOT NULL default '1',
  `web_data` text,
  UNIQUE KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `assembly` (
  `asm_seq_region_id` int(10) unsigned NOT NULL default '0',
  `cmp_seq_region_id` int(10) unsigned NOT NULL default '0',
  `asm_start` int(10) NOT NULL default '0',
  `asm_end` int(10) NOT NULL default '0',
  `cmp_start` int(10) NOT NULL default '0',
  `cmp_end` int(10) NOT NULL default '0',
  `ori` tinyint(4) NOT NULL default '0',
  UNIQUE KEY `all_idx` (`asm_seq_region_id`,`cmp_seq_region_id`,`asm_start`,`asm_end`,`cmp_start`,`cmp_end`,`ori`),
  KEY `cmp_seq_region_id` (`cmp_seq_region_id`),
  KEY `asm_seq_region_id` (`asm_seq_region_id`,`asm_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `assembly_exception` (
  `assembly_exception_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `exc_type` enum('HAP','PAR') NOT NULL default 'HAP',
  `exc_seq_region_id` int(10) unsigned NOT NULL default '0',
  `exc_seq_region_start` int(10) unsigned NOT NULL default '0',
  `exc_seq_region_end` int(10) unsigned NOT NULL default '0',
  `ori` int(11) NOT NULL default '0',
  PRIMARY KEY  (`assembly_exception_id`),
  KEY `sr_idx` (`seq_region_id`,`seq_region_start`),
  KEY `ex_idx` (`exc_seq_region_id`,`exc_seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `attrib_type` (
  `attrib_type_id` smallint(5) unsigned NOT NULL auto_increment,
  `code` varchar(15) NOT NULL default '',
  `name` varchar(255) NOT NULL default '',
  `description` text,
  PRIMARY KEY  (`attrib_type_id`),
  UNIQUE KEY `c` (`code`)
) ENGINE=MyISAM AUTO_INCREMENT=11114 DEFAULT CHARSET=latin1;

CREATE TABLE `coord_system` (
  `coord_system_id` int(10) unsigned NOT NULL auto_increment,
  `species_id` int(10) unsigned NOT NULL default '1',
  `name` varchar(40) NOT NULL default '',
  `version` varchar(255) default NULL,
  `rank` int(11) NOT NULL default '0',
  `attrib` set('default_version','sequence_level') default NULL,
  PRIMARY KEY  (`coord_system_id`),
  UNIQUE KEY `rank_idx` (`rank`,`species_id`),
  UNIQUE KEY `name_idx` (`name`,`version`,`species_id`),
  KEY `species_idx` (`species_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `density_feature` (
  `density_feature_id` int(10) unsigned NOT NULL auto_increment,
  `density_type_id` int(10) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `density_value` float NOT NULL default '0',
  PRIMARY KEY  (`density_feature_id`),
  KEY `seq_region_idx` (`density_type_id`,`seq_region_id`,`seq_region_start`),
  KEY `seq_region_id_idx` (`seq_region_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5937370 DEFAULT CHARSET=latin1;

CREATE TABLE `density_type` (
  `density_type_id` int(10) unsigned NOT NULL auto_increment,
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `block_size` int(11) NOT NULL default '0',
  `region_features` int(11) NOT NULL default '0',
  `value_type` enum('sum','ratio') NOT NULL default 'sum',
  PRIMARY KEY  (`density_type_id`),
  UNIQUE KEY `analysis_id` (`analysis_id`,`block_size`,`region_features`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

CREATE TABLE `ditag` (
  `ditag_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(30) NOT NULL default '',
  `type` varchar(30) NOT NULL default '',
  `tag_count` smallint(6) unsigned NOT NULL default '1',
  `sequence` tinytext NOT NULL,
  PRIMARY KEY  (`ditag_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `ditag_feature` (
  `ditag_feature_id` int(10) unsigned NOT NULL auto_increment,
  `ditag_id` int(10) unsigned NOT NULL default '0',
  `ditag_pair_id` int(10) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(1) NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `hit_start` int(10) unsigned NOT NULL default '0',
  `hit_end` int(10) unsigned NOT NULL default '0',
  `hit_strand` tinyint(1) NOT NULL default '0',
  `cigar_line` tinytext NOT NULL,
  `ditag_side` enum('F','L','R') NOT NULL default 'F',
  PRIMARY KEY  (`ditag_feature_id`),
  KEY `ditag_id` (`ditag_id`),
  KEY `ditag_pair_id` (`ditag_pair_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`,`seq_region_end`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `dna` (
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `sequence` longtext NOT NULL,
  PRIMARY KEY  (`seq_region_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=750000 AVG_ROW_LENGTH=19000;

CREATE TABLE `dna_align_feature` (
  `dna_align_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(1) NOT NULL default '0',
  `hit_start` int(11) NOT NULL default '0',
  `hit_end` int(11) NOT NULL default '0',
  `hit_strand` tinyint(1) NOT NULL default '0',
  `hit_name` varchar(40) NOT NULL default '',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `score` double default NULL,
  `evalue` double default NULL,
  `perc_ident` float default NULL,
  `cigar_line` text,
  `external_db_id` smallint(5) unsigned default NULL,
  `hcoverage` double default NULL,
  `external_data` text,
  `pair_dna_align_feature_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`dna_align_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`analysis_id`,`seq_region_start`,`score`),
  KEY `seq_region_idx_2` (`seq_region_id`,`seq_region_start`),
  KEY `hit_idx` (`hit_name`),
  KEY `analysis_idx` (`analysis_id`),
  KEY `external_db_idx` (`external_db_id`),
  KEY `pair_idx` (`pair_dna_align_feature_id`)
) ENGINE=MyISAM AUTO_INCREMENT=16796582 DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;

CREATE TABLE `dnac` (
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `sequence` mediumblob NOT NULL,
  `n_line` text,
  PRIMARY KEY  (`seq_region_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=750000 AVG_ROW_LENGTH=19000;

CREATE TABLE `exon` (
  `exon_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(2) NOT NULL default '0',
  `phase` tinyint(2) NOT NULL default '0',
  `end_phase` tinyint(2) NOT NULL default '0',
  `is_current` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`exon_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM AUTO_INCREMENT=444373 DEFAULT CHARSET=latin1;

CREATE TABLE `exon_stable_id` (
  `exon_id` int(10) unsigned NOT NULL default '0',
  `stable_id` varchar(128) NOT NULL default '',
  `version` int(10) default NULL,
  `created_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_date` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`exon_id`),
  KEY `stable_id_idx` (`stable_id`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `exon_transcript` (
  `exon_id` int(10) unsigned NOT NULL default '0',
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `rank` int(10) NOT NULL default '0',
  PRIMARY KEY  (`exon_id`,`transcript_id`,`rank`),
  KEY `transcript` (`transcript_id`),
  KEY `exon` (`exon_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `external_db` (
  `external_db_id` smallint(5) unsigned NOT NULL default '0',
  `db_name` varchar(40) NOT NULL,
  `db_release` varchar(255) default NULL,
  `status` enum('KNOWNXREF','KNOWN','XREF','PRED','ORTH','PSEUDO') NOT NULL default 'KNOWNXREF',
  `dbprimary_acc_linkable` tinyint(1) NOT NULL default '1',
  `display_label_linkable` tinyint(1) NOT NULL default '0',
  `priority` int(11) NOT NULL default '0',
  `db_display_name` varchar(255) default NULL,
  `type` enum('ARRAY','ALT_TRANS','MISC','LIT','PRIMARY_DB_SYNONYM','ENSEMBL') default NULL,
  `secondary_db_name` varchar(255) default NULL,
  `secondary_db_table` varchar(255) default NULL,
  `description` text,
  PRIMARY KEY  (`external_db_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `external_synonym` (
  `xref_id` int(10) unsigned NOT NULL default '0',
  `synonym` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`xref_id`,`synonym`),
  KEY `name_index` (`synonym`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `gene` (
  `gene_id` int(10) unsigned NOT NULL auto_increment,
  `biotype` varchar(40) NOT NULL default '',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(2) NOT NULL default '0',
  `display_xref_id` int(10) unsigned default NULL,
  `source` varchar(20) NOT NULL default '',
  `status` enum('KNOWN','NOVEL','PUTATIVE','PREDICTED','KNOWN_BY_PROJECTION','UNKNOWN') default NULL,
  `description` text,
  `is_current` tinyint(1) NOT NULL default '1',
  `canonical_transcript_id` int(10) unsigned NOT NULL,
  `canonical_annotation` varchar(255) default NULL,
  PRIMARY KEY  (`gene_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `xref_id_index` (`display_xref_id`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM AUTO_INCREMENT=49569 DEFAULT CHARSET=latin1;

CREATE TABLE `gene_archive` (
  `gene_stable_id` varchar(128) NOT NULL default '',
  `gene_version` smallint(6) NOT NULL default '0',
  `transcript_stable_id` varchar(128) NOT NULL default '',
  `transcript_version` smallint(6) NOT NULL default '0',
  `translation_stable_id` varchar(128) NOT NULL default '',
  `translation_version` smallint(6) NOT NULL default '0',
  `peptide_archive_id` int(10) unsigned NOT NULL default '0',
  `mapping_session_id` int(10) unsigned NOT NULL default '0',
  KEY `gene_idx` (`gene_stable_id`,`gene_version`),
  KEY `transcript_idx` (`transcript_stable_id`,`transcript_version`),
  KEY `translation_idx` (`translation_stable_id`,`translation_version`),
  KEY `peptide_archive_id_idx` (`peptide_archive_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `gene_attrib` (
  `gene_id` int(10) unsigned NOT NULL default '0',
  `attrib_type_id` smallint(5) unsigned NOT NULL default '0',
  `value` text NOT NULL,
  KEY `type_val_idx` (`attrib_type_id`,`value`(40)),
  KEY `val_only_idx` (`value`(40)),
  KEY `gene_idx` (`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `gene_stable_id` (
  `gene_id` int(10) unsigned NOT NULL default '0',
  `stable_id` varchar(128) NOT NULL default '',
  `version` int(10) default NULL,
  `created_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_date` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`gene_id`),
  KEY `stable_id_idx` (`stable_id`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `go_xref` (
  `object_xref_id` int(10) unsigned NOT NULL default '0',
  `linkage_type` enum('IC','IDA','IEA','IEP','IGI','IMP','IPI','ISS','NAS','ND','TAS','NR','RCA') NOT NULL default 'IC',
  `source_xref_id` int(10) unsigned default NULL,
  UNIQUE KEY `object_xref_id` (`object_xref_id`,`source_xref_id`,`linkage_type`),
  KEY `source_xref_id` (`source_xref_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `identity_xref` (
  `object_xref_id` int(10) unsigned NOT NULL default '0',
  `xref_identity` int(5) default NULL,
  `ensembl_identity` int(5) default NULL,
  `xref_start` int(11) default NULL,
  `xref_end` int(11) default NULL,
  `ensembl_start` int(11) default NULL,
  `ensembl_end` int(11) default NULL,
  `cigar_line` text,
  `score` double default NULL,
  `evalue` double default NULL,
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  PRIMARY KEY  (`object_xref_id`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `interpro` (
  `interpro_ac` varchar(40) NOT NULL default '',
  `id` varchar(40) NOT NULL default '',
  UNIQUE KEY `interpro_ac` (`interpro_ac`,`id`),
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `karyotype` (
  `karyotype_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) NOT NULL default '0',
  `seq_region_end` int(10) NOT NULL default '0',
  `band` varchar(40) NOT NULL default '',
  `stain` varchar(40) NOT NULL default '',
  PRIMARY KEY  (`karyotype_id`),
  KEY `region_band_idx` (`seq_region_id`,`band`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `map` (
  `map_id` int(10) unsigned NOT NULL auto_increment,
  `map_name` varchar(30) NOT NULL default '',
  PRIMARY KEY  (`map_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `mapping_session` (
  `mapping_session_id` int(10) unsigned NOT NULL auto_increment,
  `old_db_name` varchar(80) NOT NULL default '',
  `new_db_name` varchar(80) NOT NULL default '',
  `old_release` varchar(5) NOT NULL default '',
  `new_release` varchar(5) NOT NULL default '',
  `old_assembly` varchar(20) NOT NULL default '',
  `new_assembly` varchar(20) NOT NULL default '',
  `created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`mapping_session_id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `mapping_set` (
  `mapping_set_id` int(10) unsigned NOT NULL,
  `schema_build` varchar(20) NOT NULL,
  PRIMARY KEY  (`schema_build`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `marker` (
  `marker_id` int(10) unsigned NOT NULL auto_increment,
  `display_marker_synonym_id` int(10) unsigned default NULL,
  `left_primer` varchar(100) NOT NULL default '',
  `right_primer` varchar(100) NOT NULL default '',
  `min_primer_dist` int(10) unsigned NOT NULL default '0',
  `max_primer_dist` int(10) unsigned NOT NULL default '0',
  `priority` int(11) default NULL,
  `type` enum('est','microsatellite') default NULL,
  PRIMARY KEY  (`marker_id`),
  KEY `marker_idx` (`marker_id`,`priority`),
  KEY `display_idx` (`display_marker_synonym_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `marker_feature` (
  `marker_feature_id` int(10) unsigned NOT NULL auto_increment,
  `marker_id` int(10) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `map_weight` int(10) unsigned default NULL,
  PRIMARY KEY  (`marker_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `marker_map_location` (
  `marker_id` int(10) unsigned NOT NULL default '0',
  `map_id` int(10) unsigned NOT NULL default '0',
  `chromosome_name` varchar(15) NOT NULL default '',
  `marker_synonym_id` int(10) unsigned NOT NULL default '0',
  `position` varchar(15) NOT NULL default '',
  `lod_score` double default NULL,
  PRIMARY KEY  (`marker_id`,`map_id`),
  KEY `map_idx` (`map_id`,`chromosome_name`,`position`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `marker_synonym` (
  `marker_synonym_id` int(10) unsigned NOT NULL auto_increment,
  `marker_id` int(10) unsigned NOT NULL default '0',
  `source` varchar(20) default NULL,
  `name` varchar(50) default NULL,
  PRIMARY KEY  (`marker_synonym_id`),
  KEY `marker_synonym_idx` (`marker_synonym_id`,`name`),
  KEY `marker_idx` (`marker_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `meta` (
  `meta_id` int(11) NOT NULL auto_increment,
  `species_id` int(10) unsigned default '1',
  `meta_key` varchar(40) NOT NULL default '',
  `meta_value` varchar(255) character set latin1 collate latin1_bin NOT NULL,
  PRIMARY KEY  (`meta_id`),
  UNIQUE KEY `species_key_value_idx` (`species_id`,`meta_key`,`meta_value`),
  KEY `species_value_idx` (`species_id`,`meta_value`)
) ENGINE=MyISAM AUTO_INCREMENT=254 DEFAULT CHARSET=latin1;

CREATE TABLE `meta_coord` (
  `table_name` varchar(40) NOT NULL default '',
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  `max_length` int(11) default NULL,
  UNIQUE KEY `cs_table_name_idx` (`coord_system_id`,`table_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `misc_attrib` (
  `misc_feature_id` int(10) unsigned NOT NULL default '0',
  `attrib_type_id` smallint(5) unsigned NOT NULL default '0',
  `value` text NOT NULL,
  KEY `type_val_idx` (`attrib_type_id`,`value`(40)),
  KEY `val_only_idx` (`value`(40)),
  KEY `misc_feature_idx` (`misc_feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `misc_feature` (
  `misc_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`misc_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `misc_feature_misc_set` (
  `misc_feature_id` int(10) unsigned NOT NULL default '0',
  `misc_set_id` smallint(5) unsigned NOT NULL default '0',
  PRIMARY KEY  (`misc_feature_id`,`misc_set_id`),
  KEY `reverse_idx` (`misc_set_id`,`misc_feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `misc_set` (
  `misc_set_id` smallint(5) unsigned NOT NULL auto_increment,
  `code` varchar(25) NOT NULL default '',
  `name` varchar(255) NOT NULL default '',
  `description` text NOT NULL,
  `max_length` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`misc_set_id`),
  UNIQUE KEY `c` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `object_xref` (
  `object_xref_id` int(10) unsigned NOT NULL auto_increment,
  `ensembl_id` int(10) unsigned NOT NULL default '0',
  `ensembl_object_type` enum('RawContig','Transcript','Gene','Translation') NOT NULL,
  `xref_id` int(10) unsigned NOT NULL default '0',
  `linkage_annotation` varchar(255) default NULL,
  UNIQUE KEY `ensembl_object_type` (`ensembl_object_type`,`ensembl_id`,`xref_id`),
  KEY `oxref_idx` (`object_xref_id`,`xref_id`,`ensembl_object_type`,`ensembl_id`),
  KEY `xref_idx` (`xref_id`,`ensembl_object_type`)
) ENGINE=MyISAM AUTO_INCREMENT=813426 DEFAULT CHARSET=latin1;

CREATE TABLE `oligo_array` (
  `oligo_array_id` int(10) unsigned NOT NULL auto_increment,
  `parent_array_id` int(10) unsigned default NULL,
  `probe_setsize` tinyint(4) NOT NULL default '0',
  `name` varchar(40) NOT NULL default '',
  `type` enum('AFFY','OLIGO') default NULL,
  PRIMARY KEY  (`oligo_array_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `oligo_feature` (
  `oligo_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `mismatches` tinyint(4) default NULL,
  `oligo_probe_id` int(10) unsigned NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  PRIMARY KEY  (`oligo_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `probe_idx` (`oligo_probe_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `oligo_probe` (
  `oligo_probe_id` int(10) unsigned NOT NULL auto_increment,
  `oligo_array_id` int(10) unsigned NOT NULL default '0',
  `probeset` varchar(40) default NULL,
  `name` varchar(20) default NULL,
  `description` text,
  `length` smallint(6) NOT NULL default '0',
  PRIMARY KEY  (`oligo_probe_id`,`oligo_array_id`),
  KEY `probeset_idx` (`probeset`),
  KEY `array_idx` (`oligo_array_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `peptide_archive` (
  `peptide_archive_id` int(10) unsigned NOT NULL auto_increment,
  `md5_checksum` varchar(32) default NULL,
  `peptide_seq` mediumtext NOT NULL,
  PRIMARY KEY  (`peptide_archive_id`),
  KEY `checksum` (`md5_checksum`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `prediction_exon` (
  `prediction_exon_id` int(10) unsigned NOT NULL auto_increment,
  `prediction_transcript_id` int(10) unsigned NOT NULL default '0',
  `exon_rank` smallint(5) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `start_phase` tinyint(4) NOT NULL default '0',
  `score` double default NULL,
  `p_value` double default NULL,
  PRIMARY KEY  (`prediction_exon_id`),
  KEY `prediction_transcript_id` (`prediction_transcript_id`),
  KEY `seq_region_id` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM AUTO_INCREMENT=315482 DEFAULT CHARSET=latin1;

CREATE TABLE `prediction_transcript` (
  `prediction_transcript_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `display_label` varchar(255) default NULL,
  PRIMARY KEY  (`prediction_transcript_id`),
  KEY `seq_region_id` (`seq_region_id`,`seq_region_start`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM AUTO_INCREMENT=75991 DEFAULT CHARSET=latin1;

CREATE TABLE `protein_align_feature` (
  `protein_align_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(1) NOT NULL default '1',
  `hit_start` int(10) NOT NULL default '0',
  `hit_end` int(10) NOT NULL default '0',
  `hit_name` varchar(40) NOT NULL default '',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `score` double default NULL,
  `evalue` double default NULL,
  `perc_ident` float default NULL,
  `cigar_line` text,
  `external_db_id` smallint(5) unsigned default NULL,
  `hcoverage` double default NULL,
  PRIMARY KEY  (`protein_align_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`analysis_id`,`seq_region_start`,`score`),
  KEY `seq_region_idx_2` (`seq_region_id`,`seq_region_start`),
  KEY `hit_idx` (`hit_name`),
  KEY `analysis_idx` (`analysis_id`),
  KEY `external_db_idx` (`external_db_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5358527 DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;

CREATE TABLE `protein_feature` (
  `protein_feature_id` int(10) unsigned NOT NULL auto_increment,
  `translation_id` int(10) unsigned NOT NULL default '0',
  `seq_start` int(10) NOT NULL default '0',
  `seq_end` int(10) NOT NULL default '0',
  `hit_start` int(10) NOT NULL default '0',
  `hit_end` int(10) NOT NULL default '0',
  `hit_name` varchar(40) NOT NULL,
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `score` double default NULL,
  `evalue` double default NULL,
  `perc_ident` float default NULL,
  `external_data` text,
  PRIMARY KEY  (`protein_feature_id`),
  KEY `translation_id` (`translation_id`),
  KEY `analysis_idx` (`analysis_id`),
  KEY `hitname_idx` (`hit_name`)
) ENGINE=MyISAM AUTO_INCREMENT=268590 DEFAULT CHARSET=latin1;

CREATE TABLE `qtl` (
  `qtl_id` int(10) unsigned NOT NULL auto_increment,
  `trait` varchar(255) NOT NULL default '',
  `lod_score` float default NULL,
  `flank_marker_id_1` int(10) unsigned default NULL,
  `flank_marker_id_2` int(10) unsigned default NULL,
  `peak_marker_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`qtl_id`),
  KEY `trait_idx` (`trait`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `qtl_feature` (
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `qtl_id` int(10) unsigned NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  KEY `qtl_id` (`qtl_id`),
  KEY `loc_idx` (`seq_region_id`,`seq_region_start`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `qtl_synonym` (
  `qtl_synonym_id` int(10) unsigned NOT NULL auto_increment,
  `qtl_id` int(10) unsigned NOT NULL default '0',
  `source_database` enum('rat genome database','ratmap') NOT NULL default 'rat genome database',
  `source_primary_id` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`qtl_synonym_id`),
  KEY `qtl_idx` (`qtl_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `repeat_consensus` (
  `repeat_consensus_id` int(10) unsigned NOT NULL auto_increment,
  `repeat_name` varchar(255) NOT NULL default '',
  `repeat_class` varchar(100) NOT NULL default '',
  `repeat_type` varchar(40) NOT NULL default '',
  `repeat_consensus` text,
  PRIMARY KEY  (`repeat_consensus_id`),
  KEY `name` (`repeat_name`),
  KEY `class` (`repeat_class`),
  KEY `consensus` (`repeat_consensus`(10)),
  KEY `type` (`repeat_type`)
) ENGINE=MyISAM AUTO_INCREMENT=278961 DEFAULT CHARSET=latin1;

CREATE TABLE `repeat_feature` (
  `repeat_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(1) NOT NULL default '1',
  `repeat_start` int(10) NOT NULL default '0',
  `repeat_end` int(10) NOT NULL default '0',
  `repeat_consensus_id` int(10) unsigned NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `score` double default NULL,
  PRIMARY KEY  (`repeat_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `repeat_idx` (`repeat_consensus_id`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8371785 DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;

CREATE TABLE `seq_region` (
  `seq_region_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(40) NOT NULL default '',
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  `length` int(10) NOT NULL default '0',
  PRIMARY KEY  (`seq_region_id`),
  UNIQUE KEY `name_cs_idx` (`name`,`coord_system_id`),
  KEY `cs_idx` (`coord_system_id`)
) ENGINE=MyISAM AUTO_INCREMENT=859681 DEFAULT CHARSET=latin1;

CREATE TABLE `seq_region_attrib` (
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `attrib_type_id` smallint(5) unsigned NOT NULL default '0',
  `value` text NOT NULL,
  KEY `type_val_idx` (`attrib_type_id`,`value`(40)),
  KEY `val_only_idx` (`value`(40)),
  KEY `seq_region_idx` (`seq_region_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `seq_region_mapping` (
  `external_seq_region_id` int(10) unsigned NOT NULL,
  `internal_seq_region_id` int(10) unsigned NOT NULL,
  `mapping_set_id` int(10) unsigned NOT NULL,
  KEY `mapping_set_id` (`mapping_set_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `simple_feature` (
  `simple_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(1) NOT NULL default '0',
  `display_label` varchar(40) NOT NULL default '',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `score` double default NULL,
  PRIMARY KEY  (`simple_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `analysis_idx` (`analysis_id`),
  KEY `hit_idx` (`display_label`)
) ENGINE=MyISAM AUTO_INCREMENT=81292 DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;

CREATE TABLE `stable_id_event` (
  `old_stable_id` varchar(128) default NULL,
  `old_version` smallint(6) default NULL,
  `new_stable_id` varchar(128) default NULL,
  `new_version` smallint(6) default NULL,
  `mapping_session_id` int(10) unsigned NOT NULL default '0',
  `type` enum('gene','transcript','translation') NOT NULL default 'gene',
  `score` float NOT NULL default '0',
  UNIQUE KEY `uni_idx` (`mapping_session_id`,`old_stable_id`,`new_stable_id`,`type`),
  KEY `new_idx` (`new_stable_id`),
  KEY `old_idx` (`old_stable_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `supporting_feature` (
  `exon_id` int(10) unsigned NOT NULL default '0',
  `feature_type` enum('dna_align_feature','protein_align_feature') default NULL,
  `feature_id` int(10) unsigned NOT NULL default '0',
  UNIQUE KEY `all_idx` (`exon_id`,`feature_type`,`feature_id`),
  KEY `feature_idx` (`feature_type`,`feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;

CREATE TABLE `transcript` (
  `transcript_id` int(10) unsigned NOT NULL auto_increment,
  `gene_id` int(10) unsigned default NULL,
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(2) NOT NULL default '0',
  `display_xref_id` int(10) unsigned default NULL,
  `biotype` varchar(40) NOT NULL default '',
  `status` enum('KNOWN','NOVEL','PUTATIVE','PREDICTED','KNOWN_BY_PROJECTION','UNKNOWN') default NULL,
  `description` text,
  `is_current` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`transcript_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `gene_index` (`gene_id`),
  KEY `xref_id_index` (`display_xref_id`),
  KEY `analysis_idx` (`analysis_id`)
) ENGINE=MyISAM AUTO_INCREMENT=49568 DEFAULT CHARSET=latin1;

CREATE TABLE `transcript_attrib` (
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `attrib_type_id` smallint(5) unsigned NOT NULL default '0',
  `value` text NOT NULL,
  KEY `type_val_idx` (`attrib_type_id`,`value`(40)),
  KEY `val_only_idx` (`value`(40)),
  KEY `transcript_idx` (`transcript_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `transcript_stable_id` (
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `stable_id` varchar(128) NOT NULL default '',
  `version` int(10) default NULL,
  `created_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_date` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`transcript_id`),
  KEY `stable_id_idx` (`stable_id`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `transcript_supporting_feature` (
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `feature_type` enum('dna_align_feature','protein_align_feature') default NULL,
  `feature_id` int(10) unsigned NOT NULL default '0',
  UNIQUE KEY `all_idx` (`transcript_id`,`feature_type`,`feature_id`),
  KEY `feature_idx` (`feature_type`,`feature_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;

CREATE TABLE `translation` (
  `translation_id` int(10) unsigned NOT NULL auto_increment,
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `seq_start` int(10) NOT NULL default '0',
  `start_exon_id` int(10) unsigned NOT NULL default '0',
  `seq_end` int(10) NOT NULL default '0',
  `end_exon_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`translation_id`),
  KEY `transcript_id` (`transcript_id`)
) ENGINE=MyISAM AUTO_INCREMENT=34246 DEFAULT CHARSET=latin1;

CREATE TABLE `translation_attrib` (
  `translation_id` int(10) unsigned NOT NULL default '0',
  `attrib_type_id` smallint(5) unsigned NOT NULL default '0',
  `value` text NOT NULL,
  KEY `type_val_idx` (`attrib_type_id`,`value`(40)),
  KEY `val_only_idx` (`value`(40)),
  KEY `translation_idx` (`translation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `translation_stable_id` (
  `translation_id` int(10) unsigned NOT NULL default '0',
  `stable_id` varchar(128) NOT NULL default '',
  `version` int(10) default NULL,
  `created_date` datetime NOT NULL default '0000-00-00 00:00:00',
  `modified_date` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`translation_id`),
  KEY `stable_id_idx` (`stable_id`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `unconventional_transcript_association` (
  `transcript_id` int(10) unsigned NOT NULL default '0',
  `gene_id` int(10) unsigned NOT NULL default '0',
  `interaction_type` enum('antisense','sense_intronic','sense_overlaping_exonic','chimeric_sense_exonic') default NULL,
  KEY `transcript_id` (`transcript_id`),
  KEY `gene_id` (`gene_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `unmapped_object` (
  `unmapped_object_id` int(10) unsigned NOT NULL auto_increment,
  `type` enum('xref','cDNA','Marker','probe2transcript') NOT NULL default 'xref',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `external_db_id` smallint(5) unsigned default NULL,
  `identifier` varchar(255) NOT NULL default '',
  `unmapped_reason_id` smallint(5) unsigned NOT NULL default '0',
  `query_score` double default NULL,
  `target_score` double default NULL,
  `ensembl_id` int(10) unsigned default '0',
  `ensembl_object_type` enum('RawContig','Transcript','Gene','Translation') default 'RawContig',
  `parent` varchar(255) default NULL,
  PRIMARY KEY  (`unmapped_object_id`),
  KEY `id_idx` (`identifier`),
  KEY `anal_idx` (`analysis_id`),
  KEY `anal_exdb_idx` (`analysis_id`,`external_db_id`)
) ENGINE=MyISAM AUTO_INCREMENT=64 DEFAULT CHARSET=latin1;

CREATE TABLE `unmapped_reason` (
  `unmapped_reason_id` smallint(5) unsigned NOT NULL auto_increment,
  `summary_description` varchar(255) default NULL,
  `full_description` varchar(255) default NULL,
  PRIMARY KEY  (`unmapped_reason_id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;

CREATE TABLE `xref` (
  `xref_id` int(10) unsigned NOT NULL auto_increment,
  `external_db_id` smallint(5) unsigned NOT NULL default '0',
  `dbprimary_acc` varchar(40) NOT NULL default '',
  `display_label` varchar(128) NOT NULL default '',
  `version` varchar(10) NOT NULL default '0',
  `description` text,
  `info_type` enum('PROJECTION','MISC','DEPENDENT','DIRECT','SEQUENCE_MATCH','INFERRED_PAIR','PROBE','UNMAPPED','COORDINATE_OVERLAP') default NULL,
  `info_text` varchar(255) default NULL,
  PRIMARY KEY  (`xref_id`),
  UNIQUE KEY `id_index` (`dbprimary_acc`,`external_db_id`,`info_type`,`info_text`),
  KEY `display_index` (`display_label`),
  KEY `info_type_idx` (`info_type`)
) ENGINE=MyISAM AUTO_INCREMENT=828747 DEFAULT CHARSET=latin1;

