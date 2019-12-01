/*
SELECT * from firm_keywords
where keyword REGEXP '[^[:alnum:]]+';
*/

-- přidání sloupečků na označení vyhozených slov
ALTER TABLE `projektda`.`firm_keywords` 
ADD COLUMN `paznaky` TINYINT NULL DEFAULT 0 AFTER `kw_status`,
ADD COLUMN `cislice` TINYINT NULL DEFAULT 0 AFTER `paznaky`,
ADD COLUMN `cizi_abecedy` TINYINT NULL DEFAULT 0 AFTER `cislice`,
ADD COLUMN `dlouhe` TINYINT NULL DEFAULT 0 AFTER `cizi_abecedy`,
ADD COLUMN `kratke` TINYINT NULL DEFAULT 0 AFTER `dlouhe`,
ADD COLUMN `neceske_znaky` TINYINT NULL DEFAULT 0 AFTER `kratke`,
CHANGE COLUMN `kw_status` `kw_status` TINYINT GENERATED ALWAYS AS (paznaky+cislice+cizi_abecedy+dlouhe+kratke+neceske_znaky) STORED ;

-- vytvoření záložní tabulky s původními daty
DROP TABLE IF EXISTS firm_keywords_puvodni;
CREATE TABLE firm_keywords_puvodni 
LIKE firm_keywords;
INSERT INTO firm_keywords_puvodni (id, firm_id, keyword, paznaky, cislice, cizi_abecedy, dlouhe, kratke, neceske_znaky)
SELECT id, firm_id, keyword, paznaky, cislice, cizi_abecedy, dlouhe, kratke, neceske_znaky
FROM firm_keywords;


-- vyřazení duplicitních řádků přes pomocnou tabulku
CREATE TABLE firm_keywords_temp 
LIKE firm_keywords;
 
INSERT INTO firm_keywords_temp (id, firm_id, keyword, paznaky, cislice, cizi_abecedy, dlouhe, kratke, neceske_znaky)
SELECT id, firm_id, keyword, paznaky, cislice, cizi_abecedy, dlouhe, kratke, neceske_znaky 
FROM firm_keywords 
GROUP BY firm_id, keyword;
  
DROP TABLE firm_keywords;
 
ALTER TABLE firm_keywords_temp 
RENAME TO firm_keywords;


-- oprava nejčastějších (alespoň 200 výskytů) slov se špatně zakódovanou diakritikou
UPDATE firm_keywords SET keyword = 'ubytování' WHERE keyword = 'ubytovďż˝nďż˝';
UPDATE firm_keywords SET keyword = 'práce' WHERE keyword = 'prďż˝ce';
UPDATE firm_keywords SET keyword = 'výroba' WHERE keyword = 'vďż˝roba';
UPDATE firm_keywords SET keyword = 'doména' WHERE keyword = 'domďż˝na';
UPDATE firm_keywords SET keyword = 'domény' WHERE keyword = 'domďż˝ny';
UPDATE firm_keywords SET keyword = 'služby' WHERE keyword = 'sluďż˝by';
UPDATE firm_keywords SET keyword = 'stavební' WHERE keyword = 'stavebnďż˝';
UPDATE firm_keywords SET keyword = 'stránky' WHERE keyword = 'strďż˝nky';
UPDATE firm_keywords SET keyword = 'nábytek' WHERE keyword = 'nďż˝bytek';
UPDATE firm_keywords SET keyword = 'poradenství' WHERE keyword = 'poradenstvďż˝';
UPDATE firm_keywords SET keyword = 'dětský' WHERE keyword = 'dďż˝tskďż˝˝';
UPDATE firm_keywords SET keyword = 'ubytování' WHERE keyword = 'ubytov�n�';
UPDATE firm_keywords SET keyword = 'škola' WHERE keyword = 'ďż˝kola';
UPDATE firm_keywords SET keyword = 'systémy' WHERE keyword = 'systďż˝my';
UPDATE firm_keywords SET keyword = 'pronájem' WHERE keyword = 'pronďż˝jem';
UPDATE firm_keywords SET keyword = 'dovolená' WHERE keyword = 'dovolenďż˝';
UPDATE firm_keywords SET keyword = 'montáž' WHERE keyword = 'montďż˝';
UPDATE firm_keywords SET keyword = 'kancelář' WHERE keyword = 'kancelďż˝ďż˝';
UPDATE firm_keywords SET keyword = 'doplňky' WHERE keyword = 'doplďż˝ky';
UPDATE firm_keywords SET keyword = 'kancelář' WHERE keyword = 'kancelďż˝ďż˝';
UPDATE firm_keywords SET keyword = 'dveře' WHERE keyword = 'dveďż˝e';
UPDATE firm_keywords SET keyword = 'kuchyně' WHERE keyword = 'kuchynďż˝';
UPDATE firm_keywords SET keyword = 'firemní' WHERE keyword = 'firemnďż˝';
UPDATE firm_keywords SET keyword = 'výrobky' WHERE keyword = 'vďż˝robky˝';
UPDATE firm_keywords SET keyword = 'rodinný' WHERE keyword = 'rodinnďż˝';



-- Označení slov zapsaných cizí abecedou (azbuka, asijské abecedy) 
UPDATE firm_keywords
SET cizi_abecedy = 1
WHERE keyword REGEXP '[Α-Ωα-ωА-Яа-я]' -- azbuka a řecká abeceda
OR keyword REGEXP '[\\u4e00-\\u9fff]+' -- čínština a část japonštiny
OR keyword REGEXP '[\\uac00-\\ud7a3]+' -- korejština
OR keyword REGEXP '[\\u3040-\\u30ff]+' -- zbylá japonská písma
OR keyword REGEXP '[\\u0600-\\u06ff]+' -- arabština
OR keyword REGEXP '[\\u0590-\\u05ff]+' -- hebrejština
OR keyword REGEXP '[\\u0e00-\\u0e7f]+'; -- thajština

-- Označení slov začínajících číslicí
/*
UPDATE firm_keywords
SET kw_status = "ciselne"
WHERE LEFT(keyword, 1) IN ('0','1','2','3','4','5','6','7','8','9');
*/

UPDATE firm_keywords
SET cislice = 1
WHERE keyword REGEXP '.*[:digit:]+.*';

-- Označení slov jinými znaky než českou abecedou
UPDATE firm_keywords
SET paznaky = 1
WHERE keyword REGEXP '[^a-zA-ZáéěíýóúůžščřďťňÁÉĚÍÝÓÚŮŽŠČŘĎŤŇ]+';

-- Označení slov se špatně zakódovanou diakritikou
UPDATE firm_keywords
SET neceske_znaky = 1
WHERE keyword REGEXP '[^[:alnum:]]+';

-- Označení slov delších než stanovený počet znaků
UPDATE projektda.firm_keywords
SET dlouhe = 1
WHERE length(keyword) > 20;

-- označení stop slov na základě délky
UPDATE firm_keywords
SET kratke = 1
WHERE length(keyword) < 4 AND keyword NOT IN ("byt", "web", "cd", "dvd", "gps", "php", "hry", "hra", "seo", "byt", "led", "cnc", "mš", "zš", "sš", "vš", "voš", "bar", "bio", "art", "dtp", "sex", "gsm", "gps", "bmw", "cad", "spa", "mp3", "ssd", "ftp", "dvb", "eko", "bus", "cng", "rtg", "lpg", "pes", "psy", "psi");
