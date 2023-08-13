create database if not exists BloodDonationDB;
use BloodDonationDB;

CREATE TABLE if not exists Persons_T (
	pid char(8) not null unique,
	first_name varchar(20) not null,
	last_name varchar(20) not null,
	dob date not null,
	age integer default 0,
	phone_number varchar(10),
	email_address varchar(30),
	primary key(pid)
);

CREATE TABLE IF NOT EXISTS Address_T (
	pid char(8) not null references Persons_T(pid),
	street_name varchar(30) not null,
	city varchar(20) not null,
	state varchar(20) not null,
	zip_code varchar(5) not null,
	primary key(pid, state),
    constraint `Address_FK` FOREIGN KEY (`pid`) references `Persons_T`(`pid`)
);

CREATE TABLE if not exists Donor_T (
	pid char(8) not null references Persons_T(pid),
	blood_type char(3) not null,
	weightLBS integer not null,
	heightIN integer not null,
	gender char(1) not null,
	nextSafeDonation DATE,
    eligibility varchar(1) null,
	CONSTRAINT check_gender CHECK (gender = 'M' OR gender = 'F'),
	primary key(pid),
    constraint `Donor_FK` FOREIGN KEY (`pid`) references `Persons_T`(`pid`)
);

CREATE TABLE if not exists Patient_T (
	pid char(8) not null references persons_T(pid),
	blood_type char(3) not null,
	need_status varchar(20) not null,  -- The need status field indicates whether their require blood on a high priority or a low priority--
	weightLBS integer not null,
	CONSTRAINT check_status CHECK (need_status = 'high' OR need_status = 'low'),
	primary key(pid),
    constraint `Patient_FK` FOREIGN KEY (`pid`) references `Persons_T`(`pid`)
);

CREATE TABLE IF NOT EXISTS Nurse_T(    
	pid char(8) not null references persons_T(pid),    
	years_experienced integer not null,
	primary key(pid),
    constraint `Nurse_FK` FOREIGN KEY (`pid`) references `Persons_T`(`pid`)
);

CREATE TABLE IF NOT EXISTS Pre_exam_T(
	peid char(8) not null UNIQUE,
	hemoglobin_gDL decimal(5,2) not null,
	temperature_F decimal(5,2) not null,
	blood_pressure char(8) not null,
	pulse_rate_BPM integer not null,
	eligibility_hemoglobin varchar(1) null,
	primary key(peid)
);

CREATE TABLE IF NOT EXISTS Donation_types_T ( 
	dtype varchar(15) not null unique, 
	frequency_days int not null, 
	primary key(dtype)
);

CREATE TABLE IF NOT EXISTS Donation_T ( 
	did char(8) not null, 
	pid char(8) not null references donor_T(pid), 
	peid char(8) not null references pre_exam_T(peid),
	nurse char(8) not null references nurse_T(pid), 
	amount_donated_CC decimal(5,2) not null,
	donation_type varchar(15) not null references donation_types_T(dtype), 
	primary key(did),
    constraint `Donation_FK1` FOREIGN KEY (`pid`) references `Donor_T`(`pid`),
    constraint `Donation_FK2` FOREIGN KEY (`peid`) references `pre_exam_T`(`peid`),
    constraint `Donation_FK3` FOREIGN KEY (`nurse`) references `Nurse_T`(`pid`),
    constraint `Donation_FK4` FOREIGN KEY (`donation_type`) references `Donation_types_T`(`dtype`)
);

CREATE TABLE IF NOT EXISTS Transfusion_T ( 
	tid char(8) not null, 
	pid char(8) not null references patient_T(pid), 
	peid char(8) not null references pre_exam_T(peid), 
	nurse char(8) not null references nurse_T(pid), 
	amount_recieved_CC decimal(5,2) not null, 
	primary key(tid),
    constraint `Transfusion_FK1` FOREIGN KEY (`pid`) references `patient_T`(`pid`),
    constraint `Transfusion_FK2` FOREIGN KEY (`peid`) references `pre_exam_T`(`peid`),
    constraint `Transfusion_FK3` FOREIGN KEY (`nurse`) references `nurse_T`(`pid`)
);

