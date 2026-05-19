DROP TABLE IF EXISTS "Characters";

CREATE TABLE "Characters" (
	"ID" integer PRIMARY KEY,
	"firstName" text NOT NULL CHECK (LENGTH("firstName") > 0),
	"lastName" text,
	"fullName" text AS (trim(concat("firstName", ' ', "lastName"))) STORED,
	"gender" text NOT NULL DEFAULT 'Human' CHECK ("gender" IN ('Balrog', 'DarkLord', 'Dwarf', 'Elf', 'Hobbit', 'Human', 'Istari'))
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
