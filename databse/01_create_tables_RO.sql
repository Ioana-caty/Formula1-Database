CREATE TABLE CIRCUIT (
    circuit_id	NUMBER(4),
    nume		VARCHAR2(60)	NOT NULL,
    oras		VARCHAR2(60)	NOT NULL,
    tara		VARCHAR2(60)	NOT NULL,
    lungime_tur	DECIMAL(4,3)	NOT NULL,
    tip_circuit	VARCHAR2(25)	NOT NULL,
    CONSTRAINT pk_circuit PRIMARY KEY (circuit_id),
    CONSTRAINT u_circuit_nume UNIQUE (nume),
    CONSTRAINT ck_lungime_tur CHECK (lungime_tur > 0),
    CONSTRAINT ck_tip_circuit CHECK (tip_circuit IN ('permanent', 'stradal'))
);


CREATE TABLE ECHIPA (
    team_id	NUMBER(4),
    nume_oficial	VARCHAR2(60)   NOT NULL,
    director	VARCHAR2(60)   NOT NULL,
    locatie_sediu	VARCHAR2(30)   NOT NULL,
    buget_anual	DECIMAL(11,2)   NOT NULL,
    numar_campionate  NUMBER(2)       NOT NULL,
    CONSTRAINT pk_echipa PRIMARY KEY (team_id),
    CONSTRAINT u_nume_oficial UNIQUE (nume_oficial),
    CONSTRAINT ck_buget CHECK (buget_anual BETWEEN 0 AND 135000000),
    CONSTRAINT ck_campionate CHECK (numar_campionate >= 0)
);


CREATE TABLE SPONSOR (
    sponsor_id		NUMBER(4),
    nume_companie	VARCHAR2(30)    NOT NULL,
    industrie       		VARCHAR2(60)    NOT NULL,
    nume_contact    	VARCHAR2(60)    NOT NULL,
    mail_contact    	VARCHAR2(30)    NOT NULL,
    CONSTRAINT pk_sponsor PRIMARY KEY (sponsor_id),
    CONSTRAINT u_nume_companie UNIQUE (nume_companie),
    CONSTRAINT u_mail_contact UNIQUE (mail_contact),
    CONSTRAINT ck_mail_contact CHECK (mail_contact LIKE '%@%.%')
);



CREATE TABLE GRANDPRIX (
    grandprix_id		NUMBER(4),
    nume_cursa         	VARCHAR2(60)	NOT NULL,
    sezon              		NUMBER(4)       	NOT NULL,
    numar_cursa_sezon  	NUMBER(2)       	NOT NULL,
    circuit_id         	NUMBER(4)       	NOT NULL,
    CONSTRAINT pk_grandprix PRIMARY KEY (grandprix_id),
    CONSTRAINT fk_grandprix_circuit FOREIGN KEY (circuit_id) 
	REFERENCES CIRCUIT(circuit_id) ON DELETE CASCADE,
    CONSTRAINT u_circuit_sezon UNIQUE (circuit_id, sezon),
    CONSTRAINT ck_sezon CHECK (sezon >= 2000),
    CONSTRAINT ck_numar_cursa CHECK (numar_cursa_sezon BETWEEN 1 AND 24)
);

CREATE TABLE SESIUNE (
    sesiune_id		NUMBER(7),
    tip_sesiune       	VARCHAR2(60)	NOT NULL,
    data_ora_inceput  	DATE            	NOT NULL,
    numar_tururi      	NUMBER(3)       NOT NULL,
    conditii_meteo    	DECIMAL(4,2)    NOT NULL,
    grandprix_id      	NUMBER(4)       NOT NULL,
    CONSTRAINT pk_sesiune PRIMARY KEY (sesiune_id),
    CONSTRAINT fk_sesiune_grandprix FOREIGN KEY (grandprix_id)
	REFERENCES GRANDPRIX(grandprix_id) ON DELETE CASCADE,
    CONSTRAINT ck_tip_sesiune CHECK (tip_sesiune IN ('calificari', 'cursa')),
    CONSTRAINT ck_tururi CHECK (numar_tururi > 0),
    CONSTRAINT ck_meteo CHECK (conditii_meteo BETWEEN -15 AND 60)
);