CREATE TABLE if not exists Bloodbags_T ( 
	bbid char(10) not null unique, 
	donation_type VARCHAR(15) not null references donation_types_T(dtype), 
	quantity_CC decimal(5,2) not null, 
	blood_type char(3) not null, 
	primary key(bbid),
    constraint `Bloodbags_FK` FOREIGN KEY (`donation_type`) references `donation_types_T`(`dtype`)
);

CREATE TABLE IF NOT EXISTS LocationCodes_T ( 
	lc char(4) not null unique, 
	descrip text not null, 
	primary key(lc)
);

CREATE TABLE IF NOT EXISTS Locations_T ( 
	lid char(6) not null unique, 
	lname varchar(400) not null, 
	lc char(4) not null references LocationCodes_T(lc), 
	city varchar(50) not null, 
	primary key(lid),
    constraint `Locations_FK` FOREIGN KEY (`lc`) references `LocationCodes_T`(`lc`)
);

CREATE TABLE IF NOT EXISTS GlobalInventory_T ( 
	bbid char(10) not null references bloodbags_T(bbid), 
	lid char(6) not null references locations_T(lid),
	available boolean DEFAULT TRUE,
	primary key (bbid,lid),
    constraint `GlobalInventory_FK1` FOREIGN KEY (`bbid`) references `Bloodbags_T`(`bbid`),
    constraint `GlobalInventory_FK2` FOREIGN KEY (`lid`) references `Locations_T`(`lid`)
);

CREATE TABLE if not exists Requests_T (
	rqid char(8) not null unique,    
	lid char(6) not null references Locations_T(lid),    
	blood_type_requested char(3) not null,    
	date_requested DATE not null,    
	quantity_requestedPints int not null,  
	primary key(rqid),
    constraint `Requests_FK1` FOREIGN KEY (`lid`) references `Locations_T`(`lid`)
);

CREATE TABLE if not exists Donation_records_T(  
	did char(8) not null references Donation_T(did),    
	lid char(4) not null references Locations_T(lid), 
	donation_date DATE not null,    
	bbid char(10) not null references Bloodbags_T(bbid),  
	primary key(did),
	constraint `Donation_records_FK1` FOREIGN KEY (`did`) references `Donation_T`(`did`),
	constraint `Donation_records_FK2` FOREIGN KEY (`lid`) references `Locations_T`(`lid`),
    constraint `Donation_records_FK3` FOREIGN KEY (`bbid`) references `Bloodbags_T`(`bbid`)
);


CREATE TABLE IF NOT EXISTS transfusion_records_T ( 
	tid char(8) not null references transfusion_T(tid), 
	lid char(4) not null references locations_T(lid), 
	transfusion_date date not null, 
	bbid char(10) not null references bloodbags_T(bbid), 
	primary key(tid),
    constraint `Transfusion_records_FK1` FOREIGN KEY (`tid`) references `transfusion_T`(`tid`),
    constraint `Transfusion_records_FK2` FOREIGN KEY (`lid`) references `locations_T`(`lid`),
    constraint `Transfusion_records_FK3` FOREIGN KEY (`bbid`) references `bloodbags_T`(`bbid`)
);

CREATE TABLE IF NOT EXISTS blood_compatibility_T (
	blood_type char(3) not null,
    compatible_blood_type char(3) not null,
    primary key (blood_type, compatible_blood_type)
);

/* Trigger for calculating age on adding new records to the Persons_T table */
DELIMITER //
CREATE TRIGGER age_trg
BEFORE INSERT ON Persons_T
FOR EACH ROW
BEGIN
	set NEW.age = floor(datediff(CURDATE(), NEW.dob)/365);
END// 
DELIMITER ;

/* To Calculate all Person's age after entering dob in Persons_T */
DELIMITER //		
Create Procedure SP_Age_Calculate()
Begin
    update Persons_T set age = floor(datediff(CURDATE(), dob)/365);
End //
DELIMITER ;

/* Event to call stored procedure daily to update age */
CREATE EVENT test_event
ON SCHEDULE EVERY 1 DAY
DO call SP_Age_Calculate();

