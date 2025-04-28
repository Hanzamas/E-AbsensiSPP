-- ====================================================
-- 1) DROP EXISTING TABLES
-- ====================================================
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS pembayaran_spp;
DROP TABLE IF EXISTS tagihan_spp;
DROP TABLE IF EXISTS absensi;
DROP TABLE IF EXISTS sesi_pelajaran;
DROP TABLE IF EXISTS pengajaran;
DROP TABLE IF EXISTS siswa;
DROP TABLE IF EXISTS guru;
DROP TABLE IF EXISTS mapel;
DROP TABLE IF EXISTS kelas;
DROP TABLE IF EXISTS tahun_ajaran;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;

-- ====================================================
-- 2) CREATE TABLES
-- ====================================================
CREATE TABLE users (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  username          VARCHAR(50)     NOT NULL UNIQUE,
  email             VARCHAR(100)    NOT NULL,
  password          VARCHAR(255)    NOT NULL,
  role              ENUM('siswa','guru','admin') NOT NULL,
  is_active         BOOLEAN         NOT NULL DEFAULT TRUE,
  last_login        DATETIME        NULL,
  created_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE guru (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_users          INT             NOT NULL UNIQUE,
  nip               VARCHAR(20)     NULL,
  nama_lengkap      VARCHAR(100)    NOT NULL,
  jenis_kelamin     ENUM('L','P')   NULL,
  tanggal_lahir     DATE            NULL,
  tempat_lahir      VARCHAR(100)    NULL,
  alamat            TEXT            NULL,
  pendidikan_terakhir VARCHAR(100)  NULL,
  FOREIGN KEY (id_users) REFERENCES users(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE tahun_ajaran (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  nama              VARCHAR(20)     NOT NULL,
  tanggal_mulai     DATE            NOT NULL,
  tanggal_selesai   DATE            NOT NULL
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE kelas (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  nama              VARCHAR(50)     NOT NULL,
  kapasitas         INT             NOT NULL,
  id_tahun_ajaran   INT             NOT NULL,
  FOREIGN KEY (id_tahun_ajaran) REFERENCES tahun_ajaran(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE mapel (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  nama              VARCHAR(50)     NOT NULL,
  deskripsi         TEXT            NULL
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE siswa (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_users          INT             NOT NULL UNIQUE,
  id_kelas          INT             NOT NULL,
  nis               VARCHAR(20)     NULL,
  nama_lengkap      VARCHAR(100)    NOT NULL,
  jenis_kelamin     ENUM('L','P')   NULL,
  tanggal_lahir     DATE            NULL,
  tempat_lahir      VARCHAR(100)    NULL,
  alamat            TEXT            NULL,
  wali              VARCHAR(100)    NULL,
  wa_wali           VARCHAR(20)     NULL,
  FOREIGN KEY (id_users) REFERENCES users(id),
  FOREIGN KEY (id_kelas) REFERENCES kelas(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE pengajaran (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_guru           INT             NOT NULL,
  id_mapel          INT             NOT NULL,
  id_kelas          INT             NOT NULL,
  FOREIGN KEY (id_guru)  REFERENCES guru(id),
  FOREIGN KEY (id_mapel) REFERENCES mapel(id),
  FOREIGN KEY (id_kelas) REFERENCES kelas(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE sesi_pelajaran (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_pengajaran     INT             NOT NULL,
  tanggal           DATE            NOT NULL,
  qr_token          VARCHAR(100)    NOT NULL,
  jam_mulai         TIME            NOT NULL,
  jam_selesai       TIME            NOT NULL,
  lokasi_qr         VARCHAR(100)    NULL,
  status_sesi       ENUM('aktif','selesai','dihapus') NOT NULL,
  FOREIGN KEY (id_pengajaran) REFERENCES pengajaran(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE absensi (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_sesi           INT             NOT NULL,
  id_siswa          INT             NOT NULL,
  waktu_scan        DATETIME        NOT NULL,
  status            ENUM('Hadir','Izin','Sakit','Alpha') NOT NULL,
  keterangan        TEXT            NULL,
  valid             BOOLEAN         NOT NULL DEFAULT TRUE,
  FOREIGN KEY (id_sesi)  REFERENCES sesi_pelajaran(id),
  FOREIGN KEY (id_siswa) REFERENCES siswa(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE tagihan_spp (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_siswa          INT             NOT NULL,
  bulan             VARCHAR(20)     NOT NULL,
  nominal           DECIMAL(12,2)   NOT NULL,
  status            ENUM('belum_bayar','sudah_bayar') NOT NULL,
  external_id       VARCHAR(100)     NULL,
  due_date          DATE            NOT NULL,
  FOREIGN KEY (id_siswa) REFERENCES siswa(id)
) ENGINE=InnoDB CHARSET=utf8mb4;

CREATE TABLE pembayaran_spp (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  id_tagihan        INT             NOT NULL,
  tanggal_bayar     DATETIME        NOT NULL,
  metode_bayar      VARCHAR(50)     NULL,
  status            VARCHAR(50)     NULL,
  denda             DECIMAL(12,2)   DEFAULT 0,
  no_referensi      VARCHAR(50)     NULL,
  FOREIGN KEY (id_tagihan) REFERENCES tagihan_spp(id)
) ENGINE=InnoDB CHARSET=utf8mb4;


-- ====================================================
-- 3) DUMMY DATA MINIMAL 10 BARIS PER TABEL
-- ====================================================
-- 3.1 users (20)
INSERT INTO users (username,email,password,role,is_active,last_login,created_at,updated_at) VALUES
('guru01','guru01@sch.id','$2y$…','guru',1,NULL,'2025-04-01 08:00:00','2025-04-01 08:00:00'),
('guru02','guru02@sch.id','$2y$…','guru',1,NULL,'2025-04-01 08:10:00','2025-04-01 08:10:00'),
('guru03','guru03@sch.id','$2y$…','guru',1,NULL,'2025-04-01 08:20:00','2025-04-01 08:20:00'),
('guru04','guru04@sch.id','$2y$…','guru',1,NULL,'2025-04-01 08:30:00','2025-04-01 08:30:00'),
('guru05','guru05@sch.id','$2y$…','guru',1,NULL,'2025-04-01 08:40:00','2025-04-01 08:40:00'),
('guru06','guru06@sch.id','$2y$…','guru',1,NULL,'2025-04-01 08:50:00','2025-04-01 08:50:00'),
('guru07','guru07@sch.id','$2y$…','guru',1,NULL,'2025-04-01 09:00:00','2025-04-01 09:00:00'),
('guru08','guru08@sch.id','$2y$…','guru',1,NULL,'2025-04-01 09:10:00','2025-04-01 09:10:00'),
('guru09','guru09@sch.id','$2y$…','guru',1,NULL,'2025-04-01 09:20:00','2025-04-01 09:20:00'),
('guru10','guru10@sch.id','$2y$…','guru',1,NULL,'2025-04-01 09:30:00','2025-04-01 09:30:00'),
('siswa01','siswa01@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 10:00:00','2025-04-01 10:00:00'),
('siswa02','siswa02@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 10:10:00','2025-04-01 10:10:00'),
('siswa03','siswa03@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 10:20:00','2025-04-01 10:20:00'),
('siswa04','siswa04@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 10:30:00','2025-04-01 10:30:00'),
('siswa05','siswa05@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 10:40:00','2025-04-01 10:40:00'),
('siswa06','siswa06@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 10:50:00','2025-04-01 10:50:00'),
('siswa07','siswa07@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 11:00:00','2025-04-01 11:00:00'),
('siswa08','siswa08@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 11:10:00','2025-04-01 11:10:00'),
('siswa09','siswa09@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 11:20:00','2025-04-01 11:20:00'),
('siswa10','siswa10@fam.com','$2y$…','siswa',1,NULL,'2025-04-01 11:30:00','2025-04-01 11:30:00');

-- 3.2 tahun_ajaran (10)
INSERT INTO tahun_ajaran (nama,tanggal_mulai,tanggal_selesai) VALUES
('2015/2016','2015-07-01','2016-06-30'),
('2016/2017','2016-07-01','2017-06-30'),
('2017/2018','2017-07-01','2018-06-30'),
('2018/2019','2018-07-01','2019-06-30'),
('2019/2020','2019-07-01','2020-06-30'),
('2020/2021','2020-07-01','2021-06-30'),
('2021/2022','2021-07-01','2022-06-30'),
('2022/2023','2022-07-01','2023-06-30'),
('2023/2024','2023-07-01','2024-06-30'),
('2024/2025','2024-07-01','2025-06-30');

-- 3.3 kelas (10)
INSERT INTO kelas (nama,kapasitas,id_tahun_ajaran) VALUES
('X IPA 1',30,10),('X IPA 2',30,10),
('X IPS 1',30,10),('X IPS 2',30,10),
('XI IPA 1',30,9),('XI IPA 2',30,9),
('XI IPS 1',30,9),('XI IPS 2',30,9),
('XII IPA 1',30,8),('XII IPS 1',30,8);

-- 3.4 mapel (10)
INSERT INTO mapel (nama,deskripsi) VALUES
('Matematika','Dasar Matematika'),
('Fisika','Dasar Fisika'),
('Kimia','Dasar Kimia'),
('Biologi','Dasar Biologi'),
('Bahasa Inggris','Bahasa Inggris'),
('Sejarah','Sejarah Dunia'),
('Geografi','Ilmu Geografi'),
('PJOK','Pendidikan Jasmani'),
('Seni Budaya','Seni dan Budaya'),
('TIK','Teknologi Informasi');

-- 3.5 guru (10)
INSERT INTO guru (id_users,nip,nama_lengkap,jenis_kelamin,tanggal_lahir,tempat_lahir,alamat,pendidikan_terakhir) VALUES
(1,'GIP01','Guru A','L','1980-01-01','Jakarta','Jl. Merdeka 1','S2'),
(2,'GIP02','Guru B','P','1982-02-02','Bandung','Jl. Merdeka 2','S2'),
(3,'GIP03','Guru C','L','1979-03-03','Surabaya','Jl. Merdeka 3','S1'),
(4,'GIP04','Guru D','P','1981-04-04','Medan','Jl. Merdeka 4','S2'),
(5,'GIP05','Guru E','L','1983-05-05','Semarang','Jl. Merdeka 5','S1'),
(6,'GIP06','Guru F','P','1984-06-06','Yogyakarta','Jl. Merdeka 6','S2'),
(7,'GIP07','Guru G','L','1985-07-07','Malang','Jl. Merdeka 7','S1'),
(8,'GIP08','Guru H','P','1986-08-08','Solo','Jl. Merdeka 8','S2'),
(9,'GIP09','Guru I','L','1987-09-09','Padang','Jl. Merdeka 9','S1'),
(10,'GIP10','Guru J','P','1988-10-10','Makassar','Jl. Merdeka 10','S2');

-- 3.6 siswa (10)
INSERT INTO siswa (id_users,id_kelas,nis,nama_lengkap,jenis_kelamin,tanggal_lahir,tempat_lahir,alamat,wali,wa_wali) VALUES
(11,1,'SIP01','Siswa A','L','2005-01-01','Jakarta','Jl. Mawar 1','Ortu A','081100000001'),
(12,2,'SIP02','Siswa B','P','2005-02-02','Bandung','Jl. Mawar 2','Ortu B','081100000002'),
(13,3,'SIP03','Siswa C','L','2005-03-03','Surabaya','Jl. Mawar 3','Ortu C','081100000003'),
(14,4,'SIP04','Siswa D','P','2005-04-04','Medan','Jl. Mawar 4','Ortu D','081100000004'),
(15,5,'SIP05','Siswa E','L','2005-05-05','Semarang','Jl. Mawar 5','Ortu E','081100000005'),
(16,6,'SIP06','Siswa F','P','2005-06-06','Yogyakarta','Jl. Mawar 6','Ortu F','081100000006'),
(17,7,'SIP07','Siswa G','L','2005-07-07','Malang','Jl. Mawar 7','Ortu G','081100000007'),
(18,8,'SIP08','Siswa H','P','2005-08-08','Solo','Jl. Mawar 8','Ortu H','081100000008'),
(19,9,'SIP09','Siswa I','L','2005-09-09','Padang','Jl. Mawar 9','Ortu I','081100000009'),
(20,10,'SIP10','Siswa J','P','2005-10-10','Makassar','Jl. Mawar 10','Ortu J','081100000010');

-- 3.7 pengajaran (10)
INSERT INTO pengajaran (id_guru,id_mapel,id_kelas) VALUES
(1,1,1),(2,2,1),(3,3,2),(4,4,2),(5,5,3),
(6,6,3),(7,7,4),(8,8,4),(9,9,5),(10,10,5);

-- 3.8 sesi_pelajaran (10)
INSERT INTO sesi_pelajaran (id_pengajaran,tanggal,qr_token,jam_mulai,jam_selesai,lokasi_qr,status_sesi) VALUES
(1,'2025-04-01','tk1','07:00','08:00','R101','aktif'),
(2,'2025-04-02','tk2','07:00','08:00','R101','aktif'),
(3,'2025-04-03','tk3','08:00','09:00','R102','aktif'),
(4,'2025-04-04','tk4','08:00','09:00','R102','aktif'),
(5,'2025-04-05','tk5','09:00','10:00','R103','aktif'),
(6,'2025-04-06','tk6','09:00','10:00','R103','aktif'),
(7,'2025-04-07','tk7','10:00','11:00','R104','aktif'),
(8,'2025-04-08','tk8','10:00','11:00','R104','aktif'),
(9,'2025-04-09','tk9','11:00','12:00','R105','aktif'),
(10,'2025-04-10','tk10','11:00','12:00','R105','aktif');

-- 3.9 absensi (10)
INSERT INTO absensi (id_sesi,id_siswa,waktu_scan,status,keterangan,valid) VALUES
(1,1,'2025-04-01 07:05','Hadir','',TRUE),
(1,2,'2025-04-01 07:07','Alpha','Telat',FALSE),
(2,3,'2025-04-02 07:05','Hadir','',TRUE),
(3,4,'2025-04-03 08:10','Izin','Ortu izin',TRUE),
(4,5,'2025-04-04 08:00','Sakit','Demam',TRUE),
(5,6,'2025-04-05 09:02','Hadir','',TRUE),
(6,7,'2025-04-06 09:15','Alpha','Telat',FALSE),
(7,8,'2025-04-07 10:05','Hadir','',TRUE),
(8,9,'2025-04-08 10:20','Izin','Ortu izin',TRUE),
(9,10,'2025-04-09 11:03','Hadir','',TRUE);

-- 3.10 tagihan_spp (10)
INSERT INTO tagihan_spp (id_siswa,bulan,nominal,status,external_id,due_date) VALUES
(1,'April 2025',250000,'sudah_bayar','123456788991','2025-04-30'),
(2,'April 2025',250000,'sudah_bayar','123456788991','2025-04-30'),
(3,'April 2025',250000,'sudah_bayar','123456788991','2025-04-30'),
(4,'April 2025',250000,'belum_bayar','123456788991','2025-04-30'),
(5,'April 2025',250000,'belum_bayar','123456788991','2025-04-30'),
(6,'April 2025',250000,'belum_bayar','123456788991','2025-04-30'),
(7,'Maret 2025',250000,'sudah_bayar','123456788991','2025-03-31'),
(8,'Maret 2025',250000,'sudah_bayar','123456788991','2025-03-31'),
(9,'Maret 2025',250000,'sudah_bayar','123456788991','2025-03-31'),
(10,'Maret 2025',250000,'belum_bayar','123456788991','2025-03-31');

-- 3.11 pembayaran_spp (10)
INSERT INTO pembayaran_spp (id_tagihan,tanggal_bayar,metode_bayar,status,denda,no_referensi) VALUES
(1,'2025-04-02 10:00','Xendit-VA','PAID',0,'REF001'),
(2,'2025-04-03 11:00','Xendit-QRIS','PAID',0,'REF002'),
(3,'2025-04-04 12:00','Xendit-VA','PAID',0,'REF003'),
(4,'2025-04-05 13:00','Xendit-QRIS','PAID',0,'REF004'),
(5,'2025-04-06 14:00','Xendit-VA','PAID',0,'REF005'),
(6,'2025-04-07 15:00','Xendit-QRIS','PAID',0,'REF006'),
(7,'2025-03-02 10:00','Xendit-VA','PAID',0,'REF007'),
(8,'2025-03-03 11:00','Xendit-QRIS','PAID',0,'REF008'),
(9,'2025-03-04 12:00','Xendit-VA','PAID',0,'REF009'),
(10,'2025-03-05 13:00','Xendit-QRIS','PAID',0,'REF010');
