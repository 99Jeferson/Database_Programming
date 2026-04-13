-- ╔══════════════════════════════════════════════════════════════════╗
-- ║   AGRICULTURAL SERVICES DATABASE                                ║
-- ║   Ministry of Agriculture · Animal Industry · Uganda (NUCAFE)  ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║   MILESTONE FOUR: Security & Automation                         ║
-- ║   User Privileges · Roles · Stored Procedures                   ║
-- ║   Triggers · Backup & Recovery                                  ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║   Tool      : MySQL 8.0 + VS Code                               ║
-- ║   Student   : [Your Name]                                       ║
-- ║   Reg No    : [Your Registration Number]                        ║
-- ║   Course    : Database Systems                                  ║
-- ║   University: Uganda Christian University, Mukono               ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║   PRE-REQUISITE: Run M3_Database_Development.sql first.         ║
-- ║   This file assumes agri_services_db already exists.            ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║   HOW TO RUN INDIVIDUAL QUERIES                                 ║
-- ║   VS Code  : Highlight query → Ctrl+Enter                       ║
-- ║   Workbench: Highlight query → Ctrl+Shift+Enter                 ║
-- ║   CLI      : mysql -u root -p < M4_Security_Automation.sql      ║
-- ╚══════════════════════════════════════════════════════════════════╝
--
-- ┌─────────────────────────────────────────────────────────────────┐
-- │ CONTENTS                                                        │
-- │  SECTION 1  ─ User accounts & passwords      (run standalone)  │
-- │  SECTION 2  ─ Privilege grants per role       (run standalone)  │
-- │  SECTION 3  ─ Security views                 (run standalone)  │
-- │  SECTION 4  ─ Automation triggers             (run standalone)  │
-- │  SECTION 5  ─ Additional stored procedures   (run standalone)  │
-- │  SECTION 6  ─ Audit log & audit triggers      (run standalone)  │
-- │  SECTION 7  ─ Backup & recovery strategy     (run standalone)  │
-- │  SECTION 8  ─ Security & automation tests    (run standalone)  │
-- └─────────────────────────────────────────────────────────────────┘

USE agri_services_db;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 1: USER ACCOUNTS
--
-- Three users reflecting the Ministry's operational structure:
--
--  agri_admin    Full administrative control.
--                Assigned to: IT department, database administrator.
--
--  agri_officer  Data entry and field operations.
--                Can register farmers, log advisory sessions,
--                record distributions. Cannot see national_id or
--                delete any records.
--                Assigned to: Extension officers, district coordinators.
--
--  agri_readonly Read-only access to reporting views only.
--                Cannot access raw tables or personal data.
--                Assigned to: Ministry auditors, UCDA, researchers.
-- ══════════════════════════════════════════════════════════════════

-- Safe to re-run — drops users if they already exist
DROP USER IF EXISTS 'agri_admin'@'localhost';
DROP USER IF EXISTS 'agri_officer'@'localhost';
DROP USER IF EXISTS 'agri_readonly'@'localhost';


-- ── Create agri_admin ─────────────────────────────────────────────
CREATE USER 'agri_admin'@'localhost'
    IDENTIFIED BY 'Admin@Agri2024!'
    PASSWORD EXPIRE INTERVAL 90 DAY
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1;

-- ── Create agri_officer ───────────────────────────────────────────
CREATE USER 'agri_officer'@'localhost'
    IDENTIFIED BY 'Officer@Agri2024!'
    PASSWORD EXPIRE INTERVAL 90 DAY
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1;

-- ── Create agri_readonly ──────────────────────────────────────────
CREATE USER 'agri_readonly'@'localhost'
    IDENTIFIED BY 'ReadOnly@Agri2024!'
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 2: PRIVILEGE GRANTS
-- Run each block individually to grant by role.
-- ══════════════════════════════════════════════════════════════════

-- ── Admin: full control ───────────────────────────────────────────
GRANT ALL PRIVILEGES
    ON agri_services_db.*
    TO 'agri_admin'@'localhost'
    WITH GRANT OPTION;


-- ── Officer: read non-sensitive tables ───────────────────────────
GRANT SELECT ON agri_services_db.cooperative            TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.training_programme     TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.coffee_variety         TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.supplier               TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.resource               TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.seedling               TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.input                  TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.farm                   TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.farm_variety           TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.production_record      TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.interaction            TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.advisory_session       TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.distribution_event     TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.complaint_feedback     TO 'agri_officer'@'localhost';

-- ── Officer: insert and update operational records ────────────────
GRANT INSERT, UPDATE ON agri_services_db.farm               TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.farm_variety        TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.production_record   TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.interaction         TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.advisory_session    TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.distribution_event  TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.complaint_feedback  TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.programme_enrolment TO 'agri_officer'@'localhost';
GRANT INSERT, UPDATE ON agri_services_db.coop_membership     TO 'agri_officer'@'localhost';

