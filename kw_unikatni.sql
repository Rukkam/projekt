DROP TABLE IF EXISTS keywords_unique;

CREATE TABLE `keywords_unique` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `keyword` varchar(100) NOT NULL,
  `lemmatized_kw` varchar(100) DEFAULT NULL,
  `morfologie` varchar(45) DEFAULT NULL,
  `to_be_used` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lemma` (`lemmatized_kw`) /*!80000 INVISIBLE */,
  KEY `keyword` (`keyword`)
) ENGINE=InnoDB AUTO_INCREMENT=8192 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO keywords_unique (keyword)
SELECT DISTINCT keyword FROM firm_keywords
WHERE kw_status = 0
ORDER BY keyword;
