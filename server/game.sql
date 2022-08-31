CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS game;

CREATE TABLE IF NOT EXISTS game (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    word VARCHAR(255) NOT NULL,
    hits VARCHAR(255) NOT NULL,
    misses VARCHAR(255) NOT NULL,
    ongoing BOOLEAN NOT NULL DEFAULT true,
    userWord VARCHAR(255) NOT NULL,
    last BOOLEAN NOT NULL DEFAULT false,
    won BOOLEAN NOT NULL DEFAULT false
);

INSERT INTO game (word, hits, misses, ongoing, userWord, last, won) VALUES ('test', '', '', true, '', false, false);

SELECT * FROM game;