-- ── Officer: execute stored procedures and functions ──────────────
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_register_farmer         TO 'agri_officer'@'localhost';
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_distribute_resource     TO 'agri_officer'@'localhost';
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_log_advisory            TO 'agri_officer'@'localhost';
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_resolve_complaint       TO 'agri_officer'@'localhost';
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_register_extension_worker TO 'agri_officer'@'localhost';
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_register_farm           TO 'agri_officer'@'localhost';
GRANT EXECUTE ON PROCEDURE agri_services_db.sp_record_production       TO 'agri_officer'@'localhost';
GRANT EXECUTE ON FUNCTION  agri_services_db.fn_farmer_type             TO 'agri_officer'@'localhost';
GRANT EXECUTE ON FUNCTION  agri_services_db.fn_total_yield             TO 'agri_officer'@'localhost';
GRANT EXECUTE ON FUNCTION  agri_services_db.fn_stock_status            TO 'agri_officer'@'localhost';
GRANT EXECUTE ON FUNCTION  agri_services_db.fn_days_since_visit        TO 'agri_officer'@'localhost';


-- ── Read-only: reporting views and aggregate functions only ───────
GRANT SELECT ON agri_services_db.vw_farmer_summary      TO 'agri_readonly'@'localhost';
GRANT SELECT ON agri_services_db.vw_resource_value      TO 'agri_readonly'@'localhost';
GRANT SELECT ON agri_services_db.vw_cooperative_summary TO 'agri_readonly'@'localhost';
GRANT SELECT ON agri_services_db.vw_production_revenue  TO 'agri_readonly'@'localhost';
GRANT SELECT ON agri_services_db.vw_interaction_log     TO 'agri_readonly'@'localhost';
GRANT SELECT ON agri_services_db.vw_worker_profile      TO 'agri_readonly'@'localhost';
GRANT EXECUTE ON FUNCTION agri_services_db.fn_stock_status      TO 'agri_readonly'@'localhost';
GRANT EXECUTE ON FUNCTION agri_services_db.fn_revenue_estimate  TO 'agri_readonly'@'localhost';

FLUSH PRIVILEGES;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 3: SECURITY VIEWS
--
-- These views restrict column-level access so officers and
-- read-only users never see raw national_id values or sensitive
-- cost/supplier data.  Each view is followed by its GRANT.
-- Run each CREATE VIEW block individually.
-- ══════════════════════════════════════════════════════════════════

-- ── Security View 1: Farmer list without national_id ─────────────
-- Officers see full names and contacts but never the NIN.
CREATE OR REPLACE VIEW vw_secure_farmer AS
SELECT
    f.farmer_id,
    p.full_name,
    p.phone_number,
    p.district,
    p.village_lc1,
    p.gender,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    f.registration_date,
    f.cooperative_member,
    fn_farmer_type(f.farmer_id)                     AS farmer_category,
    COUNT(fm.farm_id)                               AS total_farms,
    COALESCE(SUM(fm.land_size_acres), 0)            AS total_acres
FROM farmer f
JOIN  person p  ON p.national_id  = f.national_id
LEFT JOIN farm fm ON fm.farmer_id = f.farmer_id
GROUP BY f.farmer_id, p.full_name, p.phone_number,
         p.district, p.village_lc1, p.gender,
         p.date_of_birth, f.registration_date,
         f.cooperative_member;

GRANT SELECT ON agri_services_db.vw_secure_farmer TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.vw_secure_farmer TO 'agri_readonly'@'localhost';


-- ── Security View 2: Worker list without national_id ─────────────
CREATE OR REPLACE VIEW vw_secure_worker AS
SELECT
    ew.staff_id,
    p.full_name,
    p.phone_number,
    p.district,
    ew.qualification,
    ew.expertise_area,
    ew.assigned_region,
    ew.hire_date,
    TIMESTAMPDIFF(YEAR, ew.hire_date, CURDATE()) AS years_of_service,
    CASE
        WHEN fo.fo_id IS NOT NULL THEN 'Field Officer'
        WHEN tr.tr_id IS NOT NULL THEN 'Trainer'
        ELSE 'Unclassified'
    END                                          AS worker_role,
    fn_days_since_visit(ew.staff_id)             AS days_since_last_visit
FROM extension_worker ew
JOIN  person        p  ON p.national_id  = ew.national_id
LEFT JOIN field_officer fo ON fo.staff_id = ew.staff_id
LEFT JOIN trainer       tr ON tr.staff_id = ew.staff_id;

GRANT SELECT ON agri_services_db.vw_secure_worker TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.vw_secure_worker TO 'agri_readonly'@'localhost';


-- ── Security View 3: Farm detail without farmer NIN ──────────────
CREATE OR REPLACE VIEW vw_secure_farm AS
SELECT
    fm.farm_id,
    p.full_name                   AS farmer_name,
    p.phone_number                AS farmer_contact,
    fm.district,
    fm.village,
    fm.land_size_acres,
    fm.soil_type,
    fm.water_source,
    fm.altitude_m,
    fm.gps_latitude,
    fm.gps_longitude,
    fm.registration_date,
    fn_farmer_type(fm.farmer_id)  AS farmer_category,
    fn_total_yield(fm.farm_id)    AS total_yield_kg,
    CASE
        WHEN rf.rf_id IS NOT NULL AND af.af_id IS NOT NULL THEN 'Mixed'
        WHEN rf.rf_id IS NOT NULL                          THEN 'Robusta'
        WHEN af.af_id IS NOT NULL                          THEN 'Arabica'
        ELSE 'Unclassified'
    END                           AS farm_variety_type