INSERT INTO Persons_T (pid, first_name, last_name, dob, age, phone_number, email_address)
VALUES  ('p1', 'Barbara','Fournier','1992-09-19', '0', '2065559876', 'barbaraf@gmail.com'),
        ('p2', 'David','Fournier','1979-10-09', '0', '2065569876', 'davidf@outlook.com'),
        ('p3', 'John','Kennedy', '1998-03-23', '0', '2065557854', 'kennedyj@gmail.com'),
        ('p4', 'Sara','Sheskey', '1983-06-15', '0', '2065559893', 'sheskey@gmail.com'),
        ('p5', 'Ann','Patterson','1996-01-29', '0', '2065553487', 'patterson@gmail.com'),
        ('p6', 'Neil','Patterson','1986-04-22', '0', '2065553687', 'neilpatterson@gmail.com'),
        ('p7', 'David', 'Viescas', '1995-10-06', '0', '2068828878', 'viessdavia@gmail.com'),
        ('p8', 'Stephanie','Viescas','1981-05-19', '0', '2068828808', 'stephaniev@gmail.com'),
        ('p9', 'Alastair','Black', '1982-07-08','0', '2065551189', 'alastair@gmail.com'),
        ('p10','David','Cunningham','1983-09-13','0', '2065558122', 'cunningham@gmail.com'),
        ('p11','Angel','Kennedy','1984-10-16','0', '2065557854','angeledy@gmail.com'),
        ('p12','Carol','Viescas','1985-08-30','0','2065557295','carolescas@gmail.com'),
        ('p13','Elizabeth','Hallmark','1986-11-23','0','2065558990','elizabeth@gmail.com'),
        ('p14','Gary','Hallmark','1987-02-28', '0','2065588990','hallmarkg@gmail.com'),
        ('p15','Kathryn','Patterson','2000-09-18','0','2065953487', 'kathrynp@gmail.com'),
        ('p16','Richard','Sheskey','1995-12-01', '0', '2075559893','sheskeyr@gmail.com'),
        ('p17','Kendra','Hernandez','1998-11-11', '0','2066899191', 'hernandez@gmail.com'),
        ('p18','Michael','Hernandez','1995-09-12','0', '2061399191','michnandez@gmail.com'),
        ('p19','John','Viescas','1996-02-07','0','2064515596','johnvisac@gmail.com'),
        ('p20', 'Megan', 'Patterson', '2001-06-25','0','2015583487', 'meganp@gmail.com'),
        ('p21','Zachary', 'Ehrlich', '1999-05-29', '0','2066553857','zachary@gmail.com');

select * from persons_t;

INSERT INTO Address_T (pid, street_name, city, state, zip_code)
VALUES  ('p1', '15127 NE 24th, #383', 'Redmond', 'WA', '98052'),
        ('p2', '122 Spring River Drive', 'Duvall', 'WA', '98019'),
        ('p3', 'Route 2, Box 203B', 'Auburn', 'WA', '98002'),
        ('p4', '672 Lamont Ave', 'Houston', 'TX', '77201'),
        ('p7', '4110 Old Redmond Rd.', 'Redmond', 'WA', '98052'),
        ('p6', '15127 NE 24th, #383', 'Redmond', 'WA', '98052'),
        ('p10', '901 Pine Avenue', 'Portland', 'OR', '97208'),
        ('p8', '233 West Valley Hwy', 'San Diego', 'CA', '92199'),
        ('p9', '507 - 20th Ave. E.\nApt. 2A', 'Seattle', 'WA', '98105'),
        ('p5','667 Red River Road', 'Austin', 'TX', '78710'),
        ('p11','Route 2, Box 203B', 'Woodinville', 'WA', '98072'),
        ('p12','13920 S.E. 40th Street', 'Bellevue', 'WA', '98006'),
        ('p13','2114 Longview Lane', 'San Diego', 'CA', '92199'),
        ('p14','611 Alpine Drive', 'Palm Springs', 'CA', '92263'),
        ('p15','2601 Seaview Lane', 'Chico', 'CA', '95926'),
        ('p16','101 NE 88th', 'Salem', 'OR', '97301'),
        ('p17','66 Spring Valley Drive', 'Medford', 'OR', '97501'),
        ('p21','311 20th Ave. N.E.', 'Fremont', 'CA', '94538'),
        ('p19','12330 Kingman Drive', 'Glendale', 'CA', '91209'),
        ('p20','2424 Thames Drive', 'Bellevue', 'WA', '98006'),
        ('p18','2500 Rosales Lane', 'Dallas', 'TX', '75260');

