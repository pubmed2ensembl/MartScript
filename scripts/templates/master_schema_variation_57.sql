CREATE TABLE `allele` (
  `allele_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `variation_id` int(10) unsigned NOT NULL,
  `subsnp_id` int(15) unsigned DEFAULT NULL,
  `allele` varchar(255) DEFAULT NULL,
  `frequency` float DEFAULT NULL,
  `sample_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`allele_id`),
  KEY `variation_idx` (`variation_id`,`allele`(10)),
  KEY `subsnp_idx` (`subsnp_id`)
) ENGINE=MyISAM AUTO_INCREMENT=45037903 DEFAULT CHARSET=latin1;

CREATE TABLE `allele_group` (
  `allele_group_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `variation_group_id` int(10) unsigned NOT NULL,
  `sample_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `source_id` int(10) unsigned DEFAULT NULL,
  `frequency` float DEFAULT NULL,
  PRIMARY KEY (`allele_group_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `allele_group_allele` (
  `allele_group_id` int(10) unsigned NOT NULL,
  `allele` varchar(255) NOT NULL,
  `variation_id` int(10) unsigned NOT NULL,
  UNIQUE KEY `allele_group_id` (`allele_group_id`,`variation_id`),
  KEY `allele_idx` (`variation_id`,`allele_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `compressed_genotype_single_bp` (
  `sample_id` int(10) unsigned NOT NULL,
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start` int(11) NOT NULL,
  `seq_region_end` int(11) NOT NULL,
  `seq_region_strand` tinyint(4) NOT NULL,
  `genotypes` blob,
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000;

CREATE TABLE `failed_description` (
  `failed_description_id` int(10) unsigned NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`failed_description_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `failed_variation` (
  `variation_id` int(10) unsigned NOT NULL,
  `failed_description_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`variation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `flanking_sequence` (
  `variation_id` int(10) unsigned NOT NULL,
  `up_seq` text,
  `down_seq` text,
  `up_seq_region_start` int(11) DEFAULT NULL,
  `up_seq_region_end` int(11) DEFAULT NULL,
  `down_seq_region_start` int(11) DEFAULT NULL,
  `down_seq_region_end` int(11) DEFAULT NULL,
  `seq_region_id` int(10) unsigned DEFAULT NULL,
  `seq_region_strand` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`variation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000;

CREATE TABLE `httag` (
  `httag_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `variation_group_id` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `source_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`httag_id`),
  KEY `variation_group_idx` (`variation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual` (
  `sample_id` int(10) unsigned NOT NULL,
  `gender` enum('Male','Female','Unknown') NOT NULL DEFAULT 'Unknown',
  `father_individual_sample_id` int(10) unsigned DEFAULT NULL,
  `mother_individual_sample_id` int(10) unsigned DEFAULT NULL,
  `individual_type_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual_genotype_multiple_bp` (
  `variation_id` int(10) unsigned NOT NULL,
  `subsnp_id` int(15) unsigned DEFAULT NULL,
  `allele_1` varchar(255) DEFAULT NULL,
  `allele_2` varchar(255) DEFAULT NULL,
  `sample_id` int(10) unsigned DEFAULT NULL,
  KEY `variation_idx` (`variation_id`),
  KEY `sample_idx` (`sample_id`),
  KEY `subsnp_idx` (`subsnp_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual_population` (
  `individual_sample_id` int(10) unsigned NOT NULL,
  `population_sample_id` int(10) unsigned NOT NULL,
  KEY `individual_sample_idx` (`individual_sample_id`),
  KEY `population_sample_idx` (`population_sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `individual_type` (
  `individual_type_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY (`individual_type_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `meta` (
  `meta_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `species_id` int(10) unsigned DEFAULT '1',
  `meta_key` varchar(40) NOT NULL,
  `meta_value` varchar(255) NOT NULL,
  PRIMARY KEY (`meta_id`),
  UNIQUE KEY `species_key_value_idx` (`species_id`,`meta_key`,`meta_value`),
  KEY `species_value_idx` (`species_id`,`meta_value`)
) ENGINE=MyISAM AUTO_INCREMENT=89 DEFAULT CHARSET=latin1;

CREATE TABLE `meta_coord` (
  `table_name` varchar(40) NOT NULL,
  `coord_system_id` int(10) unsigned NOT NULL,
  `max_length` int(11) DEFAULT NULL,
  UNIQUE KEY `table_name` (`table_name`,`coord_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `phenotype` (
  `phenotype_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`phenotype_id`),
  UNIQUE KEY `name_idx` (`name`),
  UNIQUE KEY `description` (`description`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `population` (
  `sample_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `population_genotype` (
  `population_genotype_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `variation_id` int(10) unsigned NOT NULL,
  `subsnp_id` int(15) unsigned DEFAULT NULL,
  `allele_1` varchar(255) DEFAULT NULL,
  `allele_2` varchar(255) DEFAULT NULL,
  `frequency` float DEFAULT NULL,
  `sample_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`population_genotype_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `sample_idx` (`sample_id`),
  KEY `subsnp_idx` (`subsnp_id`)
) ENGINE=MyISAM AUTO_INCREMENT=22394784 DEFAULT CHARSET=latin1;

CREATE TABLE `population_structure` (
  `super_population_sample_id` int(10) unsigned NOT NULL,
  `sub_population_sample_id` int(10) unsigned NOT NULL,
  UNIQUE KEY `super_population_sample_id` (`super_population_sample_id`,`sub_population_sample_id`),
  KEY `sub_pop_sample_idx` (`sub_population_sample_id`,`super_population_sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `read_coverage` (
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start` int(11) NOT NULL,
  `seq_region_end` int(11) NOT NULL,
  `level` tinyint(4) NOT NULL,
  `sample_id` int(10) unsigned NOT NULL,
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `sample` (
  `sample_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `size` int(11) DEFAULT NULL,
  `description` text,
  `display` enum('REFERENCE','DEFAULT','DISPLAYABLE','UNDISPLAYABLE','LD') DEFAULT 'UNDISPLAYABLE',
  PRIMARY KEY (`sample_id`),
  KEY `name_idx` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=151 DEFAULT CHARSET=latin1;

CREATE TABLE `sample_synonym` (
  `sample_synonym_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sample_id` int(10) unsigned NOT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`sample_synonym_id`),
  KEY `sample_idx` (`sample_id`),
  KEY `name` (`name`,`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=135 DEFAULT CHARSET=latin1;

CREATE TABLE `seq_region` (
  `seq_region_id` int(10) unsigned NOT NULL,
  `name` varchar(40) NOT NULL,
  PRIMARY KEY (`seq_region_id`),
  UNIQUE KEY `name_idx` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `source` (
  `source_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `strain_gtype_poly` (
  `variation_id` int(10) unsigned NOT NULL,
  `B10_D2_H2_oSnJ` varchar(100) DEFAULT NULL,
  `MRL_MpJ` varchar(100) DEFAULT NULL,
  `A_HeJ` varchar(100) DEFAULT NULL,
  `A_J` varchar(100) DEFAULT NULL,
  `AKR_J` varchar(100) DEFAULT NULL,
  `BALB_cJ` varchar(100) DEFAULT NULL,
  `C3H_HeJ` varchar(100) DEFAULT NULL,
  `C57BL_6J` varchar(100) DEFAULT NULL,
  `DBA_2J` varchar(100) DEFAULT NULL,
  `NZB_BlNJ` varchar(100) DEFAULT NULL,
  `129X1_SvJ` varchar(100) DEFAULT NULL,
  `CAST_EiJ` varchar(100) DEFAULT NULL,
  `BALB_cByJ` varchar(100) DEFAULT NULL,
  `NZW_LacJ` varchar(100) DEFAULT NULL,
  `SPRET_Ei` varchar(100) DEFAULT NULL,
  `129S1_SvImJ` varchar(100) DEFAULT NULL,
  `NOD_LTJ` varchar(100) DEFAULT NULL,
  `SAMP1` varchar(100) DEFAULT NULL,
  `SAMP8` varchar(100) DEFAULT NULL,
  `SAMR1` varchar(100) DEFAULT NULL,
  `SWR_J` varchar(100) DEFAULT NULL,
  `CBA_J` varchar(100) DEFAULT NULL,
  `AKR` varchar(100) DEFAULT NULL,
  `129P4_J` varchar(100) DEFAULT NULL,
  `CAST_Ei` varchar(100) DEFAULT NULL,
  `129S6_SvEvTac` varchar(100) DEFAULT NULL,
  `CZECHII_Ei` varchar(100) DEFAULT NULL,
  `129X1_Sv` varchar(100) DEFAULT NULL,
  `A` varchar(100) DEFAULT NULL,
  `A_He` varchar(100) DEFAULT NULL,
  `B10_D2` varchar(100) DEFAULT NULL,
  `BALB_c` varchar(100) DEFAULT NULL,
  `BALB_cBy` varchar(100) DEFAULT NULL,
  `C3H_He` varchar(100) DEFAULT NULL,
  `C57BL_6` varchar(100) DEFAULT NULL,
  `DBA_2` varchar(100) DEFAULT NULL,
  `MRL_MP` varchar(100) DEFAULT NULL,
  `NZB_BlN` varchar(100) DEFAULT NULL,
  `NZW_Lac` varchar(100) DEFAULT NULL,
  `129_Sv` varchar(100) DEFAULT NULL,
  `BUB_BnJ` varchar(100) DEFAULT NULL,
  `C57BL_10J` varchar(100) DEFAULT NULL,
  `C57BLKS_J` varchar(100) DEFAULT NULL,
  `C57BR_cdJ` varchar(100) DEFAULT NULL,
  `C57L_J` varchar(100) DEFAULT NULL,
  `C58_J` varchar(100) DEFAULT NULL,
  `CE_J` varchar(100) DEFAULT NULL,
  `DBA_1J` varchar(100) DEFAULT NULL,
  `FVB_NJ` varchar(100) DEFAULT NULL,
  `I_LnJ` varchar(100) DEFAULT NULL,
  `KK_HlJ` varchar(100) DEFAULT NULL,
  `LG_J` varchar(100) DEFAULT NULL,
  `LP_J` varchar(100) DEFAULT NULL,
  `MA_MyJ` varchar(100) DEFAULT NULL,
  `NON_LtJ` varchar(100) DEFAULT NULL,
  `PL_J` varchar(100) DEFAULT NULL,
  `RIIIS_J` varchar(100) DEFAULT NULL,
  `SEA_GnJ` varchar(100) DEFAULT NULL,
  `SJL_J` varchar(100) DEFAULT NULL,
  `SM_J` varchar(100) DEFAULT NULL,
  `ST_bJ` varchar(100) DEFAULT NULL,
  `WSB_EiJ` varchar(100) DEFAULT NULL,
  `ZALENDE_EiJ` varchar(100) DEFAULT NULL,
  `PERA_EiJ` varchar(100) DEFAULT NULL,
  `MOLF_EiJ` varchar(100) DEFAULT NULL,
  `CZECHII_EiJ` varchar(100) DEFAULT NULL,
  `BTBR_T__tf_J` varchar(100) DEFAULT NULL,
  `DDK_Pas` varchar(100) DEFAULT NULL,
  `JF1_Ms` varchar(100) DEFAULT NULL,
  `MAI_Pas` varchar(100) DEFAULT NULL,
  `MSM_Ms` varchar(100) DEFAULT NULL,
  `PWD_Ph` varchar(100) DEFAULT NULL,
  `SEG_Pas` varchar(100) DEFAULT NULL,
  `BUB` varchar(100) DEFAULT NULL,
  `FVB` varchar(100) DEFAULT NULL,
  `LGJ` varchar(100) DEFAULT NULL,
  `LPJ` varchar(100) DEFAULT NULL,
  `MOLF` varchar(100) DEFAULT NULL,
  `MSM` varchar(100) DEFAULT NULL,
  `PERA` varchar(100) DEFAULT NULL,
  `SMJ` varchar(100) DEFAULT NULL,
  `129S4_SvJae` varchar(100) DEFAULT NULL,
  `AVZ_Ms` varchar(100) DEFAULT NULL,
  `BALB_cUCSD` varchar(100) DEFAULT NULL,
  `BFM_2Ms` varchar(100) DEFAULT NULL,
  `BLG2_Ms` varchar(100) DEFAULT NULL,
  `CHD_Ms` varchar(100) DEFAULT NULL,
  `HMI_Ms` varchar(100) DEFAULT NULL,
  `KJR_Ms` varchar(100) DEFAULT NULL,
  `NJL_Ms` varchar(100) DEFAULT NULL,
  `PGN2_Ms` varchar(100) DEFAULT NULL,
  `SWN_Ms` varchar(100) DEFAULT NULL,
  `PWD_PhJ` varchar(100) DEFAULT NULL,
  `BALB_cA` varchar(100) DEFAULT NULL,
  `TSOD` varchar(100) DEFAULT NULL,
  `129P3_J` varchar(100) DEFAULT NULL,
  `129_NBT` varchar(100) DEFAULT NULL,
  `CSS_NBT` varchar(100) DEFAULT NULL,
  `NOD_DIL` varchar(100) DEFAULT NULL,
  `reference_C57BL_6J` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`variation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `structural_variation` (
  `structural_variation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start` int(11) NOT NULL,
  `seq_region_end` int(11) NOT NULL,
  `seq_region_strand` tinyint(4) NOT NULL,
  `variation_name` varchar(255) DEFAULT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `class` varchar(255) DEFAULT NULL,
  `bound_start` int(11) DEFAULT NULL,
  `bound_end` int(11) DEFAULT NULL,
  PRIMARY KEY (`structural_variation_id`),
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `subsnp_handle` (
  `subsnp_id` int(11) unsigned NOT NULL,
  `handle` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`subsnp_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `tagged_variation_feature` (
  `variation_feature_id` int(10) unsigned NOT NULL,
  `sample_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`variation_feature_id`,`sample_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `tmp_individual_genotype_single_bp` (
  `variation_id` int(11) NOT NULL,
  `subsnp_id` int(15) unsigned DEFAULT NULL,
  `allele_1` varchar(255) DEFAULT NULL,
  `allele_2` varchar(255) DEFAULT NULL,
  `sample_id` int(11) DEFAULT NULL,
  KEY `variation_idx` (`variation_id`),
  KEY `sample_idx` (`sample_id`),
  KEY `subsnp_idx` (`subsnp_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000;

CREATE TABLE `transcript_variation` (
  `transcript_variation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `transcript_id` int(10) unsigned NOT NULL,
  `variation_feature_id` int(10) unsigned NOT NULL,
  `cdna_start` int(11) DEFAULT NULL,
  `cdna_end` int(11) DEFAULT NULL,
  `translation_start` int(11) DEFAULT NULL,
  `translation_end` int(11) DEFAULT NULL,
  `peptide_allele_string` varchar(255) DEFAULT NULL,
  `consequence_type` set('ESSENTIAL_SPLICE_SITE','STOP_GAINED','STOP_LOST','COMPLEX_INDEL','FRAMESHIFT_CODING','NON_SYNONYMOUS_CODING','SPLICE_SITE','PARTIAL_CODON','SYNONYMOUS_CODING','REGULATORY_REGION','WITHIN_MATURE_miRNA','5PRIME_UTR','3PRIME_UTR','INTRONIC','UPSTREAM','DOWNSTREAM','WITHIN_NON_CODING_GENE','NO_CONSEQUENCE','INTERGENIC') NOT NULL DEFAULT 'INTERGENIC',
  PRIMARY KEY (`transcript_variation_id`),
  KEY `variation_idx` (`variation_feature_id`),
  KEY `transcript_idx` (`transcript_id`),
  KEY `consequence_type_idx` (`consequence_type`)
) ENGINE=MyISAM AUTO_INCREMENT=134859278 DEFAULT CHARSET=latin1;

CREATE TABLE `variation` (
  `variation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `source_id` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `validation_status` set('cluster','freq','submitter','doublehit','hapmap','failed') DEFAULT NULL,
  `ancestral_allele` text,
  PRIMARY KEY (`variation_id`),
  UNIQUE KEY `name` (`name`),
  KEY `source_idx` (`source_id`)
) ENGINE=MyISAM AUTO_INCREMENT=21578191 DEFAULT CHARSET=latin1;

CREATE TABLE `variation_annotation` (
  `variation_annotation_id` int(10) NOT NULL AUTO_INCREMENT,
  `variation_id` int(10) unsigned NOT NULL,
  `phenotype_id` int(10) unsigned NOT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `study` varchar(30) DEFAULT NULL,
  `study_type` set('GWAS') DEFAULT NULL,
  `local_stable_id` varchar(255) DEFAULT NULL,
  `associated_gene` varchar(255) DEFAULT NULL,
  `associated_variant_risk_allele` varchar(255) DEFAULT NULL,
  `variation_names` varchar(255) DEFAULT NULL,
  `risk_allele_freq_in_controls` varchar(30) DEFAULT NULL,
  `p_value` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`variation_annotation_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `phenotype_idx` (`phenotype_id`),
  KEY `source_idx` (`source_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_feature` (
  `variation_feature_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start` int(11) NOT NULL,
  `seq_region_end` int(11) NOT NULL,
  `seq_region_strand` tinyint(4) NOT NULL,
  `variation_id` int(10) unsigned NOT NULL,
  `allele_string` text,
  `variation_name` varchar(255) DEFAULT NULL,
  `map_weight` int(11) NOT NULL,
  `flags` set('genotyped') DEFAULT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `validation_status` set('cluster','freq','submitter','doublehit','hapmap') DEFAULT NULL,
  `consequence_type` set('ESSENTIAL_SPLICE_SITE','STOP_GAINED','STOP_LOST','COMPLEX_INDEL','FRAMESHIFT_CODING','NON_SYNONYMOUS_CODING','SPLICE_SITE','PARTIAL_CODON','SYNONYMOUS_CODING','REGULATORY_REGION','WITHIN_MATURE_miRNA','5PRIME_UTR','3PRIME_UTR','INTRONIC','UPSTREAM','DOWNSTREAM','WITHIN_NON_CODING_GENE','NO_CONSEQUENCE','INTERGENIC') NOT NULL DEFAULT 'INTERGENIC',
  PRIMARY KEY (`variation_feature_id`),
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`),
  KEY `variation_idx` (`variation_id`)
) ENGINE=MyISAM AUTO_INCREMENT=23430487 DEFAULT CHARSET=latin1;

CREATE TABLE `variation_group` (
  `variation_group_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `type` enum('haplotype','tag') DEFAULT NULL,
  PRIMARY KEY (`variation_group_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_group_feature` (
  `variation_group_feature_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `seq_region_id` int(10) unsigned NOT NULL,
  `seq_region_start` int(11) NOT NULL,
  `seq_region_end` int(11) NOT NULL,
  `seq_region_strand` tinyint(4) NOT NULL,
  `variation_group_id` int(10) unsigned NOT NULL,
  `variation_group_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`variation_group_feature_id`),
  KEY `pos_idx` (`seq_region_id`,`seq_region_start`),
  KEY `variation_group_idx` (`variation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_group_variation` (
  `variation_id` int(10) unsigned NOT NULL,
  `variation_group_id` int(10) unsigned NOT NULL,
  UNIQUE KEY `variation_group_id` (`variation_group_id`,`variation_id`),
  KEY `variation_idx` (`variation_id`,`variation_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_set` (
  `variation_set_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`variation_set_id`),
  KEY `name_idx` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_set_structure` (
  `variation_set_super` int(10) unsigned NOT NULL,
  `variation_set_sub` int(10) unsigned NOT NULL,
  PRIMARY KEY (`variation_set_super`,`variation_set_sub`),
  KEY `sub_idx` (`variation_set_sub`,`variation_set_super`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_set_variation` (
  `variation_id` int(10) unsigned NOT NULL,
  `variation_set_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`variation_id`,`variation_set_id`),
  KEY `variation_set_idx` (`variation_set_id`,`variation_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `variation_synonym` (
  `variation_synonym_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `variation_id` int(10) unsigned NOT NULL,
  `subsnp_id` int(15) unsigned DEFAULT NULL,
  `source_id` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `moltype` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`variation_synonym_id`),
  UNIQUE KEY `name` (`name`,`source_id`),
  KEY `variation_idx` (`variation_id`),
  KEY `source_idx` (`source_id`),
  KEY `subsnp_idx` (`subsnp_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6156136 DEFAULT CHARSET=latin1;