FROM farm fm
JOIN  farmer f  ON f.farmer_id   = fm.farmer_id
JOIN  person p  ON p.national_id = f.national_id
LEFT JOIN robusta_farm rf ON rf.farm_id = fm.farm_id
LEFT JOIN arabica_farm af ON af.farm_id = fm.farm_id;

GRANT SELECT ON agri_services_db.vw_secure_farm TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.vw_secure_farm TO 'agri_readonly'@'localhost';


-- ── Security View 4: Resource stock without unit cost ────────────
-- Officers see what is available but not what it cost.
CREATE OR REPLACE VIEW vw_secure_stock AS
SELECT
    r.resource_id,
    r.batch_no,
    r.date_received,
    r.quantity_available,
    fn_stock_status(r.quantity_available) AS stock_status,
    s.supplier_name,
    s.location                            AS supplier_location,
    CASE
        WHEN se.seedling_id IS NOT NULL THEN
            CONCAT('Seedling — ', se.variety_label,
                   ' | Germination: ', se.germination_rate, '%')
        WHEN ip.input_id IS NOT NULL THEN
            CONCAT('Input — ', ip.input_type)
        ELSE 'Unclassified'
    END                                   AS resource_description
FROM resource r
JOIN  supplier s  ON s.supplier_id  = r.supplier_id
LEFT JOIN seedling se ON se.resource_id = r.resource_id
LEFT JOIN input    ip ON ip.resource_id = r.resource_id;

GRANT SELECT ON agri_services_db.vw_secure_stock TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.vw_secure_stock TO 'agri_readonly'@'localhost';


-- ── Security View 5: Ministry-level dashboard summary ────────────
-- High-level aggregate numbers. No personal data at all.
CREATE OR REPLACE VIEW vw_ministry_dashboard AS
SELECT
    (SELECT COUNT(*) FROM farmer)                               AS total_farmers,
    (SELECT COUNT(*) FROM farm)                                AS total_farms,
    (SELECT COUNT(*) FROM smallholder_farmer)                  AS smallholder_count,
    (SELECT COUNT(*) FROM commercial_farmer)                   AS commercial_count,
    (SELECT COUNT(*) FROM extension_worker)                    AS total_workers,
    (SELECT COUNT(*) FROM interaction
     WHERE activity_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY))
                                                               AS interactions_last_30_days,
    (SELECT COALESCE(SUM(yield_kg),0)
     FROM production_record
     WHERE year = YEAR(CURDATE()))                             AS total_yield_current_year_kg,
    (SELECT COUNT(*) FROM complaint_feedback
     WHERE resolution_status = 'Open')                        AS open_complaints,
    (SELECT COALESCE(SUM(quantity_available),0) FROM resource) AS total_stock_units;

GRANT SELECT ON agri_services_db.vw_ministry_dashboard TO 'agri_admin'@'localhost';
GRANT SELECT ON agri_services_db.vw_ministry_dashboard TO 'agri_officer'@'localhost';
GRANT SELECT ON agri_services_db.vw_ministry_dashboard TO 'agri_readonly'@'localhost';


-- ══════════════════════════════════════════════════════════════════
-- SECTION 4: AUTOMATION TRIGGERS
-- Each trigger automates a business rule that would otherwise
-- need application-level code or manual updates.
-- Run each DELIMITER block individually.
-- ══════════════════════════════════════════════════════════════════

DELIMITER $$

-- ── Trigger 1: Auto-deduct stock after a distribution ────────────
-- After any distribution_event INSERT, reduces the
-- corresponding resource's quantity_available automatically.
CREATE TRIGGER trg_auto_deduct_stock
AFTER INSERT ON distribution_event
FOR EACH ROW
BEGIN
    UPDATE resource
       SET quantity_available = quantity_available - NEW.quantity_given
     WHERE resource_id = NEW.resource_id;
END$$


-- ── Trigger 2: Prevent overdistribution ──────────────────────────
-- Before any distribution_event INSERT, checks that the
-- requested quantity does not exceed what is in stock.
CREATE TRIGGER trg_prevent_overstock
BEFORE INSERT ON distribution_event
FOR EACH ROW
BEGIN
    DECLARE v_available INT UNSIGNED;
    SELECT quantity_available INTO v_available
      FROM resource WHERE resource_id = NEW.resource_id;
    IF v_available < NEW.quantity_given THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Stock validation: quantity_given exceeds quantity_available';
    END IF;
END$$


-- ── Trigger 3: Auto-mark interaction as Completed ─────────────────
-- After an advisory_session is inserted, auto-sets the
-- parent interaction status to Completed.
CREATE TRIGGER trg_complete_interaction_advisory
AFTER INSERT ON advisory_session
FOR EACH ROW
BEGIN
    UPDATE interaction
       SET activity_status = 'Completed'
     WHERE activity_id = NEW.activity_id;
END$$

-- After a distribution_event is inserted, does the same.
CREATE TRIGGER trg_complete_interaction_distribution
AFTER INSERT ON distribution_event
FOR EACH ROW
BEGIN
    UPDATE interaction
       SET activity_status = 'Completed'
     WHERE activity_id = NEW.activity_id;
END$$


