DROP TABLE IF EXISTS "Skills";
DROP TABLE IF EXISTS "Characters";

CREATE TABLE "Characters" (
	"ID" integer PRIMARY KEY,
	"firstName" text NOT NULL CHECK (LENGTH("firstName") > 0),
	"lastName" text,
	"fullName" text AS (trim(concat("firstName", ' ', "lastName"))) STORED,
	"gender" text NOT NULL DEFAULT 'Human' CHECK ("gender" IN ('Balrog', 'DarkLord', 'Dwarf', 'Elf', 'Hobbit', 'Human', 'Istari'))
);

CREATE TABLE "Skills" (
	"ID" integer PRIMARY KEY,
	"characterID" integer REFERENCES "Characters" ("ID") ON UPDATE CASCADE ON DELETE CASCADE,
	"name" text NOT NULL CHECK (LENGTH("name") > 0),
	"score" integer NOT NULL CHECK ("score" > 0)
);

INSERT INTO "Characters" ("firstName", "lastName", "gender") VALUES
	('Aragorn', NULL, 'Human'),
	('Balin', NULL, 'Dwarf'),
	('Boromir', NULL, 'Human'),
	('Durin''s Bane', NULL, 'Balrog'),
	('Elrond', NULL, 'Elf'),
	('Frodo', 'Baggins', 'Hobbit'),
	('Galadriel', NULL, 'Elf'),
	('Gandalf', NULL, 'Istari'),
	('Gimli', NULL, 'Dwarf'),
	('Gollum', NULL, 'Hobbit'),
	('Gothmog', NULL, 'Balrog'),
	('Legolas', NULL, 'Elf'),
	('Pippin', 'Took', 'Hobbit'),
	('Sam', 'Gamgee', 'Hobbit'),
	('Saruman', NULL, 'Istari'),
	('Sauron', NULL, 'DarkLord');

INSERT INTO "Skills" ("characterID", "name", "score") VALUES
	(1, "Sword", 90),
	(2, "Hammer", 80),
	(3, "Sword", 75),
	(5, "Bow", 80),
	(6, "Invisibility", 100),
	(7, "Beauty", 95),
	(8, "Magic", 80),
	(12, "Bow", 95),
	(15, "Magic", 85),
	(16, "Magic", 95);