/* Function to get a person's age by passing PID */
DELIMITER //
CREATE FUNCTION get_person_age
(
pid_param char(8)
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE get_person_age INT;
SELECT 
    age
INTO get_person_age FROM
    Persons_T
WHERE
    pid = pid_param;
    RETURN get_person_age;
END//
DELIMITER ;

/* Trigger to update eligibility of new donors whenever new inserts are made on Donor_T table */
DELIMITER //
CREATE TRIGGER eligibility_trg
BEFORE INSERT ON Donor_T
FOR EACH ROW
BEGIN
    SET NEW.eligibility = CASE WHEN NEW.heightIN >= 64 AND NEW.weightLBS >= 110 AND get_person_age(NEW.pid) > 17 THEN "Y" ELSE "N" END;
END// 
DELIMITER ;

/* To update eligibility column for existing records in Donor_T table */
DELIMITER //
Create Procedure SP_Eligibilty_check()
Begin
    UPDATE Donor_T d
	SET d.eligibility = CASE WHEN heightIN >= 64 AND weightLBS >= 110 AND get_person_age(d.pid) > 17 THEN "Y" ELSE "N" END;
End //
DELIMITER ;

INSERT INTO Donor_T(pid, blood_type, weightLBS, heightIN, gender)
VALUES  ('p4', 'O+', '149', '70', 'F'),
        ('p5', 'O+', '149', '70', 'F'),
        ('p7', 'O-', '170', '74', 'M'),
        ('p8', 'AB-', '148', '66', 'F'),
        ('p9', 'B-', '180', '71', 'M'),
        ('p13', 'O+', '212', '76', 'M'),
        ('p14', 'B-', '128', '67', 'F'),
        ('p15', 'AB+', '104', '65', 'F'),
        ('p20', 'A+', '178', '72', 'M'),
        ('p21', 'AB+', '120', '65', 'F'),
		('p2', 'A+', '120', '57', 'F'),
		('p16', 'AB-', '105', '65', 'M'),
		('p18', 'B+', '120', '59', 'M');
        
select * from donor_t;
        
INSERT INTO Patient_T (pid, blood_type, need_status, weightLBS)
VALUES  ('p1', 'O+', 'low', '172'),
        ('p3', 'A+', 'low', '185'),
        ('p6', 'AB+', 'high', '128'),
        ('p11', 'B+', 'low', '120'),
        ('p12', 'A+', 'low', '118'),
        ('p10', 'O-', 'high', '145');

INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p2", 12);
INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p4", 17);
INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p10", 5);
INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p16", 18);
INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p17", 9);
INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p18", 10);
INSERT INTO Nurse_T (pid, years_experienced) VALUES ("p19", 12);

/* Trigger to update pre_exam eligibility status of new donors whenever new inserts are made on pre_exam_T table */
DELIMITER //
CREATE TRIGGER test_eligibility_trg
BEFORE INSERT ON pre_exam_T
FOR EACH ROW
BEGIN
    SET NEW.eligibility_hemoglobin = CASE WHEN NEW.hemoglobin_gDL >= 12.50 THEN "Y" ELSE "N" END;
END// 
DELIMITER ;

INSERT INTO pre_exam_t values ("pe1", 15.2, 98.6, "120/80", 70, "");
INSERT INTO pre_exam_t values ("pe2", 14.9, 98.5, "110/70", 75, "");
INSERT INTO pre_exam_t values ("pe3", 15.7, 98.5, "130/85", 59, "");
INSERT INTO pre_exam_t values ("pe4", 16.1, 98.4, "120/80", 67, "");
INSERT INTO pre_exam_t values ("pe5", 14.2, 98.3, "90/80", 90, "");
INSERT INTO pre_exam_t values ("pe6", 17.1, 98.2, "110/70", 44, "");
INSERT INTO pre_exam_t values ("pe7", 14.2, 98.1, "140/90", 79, "");
INSERT INTO pre_exam_t values ("pe8", 7.1, 98.9, "90/60", 65, "");
INSERT INTO pre_exam_t values ("pe9", 8, 98.6, "130/85", 80, "");
INSERT INTO pre_exam_t values ("pe10", 7.9, 98.7, "120/80", 82, "");
INSERT INTO pre_exam_t values ("pe11", 7.6, 98.4, "90/60", 76, "");
INSERT INTO pre_exam_t values ("pe12", 6.9, 98.5, "120/80", 70, "");
INSERT INTO pre_exam_t values ("pe13", 14.5, 98.3, "120/80", 70, "");
INSERT INTO pre_exam_t values ("pe14", 15.3, 98.4, "110/70", 77, "");
INSERT INTO pre_exam_t values ("pe15", 14.3, 98.3, "120/80", 63, "");
INSERT INTO pre_exam_t values ("pe16", 13.9, 98.3, "110/70", 81, "");
INSERT INTO pre_exam_t values ("pe17", 16.4, 98.8, "120/80", 72, "");
INSERT INTO pre_exam_t values ("pe18", 17.1, 98.1, "120/80", 59, "");

select * from pre_exam_t;

INSERT INTO `Donation_types_T` VALUES ('Blood',56);
INSERT INTO `Donation_types_T` VALUES ('Platelets',7);
INSERT INTO `Donation_types_T` VALUES ('Plasma',28);
INSERT INTO `Donation_types_T` VALUES ('PowerRed',112);
    
INSERT INTO `Donation_T` VALUES ('d1','p5','pe1','p16',946,"PowerRed"),
	('d2','p7','pe2','p17',473,"Blood"),
	('d3','p8','pe3','p4',473,"Plasma"),
	('d4','p9','pe4','p19',473,"Blood"),
	('d5','p13','pe5','p16',473,"Blood"),
	('d6','p14','pe6','p16','473',"Blood"),
	('d7','p15','pe7','p10','473',"Blood"),
	('d8','p4','pe13','p17','473',"Blood"),
	('d9','p14','pe14','p2','473',"Blood"),
	('d10','p20','pe15','p18','473',"Blood"),
	('d11','p15','pe16','p18','473',"Blood"),
	('d12','p21','pe17','p19','473',"Blood"),
	('d13','p20','pe18','p16','473',"Blood");
    
select * from donation_T;
    
INSERT INTO `Transfusion_T` VALUES ('t1','p1','pe14','p4',473),
    ('t2','p12','pe9','p4',946),
    ('t3','p3','pe10','p2',473),
    ('t4','p10','pe11','p10',716),
    ('t5','p6','pe12','p4',473);

select * from Transfusion_t;

INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb1", "Blood", 473, "O+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb2", "Blood", 473, "O-");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb3", "PowerRed", 946, "O+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb4", "Plasma", 473, "AB-");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb5", "Blood", 473, "B-");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb6", "Blood", 473, "B+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb7", "Platelets", 473, "O+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb8", "Blood", 473, "A+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb9", "Blood", 473, "AB+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb10", "Blood", 473, "A+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb11", "Blood", 473, "B+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb12", "Blood", 473, "O+");
INSERT INTO BloodBags_T (bbid, donation_type, quantity_CC, blood_type) VALUES ("bb13", "Blood", 473, "O+");