-- ── Trigger 4: Auto-set complaint resolved_date ───────────────────
-- When a complaint status changes to Resolved or Dismissed,
-- automatically sets resolved_date to today.
CREATE TRIGGER trg_auto_resolve_date
BEFORE UPDATE ON complaint_feedback
FOR EACH ROW
BEGIN
    IF NEW.resolution_status IN ('Resolved','Dismissed')
       AND OLD.resolution_status NOT IN ('Resolved','Dismissed') THEN
        SET NEW.resolved_date = CURDATE();
    END IF;
END$$


-- ── Trigger 5: Validate training programme capacity ───────────────
-- Before a programme_enrolment INSERT, checks that the
-- programme has not already reached max_participants.
CREATE TRIGGER trg_check_enrolment_capacity
BEFORE INSERT ON programme_enrolment
FOR EACH ROW
BEGIN
    DECLARE v_max     INT UNSIGNED;
    DECLARE v_current INT UNSIGNED;
    SELECT max_participants INTO v_max
      FROM training_programme WHERE programme_id = NEW.programme_id;
    SELECT COUNT(*) INTO v_current
      FROM programme_enrolment WHERE programme_id = NEW.programme_id;
    IF v_current >= v_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Enrolment failed: training programme is at full capacity';
    END IF;
END$$


-- ── Trigger 6: Auto-set cooperative_member flag ───────────────────
-- When a farmer joins a cooperative, automatically updates
-- their cooperative_member flag in the farmer table.
CREATE TRIGGER trg_set_coop_member_flag
AFTER INSERT ON coop_membership
FOR EACH ROW
BEGIN
    UPDATE farmer SET cooperative_member = 1
     WHERE farmer_id = NEW.farmer_id;
END$$


-- ── Trigger 7: Auto-clear cooperative_member flag ─────────────────
-- When a farmer's last membership is withdrawn,
-- resets the cooperative_member flag to 0.
CREATE TRIGGER trg_clear_coop_member_flag
AFTER UPDATE ON coop_membership
FOR EACH ROW
BEGIN
    DECLARE v_active INT DEFAULT 0;
    IF NEW.membership_status = 'Withdrawn' THEN
        SELECT COUNT(*) INTO v_active
          FROM coop_membership
         WHERE farmer_id        = NEW.farmer_id
           AND membership_status = 'Active';
        IF v_active = 0 THEN
            UPDATE farmer SET cooperative_member = 0
             WHERE farmer_id = NEW.farmer_id;
        END IF;
    END IF;
END$$


-- ── Trigger 8: Block future harvest dates ─────────────────────────
CREATE TRIGGER trg_block_future_harvest
BEFORE INSERT ON production_record
FOR EACH ROW
BEGIN
    IF NEW.harvest_date IS NOT NULL
       AND NEW.harvest_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Validation: harvest_date cannot be a future date';
    END IF;
END$$

DELIMITER ;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 5: ADDITIONAL STORED PROCEDURES
-- These extend the automation layer with new operations.
-- Run each DELIMITER block individually.
-- ══════════════════════════════════════════════════════════════════

DELIMITER $$

-- ── Procedure 5: Register an extension worker (atomic) ───────────
CREATE PROCEDURE sp_register_extension_worker(
    IN p_national_id   VARCHAR(20),
    IN p_full_name     VARCHAR(100),
    IN p_dob           DATE,
    IN p_gender        VARCHAR(10),
    IN p_phone         VARCHAR(15),
    IN p_email         VARCHAR(100),
    IN p_district      VARCHAR(60),
    IN p_village       VARCHAR(80),
    IN p_qualification VARCHAR(100),
    IN p_expertise     VARCHAR(100),
    IN p_region        VARCHAR(80),
    IN p_hire_date     DATE,
    IN p_role          ENUM('FieldOfficer','Trainer','None'),
    IN p_specialisation VARCHAR(100)
)
BEGIN
    DECLARE v_staff_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    INSERT INTO person(national_id, full_name, date_of_birth, gender,
                       phone_number, email, district, village_lc1)
    VALUES (p_national_id, p_full_name, p_dob, p_gender,
            p_phone, p_email, p_district, p_village);

    INSERT INTO extension_worker(national_id, qualification,
                                 expertise_area, assigned_region, hire_date)
    VALUES (p_national_id, p_qualification, p_expertise, p_region, p_hire_date);
    SET v_staff_id = LAST_INSERT_ID();

    IF p_role = 'FieldOfficer' THEN
        INSERT INTO field_officer(staff_id, farms_assigned)
        VALUES (v_staff_id, 0);
    ELSEIF p_role = 'Trainer' THEN
        INSERT INTO trainer(staff_id, specialisation, sessions_conducted)
        VALUES (v_staff_id, IFNULL(p_specialisation,'General Agriculture'), 0);
    END IF;

    COMMIT;
    SELECT CONCAT('Extension worker registered. staff_id = ', v_staff_id) AS result;
END$$