CREATE TABLE MASINA (
    car_id            		NUMBER(4),
    model_an 		NUMBER(4)	NOT NULL,
    sasiu_serie       	NUMBER(4)	NOT NULL,
    producator_motor  	VARCHAR2(60)  NOT NULL,
    team_id           	NUMBER(4)      	NOT NULL,
    CONSTRAINT pk_masina PRIMARY KEY (car_id),
    CONSTRAINT fk_masina_echipa FOREIGN KEY (team_id)
	REFERENCES ECHIPA(team_id) ON DELETE CASCADE,
    CONSTRAINT u_sasiu UNIQUE (sasiu_serie),
    CONSTRAINT ck_motor CHECK (producator_motor IN ('Ferrari', 'Mercedes', 'Honda', 'Renault'))
);



CREATE TABLE PILOT (
    pilot_id      	NUMBER(4),
    numar        	NUMBER(2)       	  NOT NULL,
    nume          	VARCHAR2(60)    NOT NULL,
    prenume       	VARCHAR2(60)    NOT NULL,
    nationalitate 	VARCHAR2(30)    NOT NULL,
    data_nastere	DATE            	  NOT NULL,
    team_id       	NUMBER(4)         NOT NULL,
    CONSTRAINT pk_pilot PRIMARY KEY (pilot_id),
    CONSTRAINT fk_pilot_echipa FOREIGN KEY (team_id) 
	REFERENCES ECHIPA(team_id) ON DELETE CASCADE,
    CONSTRAINT u_numar UNIQUE (numar),
    CONSTRAINT u_pilot_identitate UNIQUE (nume, prenume, data_nastere),
    CONSTRAINT ck_numar CHECK (numar BETWEEN 1 AND 99 AND numar != 17)
);


CREATE TABLE CONTRACTE (
    team_id		NUMBER(4),
    sponsor_id      	NUMBER(4),
    data_inceput    	DATE           	NOT NULL,
    data_sfarsit    	DATE            	NOT NULL,
    valoare_anuala  	DECIMAL(11,2)	NOT NULL,
    tip_contract    	VARCHAR2(30)	NOT NULL,
    CONSTRAINT pk_contracte PRIMARY KEY (team_id, sponsor_id),
    CONSTRAINT fk_contracte_echipa FOREIGN KEY (team_id)
	REFERENCES ECHIPA(team_id) ON DELETE CASCADE,
    CONSTRAINT fk_contracte_sponsor FOREIGN KEY (sponsor_id) 
	REFERENCES SPONSOR(sponsor_id) ON DELETE CASCADE,
    CONSTRAINT ck_date_contract CHECK (data_sfarsit > data_inceput),
    CONSTRAINT ck_valoare CHECK (valoare_anuala BETWEEN 0 AND 135000000),
    CONSTRAINT ck_tip_contract CHECK (tip_contract IN ('principal', 'secundar', 'tehnic'))
);

CREATE TABLE REZULTATE (
    pilot_id       		NUMBER(4),
    grandprix_id   	NUMBER(4),
    pozitie_start  		NUMBER(2)       NOT NULL,
    pozitie_final  		NUMBER(2),
    status         		VARCHAR2(20),
    CONSTRAINT pk_rezultate PRIMARY KEY (pilot_id, grandprix_id),
    CONSTRAINT fk_rezultate_pilot FOREIGN KEY (pilot_id) 
	REFERENCES PILOT(pilot_id) ON DELETE CASCADE,
    CONSTRAINT fk_rezultate_grandprix FOREIGN KEY (grandprix_id)
	REFERENCES GRANDPRIX(grandprix_id) ON DELETE CASCADE,
    CONSTRAINT ck_poz_start CHECK (pozitie_start BETWEEN 1 AND 20),
    CONSTRAINT ck_poz_final CHECK (pozitie_final BETWEEN 1 AND 20),
    CONSTRAINT ck_status CHECK (
        (status = 'finalizat' AND pozitie_final IS NOT NULL) OR
        (status = 'abandon' AND pozitie_final IS NULL)
    ) 
);