INSERT INTO LocationCodes_T (lc, descrip) VALUES ("ARCF", "American Red Cross Facility");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("BDHS", "Blood Drive - High School");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("BDUN", "Blood Drive - University");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("BDCO", "Blood Drive - College");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("BDOG", "Blood Drive - Organization");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("MILT", "Military Facility");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("CLIN", "Clinics");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("HSPT", "Hospital");
INSERT INTO LocationCodes_T (lc, descrip) VALUES ("RESR", "Research Facility");

INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L1", "Mid Hudson Regional Hospital", "HSPT", "Poughkeepsie");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L2", "Vassar Brothers Medical Center", "CLIN", "Vassar");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L3", "Marist College", "BDCO", "Poughkeepsie");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L4", "Fort Monmouth", "MILT", "Eatontown");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L5", "American Red Cross Eastern New York Chapter", "ARCF", "Albany");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L6", "Ramsey High School", "BDHS", "Ramsey");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L7", "Charlesville Emergency Clinic", "CLIN", "Chatstown");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L8", "IBM", "BDOG", "Poughkeepsie");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L9", "Poughkeepsie Galleria", "BDOG", "Poughkeepsie");
INSERT INTO Locations_T (lid, lname, lc, city) VALUES ("L10", "American Red Cross Eastern New York Chapter", "ARCF", "New York");

INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb2", "L5", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb3", "L10", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb4", "L5", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb5", "L7", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb7", "L5", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb11", "L7", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb12", "L10", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb13", "L2", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb1", "L5", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb8", "L1", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb9", "L1", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb6", "L10", TRUE);
INSERT INTO GlobalInventory_T (bbid, lid, available) VALUES ("bb10", "L10", TRUE);

INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq1", "L5", "A+", "2022-01-08",10000);
INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq2", "L10", "A-", "2022-01-08",9000);
INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq3", "L1", "A-", "2022-02-09",3600);
INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq4", "L2", "O-", "2022-03-08",13000);
INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq5", "L1", "AB-", "2022-03-21",7000);
INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq6", "L1", "B-", "2022-04-16",6000);
INSERT INTO requests_T (rqid, lid, blood_type_requested, date_requested, quantity_requestedPints) VALUES ("rq7", "L7", "O-", "2022-05-01",12000);

/* Function to get PID of a person by passing Donation ID. Used in the SP update_next_donation_date */
DELIMITER //
CREATE FUNCTION get_pid_from_did (did1 char(8))
RETURNS CHAR(8)
DETERMINISTIC
BEGIN
	DECLARE pid1 char(8);
    SELECT pid FROM Donation_T WHERE did = did1 INTO pid1;
    RETURN pid1;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION update_next_donation_date(did1 char(8))
RETURNS DATE
DETERMINISTIC
BEGIN
	DECLARE no_of_days INT;
    DECLARE last_donation_date DATE;
    DECLARE pid1 CHAR(8);
    DECLARE next_date DATE;
    SELECT frequency_days FROM donation_types_t dty INNER JOIN Donation_t d ON dty.dtype = d.donation_type WHERE d.did = did1 INTO no_of_days;
    SELECT donation_date FROM donation_records_t WHERE did = did1 INTO last_donation_date;
    SELECT get_pid_from_did(did1) INTO pid1;
    SELECT DATE_ADD(last_donation_date, INTERVAL no_of_days DAY) INTO next_date;
    RETURN next_date;
END //
DELIMITER ;

/* Trigger to call SP which updates next safe donation date in Donor_T table */
DELIMITER //
CREATE TRIGGER update_next_safe_donation_date_trg
AFTER INSERT ON donation_records_t
FOR EACH ROW
BEGIN
	 CALL update_next_donation_date_proc(NEW.did);
END//
DELIMITER ;

/* Procedure to update next donation date of donors by passing new donation IDs */
DELIMITER //
CREATE PROCEDURE update_next_donation_date_proc (did char(8))
BEGIN
	update donor_t set nextSafeDonation = update_next_donation_date(did) where pid = get_pid_from_did(did) and eligibility = 'Y';
END //
DELIMITER ;

INSERT INTO `Donation_records_T` VALUES ('d1','L3','2022-01-07',"bb3"),
('d2','L6','2022-01-31',"bb2"),
('d3','L8','2022-02-24',"bb4"),
('d4','L9','2022-03-10',"bb5"),
('d5','L3','2022-03-16',"bb7"),
('d6','L3','2022-04-01',"bb11"),
('d8','L3','2022-05-03',"bb13"),
('d10','L6','2022-06-13',"bb6"),
('d13','L3','2022-08-02',"bb10");