-- ── Procedure 6: Register a farm with variety classification ──────
CREATE PROCEDURE sp_register_farm(
    IN p_farmer_id    INT UNSIGNED,
    IN p_lat          DECIMAL(10,7),
    IN p_lon          DECIMAL(10,7),
    IN p_size_acres   DECIMAL(8,2),
    IN p_soil         VARCHAR(60),
    IN p_water        VARCHAR(80),
    IN p_altitude     INT,
    IN p_district     VARCHAR(60),
    IN p_village      VARCHAR(80),
    IN p_variety_type ENUM('Robusta','Arabica','Mixed'),
    IN p_robusta_pct  DECIMAL(5,2),
    IN p_arabica_pct  DECIMAL(5,2)
)
BEGIN
    DECLARE v_farm_id INT UNSIGNED;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    INSERT INTO farm(farmer_id, gps_latitude, gps_longitude,
                     land_size_acres, soil_type, water_source,
                     altitude_m, district, village, registration_date)
    VALUES (p_farmer_id, p_lat, p_lon, p_size_acres, p_soil, p_water,
            p_altitude, p_district, p_village, CURDATE());
    SET v_farm_id = LAST_INSERT_ID();

    IF p_variety_type = 'Robusta' THEN
        INSERT INTO robusta_farm(farm_id) VALUES (v_farm_id);
    ELSEIF p_variety_type = 'Arabica' THEN
        INSERT INTO arabica_farm(farm_id) VALUES (v_farm_id);
    ELSEIF p_variety_type = 'Mixed' THEN
        IF p_robusta_pct + p_arabica_pct <> 100 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mixed farm percentages must sum to 100';
        END IF;
        INSERT INTO robusta_farm(farm_id) VALUES (v_farm_id);
        INSERT INTO arabica_farm(farm_id) VALUES (v_farm_id);
        INSERT INTO mixed_farm(farm_id, robusta_pct, arabica_pct)
        VALUES (v_farm_id, p_robusta_pct, p_arabica_pct);
    END IF;

    COMMIT;
    SELECT CONCAT('Farm registered. farm_id = ', v_farm_id) AS result;
END$$


-- ── Procedure 7: Record seasonal production ───────────────────────
CREATE PROCEDURE sp_record_production(
    IN p_farm_id      INT UNSIGNED,
    IN p_season       ENUM('Long','Short'),
    IN p_year         YEAR,
    IN p_harvest_date DATE,
    IN p_yield_kg     DECIMAL(10,2),
    IN p_quality      ENUM('A','B','C','Ungraded'),
    IN p_pest_issues  TEXT
)
BEGIN
    IF EXISTS (SELECT 1 FROM production_record
               WHERE farm_id = p_farm_id
                 AND season  = p_season
                 AND year    = p_year) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Production record already exists for this farm/season/year';
    END IF;

    INSERT INTO production_record(farm_id, season, year, harvest_date,
                                   yield_kg, quality_grade, pest_issues)
    VALUES (p_farm_id, p_season, p_year, p_harvest_date,
            p_yield_kg, p_quality, p_pest_issues);

    SELECT CONCAT('Production recorded. record_id = ',
                  LAST_INSERT_ID()) AS result;
END$$


