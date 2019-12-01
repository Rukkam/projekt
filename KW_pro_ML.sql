-- 
CREATE TABLE keywords_unique_1500x (
	lemmatized_kw VARCHAR(100),
    PRIMARY KEY (lemmatized_kw)
    )ENGINE=InnoDB AUTO_INCREMENT=204797 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO keywords_unique_1500x (lemmatized_kw)
SELECT l.lemmatized_kw FROM firm_keywords f
JOIN keywords_unique l ON f.keyword = l.keyword
GROUP BY l.lemmatized_kw
HAVING count(l.lemmatized_kw) >= 1500;

UPDATE keywords_unique
SET to_be_used = 0;

UPDATE keywords_unique
SET to_be_used = 1
WHERE EXISTS (
	SELECT lemmatized_kw
    FROM keywords_unique_1500x
    WHERE keywords_unique.lemmatized_kw = keywords_unique_1500x.lemmatized_kw);
    
DROP TABLE IF EXISTS keywords_vybrane;
CREATE TABLE keywords_vybrane (
	id_keywords_vybrane INT(11) NOT NULL AUTO_INCREMENT,
    firm_id INT(11),
    lemmatized_kw VARCHAR(100),
    PRIMARY KEY (id_keywords_vybrane)
    )ENGINE=InnoDB AUTO_INCREMENT=204797 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
INSERT INTO keywords_vybrane (firm_id, lemmatized_kw)
SELECT f.firm_id, k.lemmatized_kw FROM firm_keywords f
JOIN keywords_unique k ON f.keyword = k.keyword
WHERE k.to_be_used = 1;

-- vyřazení duplicitních řádků
CREATE TABLE keywords_vybrane_temp 
LIKE keywords_vybrane;
 
INSERT INTO keywords_vybrane_temp (id_keywords_vybrane, firm_id, lemmatized_kw)
SELECT id_keywords_vybrane, firm_id, lemmatized_kw 
FROM keywords_vybrane 
GROUP BY firm_id, lemmatized_kw;
  
DROP TABLE keywords_vybrane;
 
ALTER TABLE keywords_vybrane_temp 
RENAME TO keywords_vybrane;