select * from donation_records_t;
select * from donor_t;

/* Trigger to call SP which updates inventory status on adding new row on Transfusion_T table */
DELIMITER //
CREATE TRIGGER update_inventory_status_trg
AFTER INSERT ON transfusion_records_t
FOR EACH ROW
BEGIN
	CALL update_inventory_status(NEW.bbid);
END//
DELIMITER ;

/* To update inventory status by passing blood bag ID */
DELIMITER //
CREATE PROCEDURE update_inventory_status(bbid1 char(10))
BEGIN
	UPDATE globalinventory_t SET available = FALSE WHERE globalinventory_t.bbid = bbid1;
END//
DELIMITER ;

select * from globalinventory_t;

INSERT INTO `transfusion_records_T` VALUES ('t1','L1','2022-01-10','bb3'),
    ('t2','L5','2022-02-26','bb4'),
    ('t3','L1','2022-03-01','bb2'),
    ('t4','L10','2022-03-15','bb5'),
    ('t5','L5','2022-06-21','bb13');
    
select * from transfusion_records_t;

INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("A+","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("A+","O+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("A+","A+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("A+","A-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("A-","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("A-","A-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("B+","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("B+","O+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("B+","B+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("B+","B-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("B-","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("B-","B-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","O+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","AB+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","AB-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","A+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","A-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","B+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB+","B-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB-","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB-","AB-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB-","A-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("AB-","B-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("O+","O-");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("O+","O+");
INSERT INTO blood_compatibility_T (blood_type, compatible_blood_type) VALUES ("O-","O-");

select * from globalinventory_t;

/* View to see all donor related info */
CREATE VIEW donor_info AS
    SELECT 
        d.pid,
        blood_type,
        eligibility,
        dt.did,
        peid,
        nurse,
        donation_type,
        lid,
        donation_date,
        bbid
    FROM
        donor_t d
            INNER JOIN
        donation_t dt ON d.pid = dt.pid
            INNER JOIN
        donation_records_t dr ON dt.did = dr.did;

CREATE VIEW Patient_Donor_Data_View AS
    SELECT 
        t.tid, t.pid 'Patient PID', d.pid 'Donor PID'
    FROM
        donation_records_t dr
            INNER JOIN
        donation_t d ON dr.did = d.did
            INNER JOIN
        transfusion_records_t tr ON tr.bbid = dr.bbid
            INNER JOIN
        transfusion_t t ON t.tid = tr.tid; 

/* Select Queries */

SELECT 
    CONCAT(p.first_name, ' ', p.last_name) 'Patient Name',
    CONCAT(p1.first_name, ' ', p1.last_name) 'Donor Name'
FROM
    patient_donor_data_view pv
        INNER JOIN
    persons_t p ON pv.`Patient PID` = p.pid
        INNER JOIN
    persons_t p1 ON pv.`Donor PID` = p1.pid;

SELECT 
    bb.bbid,
    donation_date,
    donation_type,
    CASE
        WHEN donation_type = 'Blood' THEN DATE_ADD(donation_date, INTERVAL 34 DAY)
        WHEN donation_type = 'PowerRed' THEN DATE_ADD(donation_date, INTERVAL 42 DAY)
        WHEN donation_type = 'Platelets' THEN DATE_ADD(donation_date, INTERVAL 5 DAY)
        ELSE DATE_ADD(donation_date, INTERVAL 1 YEAR)
    END `Expiry Date`
FROM
    bloodbags_t bb
        INNER JOIN
    donation_records_t dt ON bb.bbid = dt.bbid;

SELECT 
    bb.blood_type,
    bb.donation_type,
    SUM(bb.quantity_CC) AS TotalAmount
FROM
    bloodbags_t bb
        INNER JOIN
    globalinventory_t gi USING (bbid)
WHERE
    available = 1
GROUP BY bb.blood_type , bb.donation_type
ORDER BY TotalAmount ASC;

SELECT 
    p.pid,
    CONCAT(first_name, ' ', last_name) AS DonorName,
    d.blood_type,
    COUNT(d.pid) AS TimesDonated,
    SUM(dn.amount_donated_CC) AS TotalAmount
FROM
    persons_t p
        INNER JOIN
    donor_t d USING (pid)
        INNER JOIN
    donation_t dn USING (pid)
GROUP BY p.pid
ORDER BY TotalAmount DESC; 

SELECT r.blood_type_requested as "requested bloodtype" ,bc.compatible_blood_type as"Compatible bloodtype"
FROM blood_compatibility_t bc,requests_t r ,bloodbags_t bb
WHERE bc.blood_type = r.blood_type_requested and bc.blood_type != bc.compatible_blood_type and r.blood_type_requested in   
(SELECT r.blood_type_requested from requests_t r
JOIN bloodbags_t bb,globalinventory_t gi,blood_compatibility_t bc 
WHERE r.blood_type_requested = bb.blood_type and bb.bbid = gi.bbid and gi.available = 0)
GROUP BY bc.compatible_blood_type, r.blood_type_requested ;

SELECT r.blood_type_requested as "Requested bloodtype",d.blood_type as "Donated bloodtype",count(pid) as "Donation count",rqid, count(rqid) as "Request count" from donor_t d
INNER JOIN donation_t dn using(pid)
RIGHT JOIN requests_t r on d.blood_type = r.blood_type_requested
WHERE blood_type_requested in ("A+","O-","A-")
GROUP BY blood_type_requested;


SELECT DISTINCT
    d.pid,
    first_name,
    last_name,
    gender,
    age,
    blood_type,
    weightLBS,
    heightIN,
    pe.peid,
    hemoglobin_gDL,
    temperature_F,
    blood_pressure,
    pulse_rate_BPM
FROM
    Donor_T d
        JOIN
    Donation_T dn ON d.pid = dn.pid
        JOIN
    persons_T p ON d.pid = p.pid
        JOIN
    Pre_exam_T pe ON pe.peid = dn.peid
WHERE
    eligibility = 'Y'
ORDER BY d.pid; 

SELECT DISTINCT
    p.pid,
    first_name,
    last_name,
    gender,
    age,
    blood_type,
    donation_type,
    frequency_days,
    donation_date,
    nextSafeDonation,
    TIMESTAMPDIFF(DAY,
        donation_date,
        nextSafeDonation) AS day_diff
FROM
    donor_T d
        JOIN
    persons_T p ON d.pid = p.pid
        JOIN
    Donation_T dn ON dn.pid = d.pid
        JOIN
    Donation_records_T dr ON dr.did = dn.did
        JOIN
    Donation_types_T dt ON dt.dtype = dn.donation_type
WHERE
    d.eligibility = 'Y'
        AND d.nextSafeDonation < NOW(); 
        
SELECT 
    descrip AS Location_type, COUNT(*) AS Donation_frequency
FROM
    LocationCodes_T lc
        JOIN
    Locations_T l ON lc.lc = l.lc
        JOIN
    Donation_records_T dr ON dr.lid = l.lid
GROUP BY descrip;

SELECT 
    b.bbid,
    donation_type,
    blood_type,
    quantity_CC,
    donation_date
FROM
    Donation_records_T d
        JOIN
    Bloodbags_T b ON b.bbid = d.bbid
ORDER BY donation_date; 

SELECT DISTINCT
    (nurse), first_name, last_name
FROM
    Donation_T d
        JOIN
    Nurse_T n ON d.nurse = n.pid
        JOIN
    Persons_T p ON n.pid = p.pid;

SELECT gi.lid,
SUM(bb.quantity_CC) AS totQuantity, bb.blood_type, bb.donation_type
FROM globalinventory_t gi INNER JOIN bloodbags_t bb ON gi.bbid = bb.bbid 
INNER JOIN locations_t l ON gi.lid = l.lid where gi.available = 1
GROUP BY blood_type, donation_type, gi.lid
ORDER BY lid desc,
totquantity desc;