-- ── Procedure 8: Transfer farmer between cooperatives ────────────
CREATE PROCEDURE sp_transfer_cooperative(
    IN p_farmer_id   INT UNSIGNED,
    IN p_old_coop_id INT UNSIGNED,
    IN p_new_coop_id INT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    UPDATE coop_membership
       SET membership_status = 'Withdrawn'
     WHERE farmer_id = p_farmer_id AND coop_id = p_old_coop_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Transfer failed: farmer not found in specified cooperative';
    END IF;

    INSERT INTO coop_membership(farmer_id, coop_id, join_date, membership_status)
    VALUES (p_farmer_id, p_new_coop_id, CURDATE(), 'Active')
    ON DUPLICATE KEY UPDATE membership_status = 'Active', join_date = CURDATE();

    COMMIT;
    SELECT 'Cooperative transfer completed' AS result;
END$$


-- ── Procedure 9: District production & service delivery report ────
CREATE PROCEDURE sp_district_report(
    IN p_district VARCHAR(60),
    IN p_year     YEAR
)
BEGIN
    SELECT
        p_district                               AS district,
        p_year                                   AS year,
        COUNT(DISTINCT f.farmer_id)              AS registered_farmers,
        COUNT(DISTINCT fm.farm_id)               AS registered_farms,
        COALESCE(SUM(fm.land_size_acres), 0)     AS total_acres,
        COALESCE(SUM(pr.yield_kg), 0)            AS total_yield_kg,
        fn_revenue_estimate(
            COALESCE(SUM(pr.yield_kg), 0), 3500) AS estimated_revenue_ugx,
        COUNT(DISTINCT ads.session_id)           AS advisory_sessions,
        COUNT(DISTINCT de.event_id)              AS distributions
    FROM farmer f
    JOIN  person      p   ON p.national_id  = f.national_id
    JOIN  farm        fm  ON fm.farmer_id   = f.farmer_id
    LEFT JOIN production_record pr
           ON pr.farm_id = fm.farm_id AND pr.year = p_year
    LEFT JOIN interaction i
           ON i.farmer_id = f.farmer_id
          AND i.district  = p_district
          AND YEAR(i.activity_date) = p_year
    LEFT JOIN advisory_session   ads ON ads.activity_id = i.activity_id
    LEFT JOIN distribution_event de  ON de.activity_id  = i.activity_id
    WHERE fm.district = p_district;
END$$


-- ── Procedure 10: Restock a resource batch ────────────────────────
CREATE PROCEDURE sp_restock(
    IN p_supplier_id INT UNSIGNED,
    IN p_batch_no    VARCHAR(40),
    IN p_qty         INT UNSIGNED,
    IN p_unit_cost   DECIMAL(12,2),
    IN p_date        DATE
)
BEGIN
    DECLARE v_rid INT UNSIGNED DEFAULT 0;
    SELECT resource_id INTO v_rid FROM resource
     WHERE batch_no = p_batch_no LIMIT 1;

    IF v_rid > 0 THEN
        UPDATE resource
           SET quantity_available = quantity_available + p_qty,
               date_received      = p_date
         WHERE resource_id = v_rid;
        SELECT CONCAT('Stock updated. resource_id = ', v_rid) AS result;
    ELSE
        INSERT INTO resource(supplier_id, batch_no, date_received,
                             quantity_available, unit_cost_ugx)
        VALUES (p_supplier_id, p_batch_no, p_date, p_qty, p_unit_cost);
        SELECT CONCAT('New batch created. resource_id = ',
                      LAST_INSERT_ID()) AS result;
    END IF;
END$$

DELIMITER ;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 6: AUDIT LOG TABLE & AUDIT TRIGGERS
-- Provides a tamper-evident record of all sensitive changes.
-- ══════════════════════════════════════════════════════════════════

-- ── Audit log table ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_log (
    log_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    log_timestamp TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    table_name    VARCHAR(60)  NOT NULL,
    operation     ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    record_id     VARCHAR(40)  NOT NULL COMMENT 'PK of affected row',
    changed_by    VARCHAR(80)  NOT NULL DEFAULT (USER()),
    old_values    TEXT         NULL     COMMENT 'JSON before-state',
    new_values    TEXT         NULL     COMMENT 'JSON after-state',
    CONSTRAINT pk_audit_log PRIMARY KEY (log_id)
) ENGINE = InnoDB
  COMMENT = 'Tamper-evident audit trail for sensitive data changes';

CREATE INDEX idx_audit_table     ON audit_log(table_name);
CREATE INDEX idx_audit_timestamp ON audit_log(log_timestamp);
CREATE INDEX idx_audit_operation ON audit_log(operation);


-- ── Audit triggers ───────────────────────────────────────────────

DELIMITER $$

-- Audit: farmer INSERT
CREATE TRIGGER trg_audit_farmer_insert
AFTER INSERT ON farmer
FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id, new_values)
    VALUES ('farmer','INSERT', NEW.farmer_id,
        JSON_OBJECT(
            'farmer_id',         NEW.farmer_id,
            'national_id',       NEW.national_id,
            'registration_date', NEW.registration_date,
            'cooperative_member',NEW.cooperative_member));
END$$

-- Audit: farmer UPDATE
CREATE TRIGGER trg_audit_farmer_update
AFTER UPDATE ON farmer
FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id,
                          old_values, new_values)
    VALUES ('farmer','UPDATE', NEW.farmer_id,
        JSON_OBJECT('cooperative_member', OLD.cooperative_member),
        JSON_OBJECT('cooperative_member', NEW.cooperative_member));
END$$

-- Audit: resource stock changes
CREATE TRIGGER trg_audit_resource_update
AFTER UPDATE ON resource
FOR EACH ROW
BEGIN
    IF OLD.quantity_available <> NEW.quantity_available THEN
        INSERT INTO audit_log(table_name, operation, record_id,
                              old_values, new_values)
        VALUES ('resource','UPDATE', NEW.resource_id,
            JSON_OBJECT('batch_no', OLD.batch_no,
                        'qty',      OLD.quantity_available),
            JSON_OBJECT('batch_no', NEW.batch_no,
                        'qty',      NEW.quantity_available));
    END IF;
END$$

-- Audit: every distribution event
CREATE TRIGGER trg_audit_distribution_insert
AFTER INSERT ON distribution_event
FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id, new_values)
    VALUES ('distribution_event','INSERT', NEW.event_id,
        JSON_OBJECT(
            'event_id',           NEW.event_id,
            'resource_id',        NEW.resource_id,
            'quantity_given',     NEW.quantity_given,
            'distribution_point', NEW.distribution_point,
            'received_by',        NEW.received_by,
            'acknowledged',       NEW.acknowledgement_signed));
END$$

-- Audit: complaint status changes
CREATE TRIGGER trg_audit_complaint_update
AFTER UPDATE ON complaint_feedback
FOR EACH ROW
BEGIN
    IF OLD.resolution_status <> NEW.resolution_status THEN
        INSERT INTO audit_log(table_name, operation, record_id,
                              old_values, new_values)
        VALUES ('complaint_feedback','UPDATE', NEW.complaint_id,
            JSON_OBJECT('status', OLD.resolution_status),
            JSON_OBJECT('status', NEW.resolution_status,
                        'resolved_date', NEW.resolved_date));
    END IF;
END$$

-- Audit: advisory session inserts
CREATE TRIGGER trg_audit_advisory_insert
AFTER INSERT ON advisory_session
FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name, operation, record_id, new_values)
    VALUES ('advisory_session','INSERT', NEW.session_id,
        JSON_OBJECT(
            'session_id',    NEW.session_id,
            'staff_id',      NEW.staff_id,
            'follow_up',     NEW.follow_up_required,
            'session_type',  NEW.session_type));
