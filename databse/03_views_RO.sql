-- Clasamentul Constructorilor în funcție de sezon. Poziția finală oferă un 
-- punctaj specific. (Suma punctajelor tuturor piloților înregistrați sub aceeași
--entitate (Echipa) pe parcursul unui sezon)
SELECT e.nume_oficial AS echipa,
       	e.director,
       	g.sezon,
     		SUM(
          		CASE r.pozitie_final
               		WHEN 1 THEN 25
               		WHEN 2 THEN 18
              			WHEN 3 THEN 15
               		WHEN 4 THEN 12
               		WHEN 5 THEN 10
               		WHEN 6 THEN 8
               		WHEN 7 THEN 6
               		WHEN 8 THEN 4
               		WHEN 9 THEN 2
               		WHEN 10 THEN 1
               		ELSE 0
           		END
       	      ) AS total_puncte
FROM ECHIPA e
JOIN PILOT p ON e.team_id = p.team_id
JOIN REZULTATE r ON p.pilot_id = r.pilot_id
JOIN GRANDPRIX g ON r.grandprix_id = g.grandprix_id
WHERE r.status = 'finalizat'
		AND g.sezon = :P22_SEZON
GROUP BY e.team_id, e.nume_oficial, e.director, g.sezon
ORDER BY total_puncte DESC;

-- Să se afișeze piloții care au finalizat cel puțin X curse și au terminat pe 
-- podium în fiecare dintre ele.
SELECT
    p.nume || ' ' || p.prenume AS "Pilot",
    COUNT(r.grandprix_id) AS "Total Curse",
    MIN(r.pozitie_final) AS "Cea mai bună clasare",
    MAX(r.pozitie_final) AS "Cea mai slabă clasare"
FROM PILOT p
JOIN REZULTATE r ON p.pilot_id = r.pilot_id
WHERE r.status = 'finalizat'
GROUP BY p.pilot_id, p.nume, p.prenume
HAVING COUNT(r.grandprix_id) >= :P24_STATISTICI
   AND MAX(r.pozitie_final) <= 3
ORDER BY "Total Curse" DESC;

-- Să se proiecteze o vizualizare complexă numită “VIZ_REZULTATE_PILOTI” care să
-- afișeze pentru fiecare pilot și fiecare cursă de Grand Prix, următoarele 
-- informații: identificatorul pilotului, identificatorul cursei, numărul și 
-- numele complet al pilotului, statusul rezultatului, poziția de start și 
-- poziția finală, precum și denumirea cursei.
create or replace view VIZ_REZULTATE_PILOTI AS
select 
    pilot_id, grandprix_id, p.numar, p.nume || ' ' || p.prenume AS nume,
    r.status, r.pozitie_start, r.pozitie_final,
    g.nume_cursa
from pilot p
join rezultate r using(pilot_id) 
join grandprix g using(grandprix_id);

-- Să se proiecteze o vizualizare complexă numită “v_clasament_piloti” care să 
-- genereze o statistică cu performanțele piloților, pe parcursul sezoanelor. 
-- Pentru fiecare pilot, vizualizarea va returna: numele complet, echipa din 
-- care face parte și sezonul. Se vor calcula, prin funcții de agregare, numărul
-- de curse finalizate, numărul de victorii, numărul de podiumuri și punctajul 
-- total acumulat (conform grilei oficiale FIA: 25-18-15-12-10-8-6-4-2-1). 
-- Datele vor fi grupate la nivel de pilot și sezon, incluzând doar piloții care
-- au înregistrat cel puțin o participare.
create or replace view v_clasament_piloti as
select 
    p.nume || ' ' || p.prenume as pilot,
    e.nume_oficial as echipa,
    g.sezon,
    count(r.grandprix_id) as curse_finalizate,
    sum(case when r.pozitie_final = 1 then 1 else 0 end) as victorii,
    sum(case when r.pozitie_final <= 3 then 1 else 0 end) as podiumuri,
    sum(
        case r.pozitie_final
            when 1 then 25
            when 2 then 18
            when 3 then 15
            when 4 then 12
            when 5 then 10
            when 6 then 8
            when 7 then 6
            when 8 then 4
            when 9 then 2
            when 10 then 1
            else 0
        end
    ) as total_puncte
from pilot p
join echipa e on p.team_id = e.team_id
join rezultate r on p.pilot_id = r.pilot_id
join grandprix g on r.grandprix_id = g.grandprix_id
where r.status = 'finalizat' and r.pozitie_final is not null
group by p.pilot_id, p.nume, p.prenume, e.nume_oficial, g.sezon
order by g.sezon desc, total_puncte desc;