END$$

DELIMITER ;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 7: BACKUP AND RECOVERY STRATEGY
-- ══════════════════════════════════════════════════════════════════

-- ── Backup schedule configuration table ──────────────────────────
CREATE TABLE IF NOT EXISTS backup_config (
    config_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    backup_type    ENUM('Full','Incremental','Binary Log') NOT NULL,
    frequency      VARCHAR(60)  NOT NULL,
    retention_days INT          NOT NULL,
    storage_path   VARCHAR(200) NOT NULL,
    notes          TEXT         NULL,
    CONSTRAINT pk_backup_config PRIMARY KEY (config_id)
) ENGINE = InnoDB COMMENT = 'Backup schedule and retention policy';

INSERT INTO backup_config(backup_type, frequency, retention_days, storage_path, notes)
VALUES
('Full',
 'Every Sunday at 02:00',
 90,
 '/var/backups/agri_db/full/',
 'Full mysqldump including routines, triggers, events. Compressed with gzip.'),

('Incremental',
 'Monday to Saturday at 02:00',
 30,
 '/var/backups/agri_db/incremental/',
 'Binary log backup since last full. Enables replay of daily changes.'),

('Binary Log',
 'Continuous — flushed daily',
 14,
 '/var/lib/mysql/binlog/',
 'Enables point-in-time recovery to any second. Requires log_bin=ON in my.cnf.');


-- ── Backup command reference procedure ───────────────────────────
DELIMITER $$

CREATE PROCEDURE sp_backup_reference()
BEGIN
    SELECT 'FULL BACKUP' AS step,
    'mysqldump -u agri_admin -p --single-transaction --routines --triggers --events --hex-blob agri_services_db | gzip > /var/backups/agri_db/full/agri_db_YYYYMMDD.sql.gz'
    AS command_to_run_in_terminal
    UNION ALL
    SELECT 'FLUSH BINARY LOGS',
    'mysqladmin -u agri_admin -p flush-logs'
    UNION ALL
    SELECT 'RESTORE FULL BACKUP',
    'gunzip < /var/backups/agri_db/full/agri_db_YYYYMMDD.sql.gz | mysql -u agri_admin -p agri_services_db'
    UNION ALL
    SELECT 'POINT-IN-TIME RECOVERY',
    'mysqlbinlog --start-datetime="YYYY-MM-DD HH:MM:SS" --stop-datetime="YYYY-MM-DD HH:MM:SS" /var/lib/mysql/binlog.000001 | mysql -u agri_admin -p agri_services_db'
    UNION ALL
    SELECT 'VERIFY BACKUP',
    'mysqlcheck -u agri_admin -p --all-databases --check --extended';
END$$

DELIMITER ;


-- ══════════════════════════════════════════════════════════════════
-- SECTION 8: SECURITY AND AUTOMATION TESTS
-- Run each labelled block individually.
-- ══════════════════════════════════════════════════════════════════

SELECT '═══════════════════════════════════════' AS '';
SELECT '  SECTION 8 — MILESTONE 4 TESTS BEGIN  ' AS '';
SELECT '═══════════════════════════════════════' AS '';


-- ── T1: Verify all three users were created ───────────────────────
SELECT '── T1: User accounts' AS test;
SELECT user, host, password_expired, account_locked
  FROM mysql.user
 WHERE user IN ('agri_admin','agri_officer','agri_readonly')
 ORDER BY user;


-- ── T2: Verify privilege grants ───────────────────────────────────
SELECT '── T2a: agri_admin grants' AS test;
SHOW GRANTS FOR 'agri_admin'@'localhost';

SELECT '── T2b: agri_officer grants' AS test;
SHOW GRANTS FOR 'agri_officer'@'localhost';

SELECT '── T2c: agri_readonly grants' AS test;
SHOW GRANTS FOR 'agri_readonly'@'localhost';


-- ── T3: Verify all views exist ────────────────────────────────────
SELECT '── T3: All views in database' AS test;
SELECT table_name AS view_name
  FROM information_schema.tables
 WHERE table_schema = 'agri_services_db'
   AND table_type   = 'VIEW'
 ORDER BY table_name;


-- ── T4: Verify all triggers exist ────────────────────────────────
SELECT '── T4: All triggers' AS test;
SELECT trigger_name,
       event_manipulation AS event,
       event_object_table AS on_table,
       action_timing      AS timing
  FROM information_schema.triggers
 WHERE trigger_schema = 'agri_services_db'
 ORDER BY event_object_table, action_timing;


-- ── T5: Test stock auto-deduction trigger ─────────────────────────
SELECT '── T5a: Stock before distribution' AS test;
SELECT resource_id, batch_no, quantity_available
  FROM resource WHERE resource_id = 1;

SELECT '── T5b: Insert distribution — trigger should auto-deduct stock' AS test;
INSERT INTO interaction(farmer_id, activity_date, district, activity_status)
VALUES (2, CURDATE(), 'Wakiso', 'Pending');
SET @t5_act = LAST_INSERT_ID();

INSERT INTO distribution_event(
    activity_id, resource_id, quantity_given,
    distribution_point, received_by, acknowledgement_signed)
VALUES (@t5_act, 1, 25, 'Wakiso Test Office', 'Test Farmer', 1);

SELECT '── T5c: Stock after (should be reduced by 25)' AS test;
SELECT resource_id, batch_no, quantity_available
  FROM resource WHERE resource_id = 1;

SELECT '── T5d: Interaction auto-marked Completed' AS test;
SELECT activity_id, activity_status
  FROM interaction WHERE activity_id = @t5_act;


-- ── T6: Test overstock prevention trigger ─────────────────────────
SELECT '── T6: EXPECTED FAIL — quantity exceeds stock' AS test;
INSERT INTO interaction(farmer_id, activity_date, district, activity_status)
VALUES (1, CURDATE(), 'Mukono', 'Pending');
SET @t6_act = LAST_INSERT_ID();

INSERT IGNORE INTO distribution_event(
    activity_id, resource_id, quantity_given,
    distribution_point, received_by)
VALUES (@t6_act, 1, 999999, 'Test', 'Test');

SELECT IF(NOT EXISTS(
    SELECT 1 FROM distribution_event WHERE activity_id = @t6_act),
    '  PASS: overstock trigger blocked the insert',
    '  FAIL: overstock was allowed') AS result;
DELETE FROM interaction WHERE activity_id = @t6_act;


-- ── T7: Test complaint auto-resolution date ───────────────────────
SELECT '── T7a: Complaint before update' AS test;
SELECT complaint_id, resolution_status, resolved_date
  FROM complaint_feedback WHERE complaint_id = 1;

UPDATE complaint_feedback
   SET resolution_status = 'Resolved'
 WHERE complaint_id = 1;

SELECT '── T7b: resolved_date should now be auto-set' AS test;
SELECT complaint_id, resolution_status, resolved_date
  FROM complaint_feedback WHERE complaint_id = 1;


-- ── T8: Test enrolment capacity trigger ──────────────────────────
SELECT '── T8: Programme capacity check' AS test;
SELECT tp.programme_id, tp.programme_name, tp.max_participants,
       COUNT(pe.farmer_id) AS current_enrolments
  FROM training_programme tp
  LEFT JOIN programme_enrolment pe ON pe.programme_id = tp.programme_id
 GROUP BY tp.programme_id;


-- ── T9: Audit log captures changes ───────────────────────────────
SELECT '── T9a: Force an audited update' AS test;
UPDATE farmer SET cooperative_member = 1 WHERE farmer_id = 2;

SELECT '── T9b: Audit log entries' AS test;
SELECT log_id, log_timestamp, table_name,
       operation, record_id, changed_by,
       old_values, new_values
  FROM audit_log
 ORDER BY log_timestamp DESC
 LIMIT 10;


-- ── T10: Stored procedures ────────────────────────────────────────
SELECT '── T10a: District report — Mukono 2023' AS test;
CALL sp_district_report('Mukono', 2023);

SELECT '── T10b: Restock a batch' AS test;
CALL sp_restock(1, 'BATCH-2025-001', 2000, 1400, CURDATE());

SELECT '── T10c: Verify restocked batch' AS test;
SELECT resource_id, batch_no, quantity_available, unit_cost_ugx
  FROM resource WHERE batch_no = 'BATCH-2025-001';

SELECT '── T10d: Backup reference commands' AS test;
CALL sp_backup_reference();


-- ── T11: Ministry dashboard ───────────────────────────────────────
SELECT '── T11: Ministry dashboard summary' AS test;
SELECT * FROM vw_ministry_dashboard;


-- ── T12: Security views return data without national_id ───────────
SELECT '── T12a: Secure farmer view (no national_id)' AS test;
SELECT farmer_id, full_name, district, farmer_category,
       total_farms, total_acres
  FROM vw_secure_farmer;

SELECT '── T12b: Secure stock view (no unit cost)' AS test;
SELECT resource_id, batch_no, quantity_available,
       stock_status, resource_description
  FROM vw_secure_stock;


-- ── T13: Full audit log review ────────────────────────────────────
SELECT '── T13: Full audit log' AS test;
SELECT log_id, log_timestamp, table_name,
       operation, record_id, changed_by
  FROM audit_log
 ORDER BY log_timestamp DESC;


-- ── T14: Backup configuration ─────────────────────────────────────
SELECT '── T14: Backup schedule' AS test;
SELECT backup_type, frequency, retention_days, storage_path
  FROM backup_config;


-- ── T15: Privilege summary matrix ─────────────────────────────────
SELECT '── T15: Privilege matrix summary' AS test;
SELECT 'agri_admin'  AS role,
       'ALL tables'  AS access_scope,
       'ALL'         AS operations,
       'YES'         AS execute_procedures,
       'YES'         AS manage_users
UNION ALL
SELECT 'agri_officer',
       'Operational tables + secure views',
       'SELECT / INSERT / UPDATE',
       'YES',
       'NO'
UNION ALL
SELECT 'agri_readonly',
       'Reporting views only',
       'SELECT only',
       'Functions only',
       'NO';


SELECT '═══════════════════════════════════════' AS '';
SELECT '  SECTION 8 — ALL MILESTONE 4 TESTS DONE' AS '';
SELECT '═══════════════════════════════════════' AS '';

-- ══════════════════════════════════════════════════════════════════
-- END OF MILESTONE FOUR
-- ══════════════════════════════════════════════════════════════════
