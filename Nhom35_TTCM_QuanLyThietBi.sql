use master
Go

IF DB_ID('QuanLyThietBi_Nhom35') IS NOT NULL
BEGIN
    ALTER DATABASE QuanLyThietBi_Nhom35 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyThietBi_Nhom35;
END
GO

CREATE DATABASE QuanLyThietBi_Nhom35;
GO
USE QuanLyThietBi_Nhom35;
GO

-- =============================================
-- 1. CÁC BẢNG DANH MỤC & CƠ SỞ (Tạo trước)
-- =============================================

CREATE TABLE tbQuyenHan (
    ID_QuyenHan CHAR(5) PRIMARY KEY,
    TenQuyenHan NVARCHAR(50) NOT NULL UNIQUE,
    MoTa NVARCHAR(200) NULL
);
GO

CREATE TABLE tbVaiTro (
    ID_VaiTro CHAR(5) PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE tbKhoa_PhongBan (
    ID_KhoaPhongBan CHAR(3) PRIMARY KEY,
    TenPhongBanKhoa NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE tbCoSo (
    ID_CoSo CHAR(4) PRIMARY KEY,
    TenCoSo NVARCHAR(10) NOT NULL
);
GO

CREATE TABLE tbDanhMuc (
    ID_DanhMuc CHAR(10) PRIMARY KEY,
    TenDanhMuc NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(255) NULL
);
GO

CREATE TABLE tbNhaCungCap (
    ID_NhaCC CHAR(10) PRIMARY KEY,
    TenNhaCC NVARCHAR(100) NOT NULL,
    LoaiDichVu NVARCHAR(50) CHECK (LoaiDichVu IN (N'Cung cấp', N'Sửa chữa', N'Bảo trì', N'Khác')),
    DiaChi NVARCHAR(255) NOT NULL,
    SDT VARCHAR(13) UNIQUE
        CHECK (SDT NOT LIKE '%[^0-9]%')
);
GO

CREATE TABLE tbLoaiYeuCau (
    ID_LoaiYeuCau CHAR(10) PRIMARY KEY,
    TenLoaiYeuCau NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE tbTiet (
    ID_Tiet CHAR(3) PRIMARY KEY,
    GioBD TIME NOT NULL,
    ThoiLuong INT NOT NULL
);
GO

-- =============================================
-- 2. CÁC BẢNG CẤP 2 (Có khóa ngoại)
-- =============================================

CREATE TABLE tbQuyenHan_VaiTro (
    QuyenHanNo CHAR(5),
    VaiTroNo CHAR(5),
    TrangThai BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (QuyenHanNo, VaiTroNo),
    CONSTRAINT FK_QHVT_QuyenHan FOREIGN KEY (QuyenHanNo) REFERENCES tbQuyenHan(ID_QuyenHan) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_QHVT_VaiTro FOREIGN KEY (VaiTroNo) REFERENCES tbVaiTro(ID_VaiTro) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE tbNguoiDung (
    ID_NguoiDung CHAR(6) PRIMARY KEY,
    KhoaPhongBanNo CHAR(3),
    VaiTroNo CHAR(5),
    Email VARCHAR(50) NOT NULL UNIQUE CHECK (Email LIKE '%@%'),
    MatKhau VARCHAR(50) NOT NULL,
    HoTen NVARCHAR(50) NOT NULL,
    NgaySinh DATE CHECK (DATEDIFF(year, NgaySinh, GETDATE()) >= 18),
    TrangThaiTK BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_NguoiDung_Khoa FOREIGN KEY (KhoaPhongBanNo) REFERENCES tbKhoa_PhongBan(ID_KhoaPhongBan) 
        ON DELETE SET NULL ON UPDATE CASCADE,    CONSTRAINT FK_NguoiDung_VaiTro FOREIGN KEY (VaiTroNo) REFERENCES tbVaiTro(ID_VaiTro) 
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

CREATE TABLE tbVaiTro_NguoiDung (
    VaiTroNo CHAR(5),
    NguoiDungNo CHAR(6),
    NgayHieuLuc DATE NOT NULL,
    NgayHetHieuLuc DATE NOT NULL,
    PRIMARY KEY (VaiTroNo, NguoiDungNo),
    CHECK (NgayHetHieuLuc >= NgayHieuLuc),
    CONSTRAINT FK_VTND_VaiTro FOREIGN KEY (VaiTroNo) REFERENCES tbVaiTro(ID_VaiTro) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_VTND_NguoiDung FOREIGN KEY (NguoiDungNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE tbKhuVuc (
    ID_KhuVuc CHAR(4) PRIMARY KEY,
    CoSoNo CHAR(4),
    TenKhuVuc NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_KhuVuc_CoSo FOREIGN KEY (CoSoNo) REFERENCES tbCoSo(ID_CoSo) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE tbThongBao (
    ID_ThongBao CHAR(10) PRIMARY KEY,
    NguoiTaoNo CHAR(6),
    TieuDe NVARCHAR(255) NOT NULL,
    NoiDung NVARCHAR(MAX) NOT NULL,
    NgayTao DATE NOT NULL DEFAULT GETDATE(),
    LoaiThongBao NVARCHAR(50) NOT NULL CHECK (LoaiThongBao IN (N'Hệ thống', N'Cá nhân', N'Nhóm', N'Công khai')),
    PathFileDinhKem VARCHAR(255) NULL,
    CONSTRAINT FK_ThongBao_NguoiTao FOREIGN KEY (NguoiTaoNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

CREATE TABLE tbThongBao_NguoiDung (
    ThongBaoNo CHAR(10),
    NguoiNhanNo CHAR(6),
    TrangThaiDoc BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (ThongBaoNo, NguoiNhanNo),
    CONSTRAINT FK_TBND_ThongBao FOREIGN KEY (ThongBaoNo) REFERENCES tbThongBao(ID_ThongBao) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- Sử dụng NO ACTION cho người nhận để tránh lỗi Multiple Cascade Paths trong SQL Server
    CONSTRAINT FK_TBND_NguoiNhan FOREIGN KEY (NguoiNhanNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

CREATE TABLE tbTaiLieu (
    ID_TaiLieu CHAR(10) PRIMARY KEY,
    DonViQuanLy CHAR(3),
    TenTaiLieu NVARCHAR(255) NOT NULL,
    SoHieu VARCHAR(50) UNIQUE,
    NgayPhatHanh DATE NOT NULL,
    DuongDanFile VARCHAR(255) UNIQUE,
    TrangThaiApDung BIT DEFAULT 1,
    CONSTRAINT FK_TaiLieu_DonVi FOREIGN KEY (DonViQuanLy) REFERENCES tbKhoa_PhongBan(ID_KhoaPhongBan) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- =============================================
-- 3. CÁC BẢNG LIÊN QUAN THIẾT BỊ VÀ PHÒNG
-- =============================================

CREATE TABLE tbPhong (
    ID_Phong CHAR(4) PRIMARY KEY,
    KhuVucNo CHAR(4),
    TenPhong NVARCHAR(50) NOT NULL,
    SucChua INT NOT NULL CHECK (SucChua > 0),
    CONSTRAINT FK_Phong_KhuVuc FOREIGN KEY (KhuVucNo) REFERENCES tbKhuVuc(ID_KhuVuc) 
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

CREATE TABLE tbThietBi (
    ID_ThietBi CHAR(10) PRIMARY KEY,
    DanhMucNo CHAR(10),
    NhaCCNo CHAR(10),
    KhoaPhongBan CHAR(3) NULL,
    TenTB NVARCHAR(100) NOT NULL,
    TrangThaiThietBi NVARCHAR(20) DEFAULT N'Sẵn sàng' CHECK (TrangThaiThietBi IN (N'Sửa chữa', N'Thanh lý', N'Đang sử dụng', N'Hư hỏng', N'Sẵn sàng', N'Đang bàn giao')),
    Gia DECIMAL(12, 2) CHECK (Gia >= 0) NOT NULL,
    ThongSoKT NVARCHAR(100) NOT NULL,
    SoSeri VARCHAR(20) NOT NULL UNIQUE,
    CONSTRAINT FK_ThietBi_DanhMuc FOREIGN KEY (DanhMucNo) REFERENCES tbDanhMuc(ID_DanhMuc) 
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_ThietBi_NhaCC FOREIGN KEY (NhaCCNo) REFERENCES tbNhaCungCap(ID_NhaCC) 
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_ThietBi_Khoa FOREIGN KEY (KhoaPhongBan) REFERENCES tbKhoa_PhongBan(ID_KhoaPhongBan) 
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

CREATE TABLE tbThietBi_NguoiDung (
    ThietBiNo CHAR(10),
    NguoiDungNo CHAR(6),
    TrangThai BIT DEFAULT 1,
    PRIMARY KEY (ThietBiNo, NguoiDungNo),
    CONSTRAINT FK_TBND_ThietBi FOREIGN KEY (ThietBiNo) REFERENCES tbThietBi(ID_ThietBi) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_TBND_User FOREIGN KEY (NguoiDungNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE tbPhong_ThietBi (
    ThietBiNo CHAR(10),
    PhongNo CHAR(4),
    NgayHieuLuc DATE CHECK (NgayHieuLuc >= GETDATE()),
    PRIMARY KEY (ThietBiNo, PhongNo),
    CONSTRAINT FK_PTB_ThietBi FOREIGN KEY (ThietBiNo) REFERENCES tbThietBi(ID_ThietBi) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_PTB_Phong FOREIGN KEY (PhongNo) REFERENCES tbPhong(ID_Phong) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE tbLopHocPhan (
    ID_LHP CHAR(10) PRIMARY KEY,
    PhongNo CHAR(4),
    TietNo CHAR(3),
    SoTC INT NOT NULL,
    Thu NVARCHAR(10) CHECK (Thu IN (N'Thứ 2', N'Thứ 3', N'Thứ 4', N'Thứ 5', N'Thứ 6', N'Thứ 7')),
    SiSo INT NOT NULL CHECK (SiSo > 0),
    TenLHP NVARCHAR(50) NOT NULL,
    HocKy NVARCHAR(20) NOT NULL,
    CONSTRAINT FK_LHP_Phong FOREIGN KEY (PhongNo) REFERENCES tbPhong(ID_Phong) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_LHP_Tiet FOREIGN KEY (TietNo) REFERENCES tbTiet(ID_Tiet) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
Go

-- =============================================
-- 4. HỆ THỐNG YÊU CẦU (Transaction)
-- =============================================

CREATE TABLE tbYeuCau (
    ID_YeuCau CHAR(10) PRIMARY KEY,
    NguoiTaoNo CHAR(6),
    LoaiYeuCauNo CHAR(10),
    TrangThai NVARCHAR(50) CHECK (TrangThai IN (N'Chờ xử lý', N'Đã duyệt', N'Từ chối', N'Đã hủy', N'Hoàn Thành')),
    NgayTao DATE DEFAULT GETDATE(),
    NgayDuKienXL DATE,
    NgayXuLy DATE,
    CHECK (NgayDuKienXL >= NgayTao),
    CHECK (NgayXuLy >= NgayTao),
    CONSTRAINT FK_YeuCau_NguoiTao FOREIGN KEY (NguoiTaoNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_YeuCau_Loai FOREIGN KEY (LoaiYeuCauNo) REFERENCES tbLoaiYeuCau(ID_LoaiYeuCau) 
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

CREATE TABLE tbChiTietYeuCau_Mua (
    ID_ChiTiet CHAR(10) PRIMARY KEY,
    YeuCauNo CHAR(10),
    TenTB NVARCHAR(100) NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    ThongSoKT NVARCHAR(100) NOT NULL,
    GiaDuKien DECIMAL(10, 2) NOT NULL CHECK (GiaDuKien > 0),
    MucDoUuTien NVARCHAR(20) NOT NULL CHECK (MucDoUuTien IN (N'Cao', N'Trung bình', N'Thấp')),
    DonViTinh NVARCHAR(10) NOT NULL CHECK (DonViTinh IN (N'Cái', N'Bộ')),
    LyDo NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_CTMua_YeuCau FOREIGN KEY (YeuCauNo) REFERENCES tbYeuCau(ID_YeuCau) 
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

CREATE TABLE tbChiTietYeuCau_SuaChua (
    YeuCauNo CHAR(10),
    ThietBiNo CHAR(10),
    HinhAnh VARCHAR(255) NULL,
    MoTa NVARCHAR(255) NOT NULL,
    LyDo NVARCHAR(255) NOT NULL,
    PRIMARY KEY (YeuCauNo, ThietBiNo),
    CONSTRAINT FK_CTSua_YeuCau FOREIGN KEY (YeuCauNo) REFERENCES tbYeuCau(ID_YeuCau) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_CTSua_ThietBi FOREIGN KEY (ThietBiNo) REFERENCES tbThietBi(ID_ThietBi) 
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE tbChiTietYeuCauSuDung_NgoaiKhoa (
    ID_ChiTiet CHAR(10) PRIMARY KEY,
    YeuCauNo CHAR(10),
    KhoaPhongBanNo CHAR(3),
    TenTB NVARCHAR(255) NOT NULL,
    ThongSoKT NVARCHAR(255) NOT NULL,
    LyDo NVARCHAR(255) NOT NULL,
    CONSTRAINT FK_CTNgoai_YeuCau FOREIGN KEY (YeuCauNo) REFERENCES tbYeuCau(ID_YeuCau) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_CTNgoai_Khoa FOREIGN KEY (KhoaPhongBanNo) REFERENCES tbKhoa_PhongBan(ID_KhoaPhongBan) 
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

CREATE TABLE tbChiTietYeuCau_SuDung (
    YeuCauNo CHAR(10),
    ThietBiNo CHAR(10),
    TietBDNo CHAR(3),
    TietKTNo CHAR(3),
    LyDoMuon NVARCHAR(255) NOT NULL,
    NgayMuon DATE CHECK (NgayMuon >= GETDATE()),
    PRIMARY KEY (YeuCauNo, ThietBiNo),
    CONSTRAINT FK_CTSuDung_YeuCau FOREIGN KEY (YeuCauNo) REFERENCES tbYeuCau(ID_YeuCau) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_CTSuDung_ThietBi FOREIGN KEY (ThietBiNo) REFERENCES tbThietBi(ID_ThietBi) 
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_CTSuDung_TietBD FOREIGN KEY (TietBDNo) REFERENCES tbTiet(ID_Tiet)
         ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_CTSuDung_TietKT FOREIGN KEY (TietKTNo) REFERENCES tbTiet(ID_Tiet)
         ON DELETE NO ACTION ON UPDATE NO ACTION
);
Go

CREATE TABLE tbChiTietYeuCau_BanGiao (
    YeuCauNo CHAR(10),
    ThietBiNo CHAR(10),
    PhongBanKhoaNo CHAR(3),
    NgayBanGiao DATE NOT NULL,
    NgayNhanThucTe DATE NULL,
    TrangThaiBanGiao NVARCHAR(15) DEFAULT N'Chưa giao',
    NguoiBanGiaoNo CHAR(6),
    NguoiNhanNo CHAR(6),
    GhiChu NVARCHAR(255) NULL,
    PRIMARY KEY (YeuCauNo, ThietBiNo),
        CONSTRAINT FK_CTBanGiao_YeuCau FOREIGN KEY (YeuCauNo) REFERENCES tbYeuCau(ID_YeuCau) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
            CONSTRAINT FK_CTBanGiao_ThietBi FOREIGN KEY (ThietBiNo) REFERENCES tbThietBi(ID_ThietBi) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
        
    CONSTRAINT FK_CTBanGiao_Khoa FOREIGN KEY (PhongBanKhoaNo) REFERENCES tbKhoa_PhongBan(ID_KhoaPhongBan) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
        
    CONSTRAINT FK_CTBanGiao_NguoiGiao FOREIGN KEY (NguoiBanGiaoNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE NO ACTION ON UPDATE NO ACTION,
        
    CONSTRAINT FK_CTBanGiao_NguoiNhan FOREIGN KEY (NguoiNhanNo) REFERENCES tbNguoiDung(ID_NguoiDung) 
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
Go

-- =============================================
-- Tạo sequence cho các bảng
-- =============================================
CREATE SEQUENCE seq_QuyenHan START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_VaiTro START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ThietBi START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_NguoiDung START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_KhoaPhongBan START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_LoaiYeuCau START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_YeuCau START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ChiTietYeuCauSuDungNgoaiKhoa START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ChiTietYeuCauMua START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ThongBao START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_TaiLieu START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_DanhMuc START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_NhaCungCap START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_Tiet START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_Phong START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_KhuVuc START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_CoSo START WITH 1 INCREMENT BY 1;
GO

-- =============================================
-- PROCEDURES
-- =============================================

-- Procedure cho sinh mã tự động cho các bảng
-- Bảng tbQuyenHan
CREATE PROCEDURE pr_SinhMa_QuyenHan
    @MaMoi CHAR(5) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_QuyenHan;

    SET @MaMoi = 'QH' + RIGHT('000' + CAST(@STT AS VARCHAR), 3);
END;
GO

-- Bảng tbVaiTro
CREATE PROCEDURE pr_SinhMa_VaiTro
    @MaMoi CHAR(5) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_VaiTro;

    SET @MaMoi = 'VT' + RIGHT('000' + CAST(@STT AS VARCHAR), 3);
END;
GO

-- Bảng tbThietBi
CREATE PROCEDURE pr_SinhMa_ThietBi
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_ThietBi;

    SET @MaMoi = 'TB' + RIGHT('00000000' + CAST(@STT AS VARCHAR), 8);
END;
GO

-- Bảng tbNguoiDung
CREATE PROCEDURE pr_SinhMa_NguoiDung
    @MaMoi CHAR(6) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_NguoiDung;

    SET @MaMoi = 'ND' + RIGHT('0000' + CAST(@STT AS VARCHAR), 4);
END;
GO

-- Bảng tbKhoa_PhongBan
CREATE PROCEDURE pr_SinhMa_KhoaPhongBan
    @MaMoi CHAR(3) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_KhoaPhongBan;

    SET @MaMoi = 'KP' + RIGHT('0' + CAST(@STT AS VARCHAR), 1);
END;
GO

-- Bảng tbLoaiYeuCau
CREATE PROCEDURE pr_SinhMa_LoaiYeuCau
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_LoaiYeuCau;

    SET @MaMoi = 'LYC' + RIGHT('0000000' + CAST(@STT AS VARCHAR), 7);
END;
GO

-- Bảng tbYeuCau
CREATE PROCEDURE pr_SinhMa_YeuCau
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_YeuCau;

    SET @MaMoi = 'YC' + RIGHT('00000000' + CAST(@STT AS VARCHAR), 8);
END;
GO

-- Bảng tbChiTietYeuCauSuDung_NgoaiKhoa
CREATE PROCEDURE pr_SinhMa_ChiTietYeuCau_SuDung_NgoaiKhoa
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_ChiTietYeuCauSuDungNgoaiKhoa;

    SET @MaMoi = 'CTNK' + RIGHT('000000' + CAST(@STT AS VARCHAR), 6);
END;
GO

-- Bảng tbChiTietYeuCau_Mua
CREATE PROCEDURE pr_SinhMa_ChiTietYeuCau_Mua
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_ChiTietYeuCauMua;

    SET @MaMoi = 'CTM' + RIGHT('0000000' + CAST(@STT AS VARCHAR), 7);
END;
GO

-- Bảng tbThongBao
CREATE PROCEDURE pr_SinhMa_ThongBao
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_ThongBao;

    SET @MaMoi = 'TB' + RIGHT('00000000' + CAST(@STT AS VARCHAR), 8);
END;
GO

-- Bảng tbTaiLieu
CREATE PROCEDURE pr_SinhMa_TaiLieu
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_TaiLieu;

    SET @MaMoi = 'TL' + RIGHT('00000000' + CAST(@STT AS VARCHAR), 8);
END;
GO

-- Bảng tbDanhMuc
CREATE PROCEDURE pr_SinhMa_DanhMuc
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_DanhMuc;

    SET @MaMoi = 'DM' + RIGHT('00000000' + CAST(@STT AS VARCHAR), 8);
END;
GO

-- Bảng tbNhaCungCap
CREATE PROCEDURE pr_SinhMa_NhaCungCap
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_NhaCungCap;

    SET @MaMoi = 'NCC' + RIGHT('0000000' + CAST(@STT AS VARCHAR), 7);
END;
GO

-- Bảng tbTiet
CREATE PROCEDURE pr_SinhMa_Tiet
    @MaMoi CHAR(3) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_Tiet;

    SET @MaMoi = 'T' + RIGHT('00' + CAST(@STT AS VARCHAR), 2);
END;
GO

-- Bảng tbPhong
CREATE PROCEDURE pr_SinhMa_Phong
    @MaMoi CHAR(4) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_Phong;

    SET @MaMoi = 'P' + RIGHT('000' + CAST(@STT AS VARCHAR), 3);
END;
GO

-- Bảng tbKhuVuc
CREATE PROCEDURE pr_SinhMa_KhuVuc
    @MaMoi CHAR(4) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_KhuVuc;

    SET @MaMoi = 'KV' + RIGHT('00' + CAST(@STT AS VARCHAR), 2);
END;
GO

-- Bảng tbCoSo
CREATE PROCEDURE pr_SinhMa_CoSo
    @MaMoi CHAR(4) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_CoSo;

    SET @MaMoi = 'CS' + RIGHT('00' + CAST(@STT AS VARCHAR), 2);
END;
GO

-----------------------------------------------------------------------------------------------------------------------------TRIGGER-----------------------------------------------------------------------------------------------------------------
--1. Trigger sinh mã tự động cho bảng tbQuyenHan
CREATE TRIGGER trg_tbQuyenHan_Insert_SinhMa
ON tbQuyenHan
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(5);
    EXEC pr_SinhMa_QuyenHan @NewID OUTPUT;

    INSERT INTO tbQuyenHan(ID_QuyenHan, TenQuyenHan, MoTa)
    SELECT @NewID, TenQuyenHan, MoTa
    FROM inserted;
END;
GO

--2. Trigger sinh mã tự động cho bảng tbVaiTro
CREATE TRIGGER trg_tbVaiTro_Insert_SinhMa
ON tbVaiTro
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(5);
    EXEC pr_SinhMa_VaiTro @NewID OUTPUT;

    INSERT INTO tbVaiTro(ID_VaiTro, TenVaiTro)
    SELECT @NewID, TenVaiTro
    FROM inserted;
END;
GO

--3. Trigger sinh mã tự động cho bảng tbNguoiDung
CREATE TRIGGER trg_tbNguoiDung_Insert_SinhMa
ON tbNguoiDung
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(6);
    EXEC pr_SinhMa_NguoiDung @NewID OUTPUT;

    INSERT INTO tbNguoiDung(ID_NguoiDung, KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK)
    SELECT @NewID, KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK
    FROM inserted;
END;
GO

--5. Trigger sinh mã tự động cho bảng tbKhoa_PhongBan
CREATE TRIGGER trg_tbKhoaPhongBan_Insert_SinhMa
ON tbKhoa_PhongBan
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_KhoaPhongBan @NewID OUTPUT;

    INSERT INTO tbKhoa_PhongBan(ID_KhoaPhongBan, TenPhongBanKhoa)
    SELECT @NewID, TenPhongBanKhoa
    FROM inserted;
END;
GO

--6. Trigger sinh mã tự động cho bảng tbTaiLieu
CREATE TRIGGER trg_tbTaiLieu_Insert_SinhMa
ON tbTaiLieu
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_TaiLieu @NewID OUTPUT;

    INSERT INTO tbTaiLieu(ID_TaiLieu, DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung)
    SELECT @NewID, DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung
    FROM inserted;
END;
GO

--7. Trigger sinh mã tự động cho bảng tbLoaiYeuCau
CREATE TRIGGER trg_tbLoaiYeuCau_Insert_SinhMa
ON tbLoaiYeuCau
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_LoaiYeuCau @NewID OUTPUT;

    INSERT INTO tbLoaiYeuCau(ID_LoaiYeuCau, TenLoaiYeuCau)
    SELECT @NewID, TenLoaiYeuCau
    FROM inserted;
END;
GO

--8. Trigger sinh mã tự động cho bảng tbThongBao
CREATE TRIGGER trg_tbThongBao_Insert_SinhMa
ON tbThongBao
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_ThongBao @NewID OUTPUT;

    INSERT INTO tbThongBao(ID_ThongBao, TieuDe, LoaiThongBao, NoiDung, NgayTao)
    SELECT @NewID, TieuDe, LoaiThongBao, NoiDung, NgayTao
    FROM inserted;
END;
GO

--9. Trigger sinh mã tự động cho bảng tbDanhMuc
CREATE TRIGGER trg_tbDanhMuc_Insert_SinhMa
ON tbDanhMuc
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_DanhMuc @NewID OUTPUT;

    INSERT INTO tbDanhMuc(ID_DanhMuc, TenDanhMuc, MoTa)
    SELECT @NewID, TenDanhMuc, MoTa
    FROM inserted;
END;
GO

--10. Trigger sinh mã tự động cho bảng tbNhaCungCap
CREATE TRIGGER trg_tbNhaCungCap_Insert_SinhMa
ON tbNhaCungCap
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_NhaCungCap @NewID OUTPUT;

    INSERT INTO tbNhaCungCap(ID_NhaCC, TenNhaCC, LoaiDichVu, DiaChi, SDT)
    SELECT @NewID, TenNhaCC, LoaiDichVu, DiaChi, SDT
    FROM inserted;
END;
GO

--11. Trigger sinh mã tự động cho bảng tbTiet
CREATE TRIGGER trg_tbTiet_Insert_SinhMa
ON tbTiet
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_Tiet @NewID OUTPUT;

    INSERT INTO tbTiet(ID_Tiet, GioBD, ThoiLuong)
    SELECT @NewID, GioBD, ThoiLuong
    FROM inserted;
END;
GO

--12. Trigger sinh mã tự động cho bảng tbPhong
CREATE TRIGGER trg_tbPhong_Insert_SinhMa
ON tbPhong
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(4);
    EXEC pr_SinhMa_Phong @NewID OUTPUT;

    INSERT INTO tbPhong(ID_Phong, KhuVucNo, TenPhong, SucChua)
    SELECT @NewID, KhuVucNo, TenPhong, SucChua
    FROM inserted;
END;
GO

--13. Trigger sinh mã tự động cho bảng tbKhuVuc
CREATE TRIGGER trg_tbKhuVuc_Insert_SinhMa
ON tbKhuVuc
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(4);
    EXEC pr_SinhMa_KhuVuc @NewID OUTPUT;

    INSERT INTO tbKhuVuc(ID_KhuVuc, CoSoNo, TenKhuVuc)
    SELECT @NewID, CoSoNo, TenKhuVuc
    FROM inserted;
END;
GO

--14. Trigger sinh mã tự động cho bảng tbCoSo
CREATE TRIGGER trg_tbCoSo_Insert_SinhMa
ON tbCoSo
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_CoSo @NewID OUTPUT;

    INSERT INTO tbCoSo(ID_CoSo, TenCoSo)
    SELECT @NewID, TenCoSo
    FROM inserted;
END;
GO

--15. Trigger sinh mã tự động cho bảng tbChiTietYeuCau_Mua
CREATE TRIGGER trg_tbChiTietMua_Insert_SinhMa
ON tbChiTietYeuCau_Mua
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_ChiTietYeuCau_Mua @NewID OUTPUT;

    INSERT INTO tbChiTietYeuCau_Mua(ID_ChiTiet, YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo)
    SELECT @NewID, YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo
    FROM inserted;
END;
GO

--16. Trigger sinh mã tự động cho bảng tbChiTietYeuCauSuDung_NgoaiKhoa
CREATE TRIGGER trg_tbChiTietNgoaiKhoa_Insert_SinhMa
ON tbChiTietYeuCauSuDung_NgoaiKhoa
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_ChiTietYeuCau_SuDung_NgoaiKhoa @NewID OUTPUT;

    INSERT INTO tbChiTietYeuCauSuDung_NgoaiKhoa(ID_ChiTiet, YeuCauNo, KhoaPhongBanNo, TenTB, ThongSoKT, LyDo)
    SELECT @NewID, YeuCauNo, KhoaPhongBanNo, TenTB, ThongSoKT, LyDo
    FROM inserted;
END;
GO

--17. Trigger tự động cập nhật ngày tạo và insert tbThongBao_NguoiDung khi thêm thông báo
CREATE TRIGGER trg_tbThongBao_Insert_ThongBaoNguoiDung
On tbThongBao
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tbThongBao_NguoiDung(ThongBaoNo, NguoiNhanNo)
    SELECT i.ID_ThongBao, nd.ID_NguoiDung
    FROM inserted i
    CROSS JOIN tbNguoiDung nd
    WHERE i.LoaiThongBao = N'Công khai';
END;
GO

--18. Trigger chặn xóa thiết bị, thay trạng thái thành 'Đã thanh lý'
CREATE TRIGGER trg_tbThietBi_NganXoaThietBi
ON tbThietBi
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    PRINT N'Bạn không thể xoá thông tin thiết bị, thiết bị sẽ được chuyển về trạng thái thanh lý để bảo toàn dữ liệu'
    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Thanh lý'
    FROM tbThietBi t
    INNER JOIN deleted d ON t.ID_ThietBi = d.ID_ThietBi;
END;
GO

--19. Trigger cập nhật thông tin khi bàn giao
CREATE TRIGGER trg_ChiTietBanGiao_DaBanGiao
ON tbChiTietYeuCau_BanGiao
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThaiBanGiao)
    BEGIN
        UPDATE tb
        SET tb.TrangThaiThietBi = N'Sẵn sàng'
        FROM tbThietBi tb 
        INNER JOIN inserted i ON tb.ID_ThietBi = i.ThietBiNo
        WHERE i.TrangThaiBanGiao = N'Đã giao';

        -- Cập nhật ngày nhận thực tế
        UPDATE tbChiTietYeuCau_BanGiao
        SET NgayNhanThucTe = GETDATE(),
            GhiChu = CASE 
                        WHEN GETDATE() > i.NgayBanGiao 
                        THEN N'Bàn giao không đúng thời hạn'
                        ELSE N'Bàn giao đúng thời hạn'
                    END
        FROM tbChiTietYeuCau_BanGiao ct
        INNER JOIN inserted i ON ct.YeuCauNo = i.YeuCauNo AND ct.ThietBiNo = i.ThietBiNo
        INNER JOIN deleted d ON ct.YeuCauNo = d.YeuCauNo AND ct.ThietBiNo = d.ThietBiNo
        WHERE i.TrangThaiBanGiao = N'Đã giao'

        DECLARE @KQ NVARCHAR(100) = (SELECT CASE WHEN GETDATE() > NgayBanGiao THEN N'Bàn giao trễ thời hạn!' ELSE N'Bàn giao đúng thời hạn!' END FROM inserted);
        PRINT @KQ;
    END
END;
GO

--20. Trigger cập nhật trạng thái thiết bị 'Hư hỏng' khi có báo cáo sửa chữa thiết bị
CREATE TRIGGER trg_tbChiTietSuaChua_Insert_UpdateTB
ON tbChiTietYeuCau_SuaChua
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tb
    SET tb.TrangThaiThietBi = N'Hư hỏng'
    FROM tbThietBi tb
    INNER JOIN inserted i ON tb.ID_ThietBi = i.ThietBiNo;
END;
GO

--21. Trigger khi update tbYeuCau (trạng thái) => cập nhật trạng thái thiết bị
CREATE TRIGGER trg_tbYeuCau_CapNhatTrangThaiTB
ON tbYeuCau
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Khi duyệt yêu cầu sửa chữa
    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Sửa chữa'
    FROM tbThietBi tb
    JOIN tbChiTietYeuCau_SuaChua ct ON tb.ID_ThietBi = ct.ThietBiNo
    JOIN inserted i ON ct.YeuCauNo = i.ID_YeuCau
    JOIN deleted d ON i.ID_YeuCau = d.ID_YeuCau
    WHERE i.LoaiYeuCauNo = 'LYC0000003' AND d.TrangThai = N'Chờ xử lý' AND i.TrangThai = N'Đã duyệt';

    -- 2. Khi hoàn thành yêu cầu sửa chữa
    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Sẵn sàng'
    FROM tbThietBi tb
    JOIN tbChiTietYeuCau_SuaChua ct ON tb.ID_ThietBi = ct.ThietBiNo
    JOIN inserted i ON ct.YeuCauNo = i.ID_YeuCau
    WHERE i.LoaiYeuCauNo = 'LYC0000003' AND i.TrangThai = N'Hoàn Thành';
END;
GO

--22. Trigger tạo thông báo tự động khi cập nhật trạng thái yêu cầu
CREATE TRIGGER trg_YeuCau_ThongBaoHeThong
ON tbYeuCau
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tbThongBao (NguoiTaoNo, TieuDe, NoiDung, NgayTao, LoaiThongBao)
    SELECT
        NULL,
        N'Thông báo xử lý yêu cầu',
        CASE
            WHEN i.TrangThai = N'Đã duyệt' THEN lyc.TenLoaiYeuCau + i.ID_YeuCau + N' đã được duyệt'
            WHEN i.TrangThai = N'Từ chối' THEN lyc.TenLoaiYeuCau + i.ID_YeuCau + N' đã bị từ chối'
            WHEN i.TrangThai = N'Hoàn Thành' THEN lyc.TenLoaiYeuCau + i.ID_YeuCau + N' đã hoàn thành'
            ELSE N'Yêu cầu ' + i.ID_YeuCau + N' trạng thái thay đổi'
        END,
        GETDATE(),
        N'Hệ thống'
    FROM inserted i
    INNER JOIN deleted d ON i.ID_YeuCau = d.ID_YeuCau
    INNER JOIN tbLoaiYeuCau lyc ON i.LoaiYeuCauNo = lyc.ID_LoaiYeuCau
    WHERE d.TrangThai IN (N'Chờ xử lý', N'Đã duyệt') AND i.TrangThai IN (N'Đã duyệt', N'Từ chối', N'Hoàn Thành');

    INSERT INTO tbThongBao_NguoiDung (ThongBaoNo, NguoiNhanNo, TrangThaiDoc)
    SELECT TOP 1 tb.ID_ThongBao, i.NguoiTaoNo, 0
    FROM inserted i
    CROSS APPLY (
        SELECT TOP 1 ID_ThongBao
        FROM tbThongBao
        WHERE NoiDung LIKE '%' + i.ID_YeuCau + '%' AND LoaiThongBao = N'Hệ thống'
        ORDER BY ID_ThongBao DESC
    ) tb
    WHERE i.NguoiTaoNo IS NOT NULL;
END
GO
    
--23. Trigger kiểm tra trùng lịch mượn khi INSERT vào tbChiTietYeuCau_SuDung
CREATE TRIGGER trg_ChiTietSuDung_Insert_KiemTraTrung
ON tbChiTietYeuCau_SuDung
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Kiểm tra trùng: cùng thiết bị, cùng ngày, có tiết giao nhau
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN tbChiTietYeuCau_SuDung ct ON i.ThietBiNo = ct.ThietBiNo AND i.NgayMuon = ct.NgayMuon
        INNER JOIN tbYeuCau yc ON ct.YeuCauNo = yc.ID_YeuCau
        WHERE yc.TrangThai = N'Đã duyệt' AND ((i.TietBDNo <= ct.TietKTNo) AND (i.TietKTNo >= ct.TietBDNo))
    )
    BEGIN
        RAISERROR(N'Thiết bị đã được mượn trong khoảng thời gian này. Vui lòng chọn thời gian khác.', 16, 1);
        RETURN;
    END

    -- Nếu không trùng thì cho phép insert
    INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon)
    SELECT YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon
    FROM inserted;
END;
GO

--24. Trigger khi cập nhật trạng thái "Đã huỷ" cho yêu cầu thì phải kiểm tra xem nếu yêu cầu đó còn ở trạng thái "Chờ xử lý" thì mới cho huỷ.
GO
CREATE TRIGGER trg_tbYeuCau_HuyYeuCau
ON tbYeuCau
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.ID_YeuCau = d.ID_YeuCau 
               WHERE i.TrangThai = N'Đã hủy' AND d.TrangThai <> N'Đã hủy')
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM inserted i 
            JOIN deleted d ON i.ID_YeuCau = d.ID_YeuCau
            WHERE i.TrangThai = N'Đã hủy' AND d.TrangThai <> N'Chờ xử lý'
        )
        BEGIN
            RAISERROR(N'Yêu cầu đã được xét duyệt hoặc xử lý. Bạn không thể hủy yêu cầu này!', 16, 1);
            RETURN;
        END

        UPDATE tbThietBi
        SET TrangThaiThietBi = N'Sẵn sàng'
        FROM tbThietBi tb
        INNER JOIN tbChiTietYeuCau_SuaChua ct ON tb.ID_ThietBi = ct.ThietBiNo
        INNER JOIN inserted i ON ct.YeuCauNo = i.ID_YeuCau
        WHERE i.LoaiYeuCauNo = 'LYC0000003' AND i.TrangThai = N'Đã hủy';
        PRINT N'Yêu cầu đã được huỷ thành công'
    END
END;
GO

--25. Trigger kiểm tra tình trạng thiết bị trước khi thanh lý (nếu thiết bị ơr trạng thái sửa chữa/có lịch được sử dụng trong tương lại/hiện tại đã được duyệt) thì không được thanh lý
GO
CREATE TRIGGER trg_tbThietBi_CheckThanhLy
ON tbThietBi
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThaiThietBi)
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM inserted i
            LEFT JOIN tbChiTietYeuCau_SuDung ct ON i.ID_ThietBi = ct.ThietBiNo
            LEFT JOIN tbYeuCau y ON ct.YeuCauNo = y.ID_YeuCau
            WHERE i.TrangThaiThietBi = N'Thanh lý' AND ( i.TrangThaiThietBi IN (N'Đang sử dụng', N'Sửa chữa') OR ( y.TrangThai = N'Đã duyệt' AND ct.NgayMuon >= CAST(GETDATE() AS DATE)))
        )
        BEGIN
            RAISERROR(N'Không thể thanh lý thiết bị vì đang có lịch mượn đã duyệt hoặc máy đang trong quá trình sử dụng/sửa chữa!', 16, 1);
            RETURN;
        END
    END
END;
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1. Hàm thống kê số lượng thiết bị theo trạng thái thiết bị
GO
CREATE FUNCTION fn_ThongKeThietBi_TatCaTrangThai()
RETURNS TABLE
AS
RETURN (
    SELECT TrangThaiThietBi, COUNT(*) AS SoLuong, CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM tbThietBi) AS DECIMAL(5,2)) AS TyLePhanTram
    FROM tbThietBi
    GROUP BY TrangThaiThietBi
);
GO
SELECT * FROM dbo.fn_ThongKeThietBi_TatCaTrangThai();

--2. Hàm thống kê số lượng thiết bị theo trạng thái cho từng khoa
GO
CREATE FUNCTION fn_ThongKeTrangThaiThietBi_TheoKhoa (@MaKhoa CHAR(3))
RETURNS TABLE
AS
RETURN (
    SELECT TrangThaiThietBi, COUNT(*) AS SoLuong
    FROM tbThietBi
    WHERE KhoaPhongBan = @MaKhoa
    GROUP BY TrangThaiThietBi
);
GO

--3. Hàm kiểm tra quyền hạn của người dùng
GO
CREATE FUNCTION fn_CheckQuyenNguoiDung (
    @NguoiDungNo CHAR(6),
    @TenQuyenHan NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0;
    
    IF EXISTS (
        SELECT 1
        FROM tbQuyenHan_VaiTro qhvt
        INNER JOIN tbQuyenHan qh ON qhvt.QuyenHanNo = qh.ID_QuyenHan
        INNER JOIN tbVaiTro_NguoiDung vtnd ON qhvt.VaiTroNo = vtnd.VaiTroNo
        WHERE vtnd.NguoiDungNo = @NguoiDungNo AND qh.TenQuyenHan = @TenQuyenHan AND qhvt.TrangThai = 1 AND GETDATE() BETWEEN vtnd.NgayHieuLuc AND vtnd.NgayHetHieuLuc
    )
    BEGIN
        SET @Result = 1;
    END
    
    RETURN @Result;
END;
GO

--4. Hàm tính tổng giá trị thiết bị của khoa
CREATE FUNCTION fn_TinhTongGiaTriThietBiKhoa (
    @KhoaPhongBanNo CHAR(3)
)
RETURNS DECIMAL(15, 2)
AS
BEGIN
    DECLARE @TongGiaTri DECIMAL(15, 2);
    
    SELECT @TongGiaTri = SUM(Gia)
    FROM tbThietBi
    WHERE KhoaPhongBan = @KhoaPhongBanNo
        AND TrangThaiThietBi NOT IN (N'Đã thanh lý');
    
    RETURN ISNULL(@TongGiaTri, 0);
END;
GO

--5. Hàm đếm loại yêu cầu theo trạng thái và loại yêu cầu
GO
CREATE FUNCTION fn_PhanTichYeuCauTheoTrangThai (
    @TrangThai NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN (
    SELECT l.TenLoaiYeuCau, COUNT(y.ID_YeuCau) AS SoLuong, FORMAT(CAST(COUNT(y.ID_YeuCau) AS FLOAT) / NULLIF((SELECT COUNT(*) FROM tbYeuCau WHERE TrangThai = @TrangThai), 0), 'P') AS TyLeTrongTrangThai
    FROM tbLoaiYeuCau l
    LEFT JOIN tbYeuCau y ON l.ID_LoaiYeuCau = y.LoaiYeuCauNo AND y.TrangThai = @TrangThai
    GROUP BY l.TenLoaiYeuCau
);
GO

--6. Hàm thống kê số lượng thiết bị theo nhà cung cấp
CREATE FUNCTION fn_ThongKeThietBiTheoNhaCC (
    @KhoaPhongBanNo CHAR(3)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ncc.TenNhaCC,
        COUNT(tb.ID_ThietBi) AS SoLuongThietBi,
        SUM(tb.Gia) AS TongGiaTri
    FROM tbThietBi tb
    INNER JOIN tbNhaCungCap ncc ON tb.NhaCCNo = ncc.ID_NhaCC
    WHERE tb.KhoaPhongBan = @KhoaPhongBanNo
    GROUP BY ncc.TenNhaCC
);
GO

--7. Thủ tục thống kế yêu cầu theo các tháng trong năm (được truyền vào)
CREATE PROCEDURE pr_ThongKeYeuCauTheoThang
    @Nam INT
AS
BEGIN
    SELECT MONTH(NgayTao) AS Thang, l.TenLoaiYeuCau, COUNT(y.ID_YeuCau) AS TongSoYeuCau, SUM(CASE WHEN y.TrangThai = N'Đã duyệt' THEN 1 ELSE 0 END) AS SoLuongDaDuyet
    FROM tbYeuCau y
    JOIN tbLoaiYeuCau l ON y.LoaiYeuCauNo = l.ID_LoaiYeuCau
    WHERE YEAR(NgayTao) = @Nam
    GROUP BY MONTH(NgayTao), l.TenLoaiYeuCau
    ORDER BY Thang;
END;
GO

--8. Thủ tục thống kê tổng giá trị của mỗi khoa trong trường
CREATE PROCEDURE pr_BaoCaoGiaTriTaiSanTheoKhoa
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ID_KhoaPhongBan, TenPhongBanKhoa, dbo.fn_TinhTongGiaTriThietBiKhoa(ID_KhoaPhongBan) AS TongGiaTriHienCo, (SELECT COUNT(*) FROM tbThietBi WHERE KhoaPhongBan = ID_KhoaPhongBan AND TrangThaiThietBi <> N'Đã thanh lý') AS SoLuongThietBi
    FROM tbKhoa_PhongBan
    ORDER BY TongGiaTriHienCo DESC;
END;
GO

--9. Thủ tục tự động đề xuất lịch bảo trì dự phòng
GO
CREATE PROCEDURE pr_DeXuatBaoTriDuPhong
AS
BEGIN
    SELECT tb.ID_ThietBi, tb.TenTB, SUM(t.ThoiLuong) AS TongPhutDaSuDung, N'Cần bảo trì' AS TrangThaiDuKien
    FROM tbThietBi tb
    JOIN tbChiTietYeuCau_SuDung ct ON tb.ID_ThietBi = ct.ThietBiNo
    JOIN tbTiet t ON ct.TietBDNo = t.ID_Tiet
    GROUP BY tb.ID_ThietBi, tb.TenTB
    HAVING SUM(t.ThoiLuong) > 7776000 -- Ngưỡng phút 
END;
GO

--10. Hàm truy vấn lịch sử dụng của Thiết bị
CREATE FUNCTION fn_XemLichDungThietBi(@MaTB CHAR(10))
RETURNS TABLE
AS
RETURN (
    -- 1. Lấy lịch mượn thiết bị từ các yêu cầu đã được duyệt
    SELECT FORMAT(ct.NgayMuon, 'dd/MM/yyyy') AS Ngay_Hoac_Thu, N'Lịch mượn sử dụng' AS LoaiLich, ct.TietBDNo AS TietBatDau, ct.TietKTNo AS TietKetThuc
    FROM tbChiTietYeuCau_SuDung ct
    JOIN tbYeuCau y ON ct.YeuCauNo = y.ID_YeuCau
    WHERE ct.ThietBiNo = @MaTB AND y.TrangThai = N'Đã duyệt'

    UNION ALL

    -- 2. Lấy lịch cố định của thiết bị nếu thiết bị đó được gán vào phòng có lớp học
    SELECT lhp.Thu AS Ngay_Hoac_Thu, N'Lịch học cố định' AS LoaiLich,lhp.TietNo AS TietBatDau, 'T' + RIGHT('0' + CAST(CAST(RIGHT(lhp.TietNo, 2) AS INT) + lhp.SoTC - 1 AS VARCHAR(2)), 2) AS TietKetThuc
    FROM tbLopHocPhan lhp
    JOIN tbPhong_ThietBi ptb ON lhp.PhongNo = ptb.PhongNo
    WHERE ptb.ThietBiNo = @MaTB
);
GO

-- 11. Khi thêm thiết bị → phải kiểm tra DanhMucNo, Nhà cung cấp, Khoa/Phòng ban có tồn tại & hợp lệ
CREATE TRIGGER trg_tbThietBi_CheckBeforeInsert
ON tbThietBi
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra danh mục
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN tbDanhMuc dm ON i.DanhMucNo = dm.ID_DanhMuc WHERE dm.ID_DanhMuc IS NULL)
    BEGIN
        RAISERROR(N'Danh mục thiết bị không tồn tại trong hệ thống!', 16, 1);
        RETURN;
    END

    -- Kiểm tra nhà cung cấp
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN tbNhaCungCap ncc ON i.NhaCCNo = ncc.ID_NhaCC WHERE ncc.ID_NhaCC IS NULL)
    BEGIN
        RAISERROR(N'Nhà cung cấp không tồn tại trong hệ thống!', 16, 1);
        RETURN;
    END

    -- Kiểm tra khoa/phòng ban
    IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN tbKhoa_PhongBan kp ON i.KhoaPhongBan = kp.ID_KhoaPhongBan WHERE i.KhoaPhongBan IS NOT NULL AND kp.ID_KhoaPhongBan IS NULL)
    BEGIN
        RAISERROR(N'Khoa / Phòng ban không tồn tại!', 16, 1);
        RETURN;
    END

    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_ThietBi @NewID OUTPUT;

    INSERT INTO tbThietBi (ID_ThietBi, DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri)
    SELECT @NewID, DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, ISNULL(TrangThaiThietBi, N'Sẵn sàng'), Gia, ThongSoKT, SoSeri
    FROM inserted;
END;
GO

-- 12. Khi thêm yêu cầu → phải kiểm tra NguoiTaoNo, Nhà cung cấp, Khoa/Phòng ban có tồn tại & hợp lệ
CREATE TRIGGER trg_tbYeuCau_CheckBeforeInsert
ON tbYeuCau
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- KIỂM TRA 1: Người tạo (NguoiTaoNo)
    IF EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN tbNguoiDung nd ON i.NguoiTaoNo = nd.ID_NguoiDung 
        WHERE nd.ID_NguoiDung IS NULL
    )
    BEGIN
        PRINT N'Người tạo yêu cầu không tồn tại trong hệ thống!';
        RETURN;
    END

    -- KIỂM TRA 2: Loại yêu cầu (LoaiYeuCauNo)
    IF EXISTS (
        SELECT 1 FROM inserted i 
        LEFT JOIN tbLoaiYeuCau lyc ON i.LoaiYeuCauNo = lyc.ID_LoaiYeuCau 
        WHERE lyc.ID_LoaiYeuCau IS NULL
    )
    BEGIN
        PRINT N'Loại yêu cầu không hợp lệ!';
        RETURN; 
    END

    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_YeuCau @NewID OUTPUT;

    INSERT INTO tbYeuCau (ID_YeuCau, NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy)
    SELECT @NewID, NguoiTaoNo, LoaiYeuCauNo, ISNULL(TrangThai, N'Chờ xử lý'), ISNULL(NgayTao, GETDATE()), NgayDuKienXL, NgayXuLy
    FROM inserted;
END;
GO

-- tbQuyenHan (QH001 -> QH007)
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Xem', N'Chỉ được xem dữ liệu');
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Thêm', N'Được phép thêm mới');
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Sửa', N'Được phép chỉnh sửa');
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Xóa', N'Được phép xóa dữ liệu');
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Duyệt', N'Quyền phê duyệt yêu cầu');
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Báo cáo', N'Xuất các báo cáo thống kê');
INSERT INTO tbQuyenHan (TenQuyenHan, MoTa) VALUES (N'Quản trị', N'Toàn quyền hệ thống');

-- tbVaiTro (VT001 -> VT007)
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Admin');
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Ban Giám Hiệu');
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Trưởng Khoa');
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Phòng CSVC');
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Phòng KHTC');
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Giảng viên');
INSERT INTO tbVaiTro (TenVaiTro) VALUES (N'Sinh viên');

-- tbKhoa_PhongBan (KP1 -> KP7)
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Khoa Công nghệ số');
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Khoa Cơ khí');
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Khoa Điện - Điện tử');
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Khoa KT Xây dựng');
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Khoa Sư phạm Công nghiệp');
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Phòng Cơ sở vật chất');
INSERT INTO tbKhoa_PhongBan (TenPhongBanKhoa) VALUES (N'Phòng Kế hoạch Tài chính');

-- tbCoSo (CS01 -> CS02)
INSERT INTO tbCoSo (TenCoSo) VALUES (N'Cơ sở 1');
INSERT INTO tbCoSo (TenCoSo) VALUES (N'Cơ sở 2');

-- tbDanhMuc (DM00000001 -> DM00000007)
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Thiết bị CNTT', N'Máy tính bàn, Laptop, Server, Workstation');
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Thiết bị Trình chiếu', N'Máy chiếu, Màn hình tương tác, Tivi');
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Thiết bị Mạng & Viễn thông', N'Router, Switch, Access Point, Tổng đài');
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Thiết bị Đo lường & Thí nghiệm', N'Dao động ký, Đồng hồ vạn năng, Nguồn DC');
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Máy Công cụ & Cơ khí', N'Máy phay CNC, Máy tiện, Máy hàn, Robot tay máy');
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Kit & Bo mạch nhúng', N'Kit FPGA, Raspberry Pi, Arduino, PLC');
INSERT INTO tbDanhMuc (TenDanhMuc, MoTa) VALUES (N'Thiết bị Âm thanh', N'Loa hội trường, Micro, Amply, Mixer');
GO

-- tbNhaCungCap (NCC0000001 -> NCC0000007)
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'FPT Trading', N'Cung cấp', N'KCN Đà Nẵng', '0905111222');
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'Phong Vũ', N'Cung cấp', N'Lê Duẩn, ĐN', '0905333444');
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'Điện máy Xanh', N'Bảo trì', N'Nguyễn Văn Linh, ĐN', '18001061');
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'Cơ khí Hòa Phát', N'Cung cấp', N'Hòa Khánh, ĐN', '0914555666');
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'Daikin Service', N'Sửa chữa', N'Hải Châu, ĐN', '18006777');
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'Thiết bị GD Sao Mai', N'Cung cấp', N'Thanh Khê, ĐN', '0935888999');
INSERT INTO tbNhaCungCap (TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES (N'Viettel IDC', N'Khác', N'Hòa Cường, ĐN', '0969000111');

-- tbLoaiYeuCau (không có trigger, dùng ID tường minh)
INSERT INTO tbLoaiYeuCau (TenLoaiYeuCau) VALUES (N'Yêu cầu sử dụng thiết bị');
INSERT INTO tbLoaiYeuCau (TenLoaiYeuCau) VALUES (N'Yêu cầu sử dụng thiết bị ngoài khoa');
INSERT INTO tbLoaiYeuCau (TenLoaiYeuCau) VALUES (N'Yêu cầu Sửa chữa');
INSERT INTO tbLoaiYeuCau (TenLoaiYeuCau) VALUES (N'Yêu cầu mua sắm thiết bị');
INSERT INTO tbLoaiYeuCau (TenLoaiYeuCau) VALUES (N'Yêu cầu bàn giao');

-- tbTiet (T01 -> T14)
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('07:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('08:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('09:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('10:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('11:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('12:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('13:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('14:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('15:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('16:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('17:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('18:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('19:00:00', 60);
INSERT INTO tbTiet (GioBD, ThoiLuong) VALUES ('20:00:00', 60);

-- Admin (VT001) có toàn quyền, Sinh viên (VT007) chỉ được Xem
INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES ('QH001', 'VT001', 1); -- Admin được Xem
INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES ('QH002', 'VT001', 1); -- Admin được Thêm
INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES ('QH004', 'VT001', 1); -- Admin được Xóa
INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES ('QH007', 'VT001', 1); -- Admin Toàn quyền
INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES ('QH001', 'VT007', 1); -- Sinh viên được Xem

-- tbKhuVuc (KV01 -> KV07) - Trigger tự sinh mã
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS01', N'Khu A');
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS01', N'Khu B');
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS01', N'Khu C');
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS01', N'Khu D (Xưởng)');
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS02', N'Khu A');
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS02', N'Khu B');
INSERT INTO tbKhuVuc (CoSoNo, TenKhuVuc) VALUES ('CS02', N'Hội Trường');

-- tbNguoiDung (ND0001 -> ND0007) - Trigger tự sinh mã
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP6', 'VT001', 'admin@ute.udn.vn', '123', N'Nguyễn Quản Trị', '1990-01-01', 1);
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP1', 'VT003', 'truongkhoa.cntt@ute.udn.vn', '123', N'Trần Văn Trưởng', '1980-05-15', 1);
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP1', 'VT006', 'gv.cntt01@ute.udn.vn', '123', N'Lê Thị Giảng Viên', '1992-08-20', 1);
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP2', 'VT006', 'gv.cokhi01@ute.udn.vn', '123', N'Phạm Kỹ Thuật', '1985-03-10', 1);
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP1', 'VT007', 'sv.cntt01@ute.udn.vn', '123', N'Hoàng Sinh Viên', '2003-11-25', 1);
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP6', 'VT004', 'nv.csvc@ute.udn.vn', '123', N'Đỗ Cơ Sở', '1995-07-07', 1);
INSERT INTO tbNguoiDung (KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES ('KP7', 'VT005', 'nv.khtc@ute.udn.vn', '123', N'Vũ Tài Chính', '1993-12-12', 1);

-- Ghi nhận thời gian hiệu lực của vai trò người dùng
INSERT INTO tbVaiTro_NguoiDung (VaiTroNo, NguoiDungNo, NgayHieuLuc, NgayHetHieuLuc) VALUES ('VT001', 'ND0001', '2023-01-01', '2030-01-01'); -- Admin
INSERT INTO tbVaiTro_NguoiDung (VaiTroNo, NguoiDungNo, NgayHieuLuc, NgayHetHieuLuc) VALUES ('VT003', 'ND0002', '2023-05-01', '2028-05-01'); -- Trưởng khoa
INSERT INTO tbVaiTro_NguoiDung (VaiTroNo, NguoiDungNo, NgayHieuLuc, NgayHetHieuLuc) VALUES ('VT007', 'ND0005', '2023-09-01', '2027-09-01'); -- Sinh viên

-- tbThongBao (TB00000001 -> TB00000002)
INSERT INTO tbThongBao (NguoiTaoNo, TieuDe, NoiDung, LoaiThongBao) VALUES ('ND0001', N'Lịch bảo trì hệ thống', N'Hệ thống sẽ bảo trì vào chủ nhật tuần này.', N'Hệ thống');
INSERT INTO tbThongBao (NguoiTaoNo, TieuDe, NoiDung, LoaiThongBao) VALUES ('ND0002', N'Nhắc nhở nộp báo cáo', N'Các giảng viên nộp báo cáo kiểm kê trước ngày 30.', N'Công khai');

-- tbTaiLieu (TL00000001 -> TL00000007) - Trigger tự sinh mã
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP7', N'Quy định sử dụng tài sản công', '01/QD-CSVC', '2023-01-01', '/files/quydinh_tsc.pdf', 1);
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP7', N'Định mức chi tiêu mua sắm', '05/QD-KHTC', '2023-02-15', '/files/dinhmuc_2023.pdf', 1);
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP7', N'Biểu mẫu đề nghị sửa chữa', 'BM-03', '2022-06-01', '/files/bm_suachua.docx', 1);
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP1', N'Nội quy phòng máy tính', 'NQ-CNTT', '2023-08-20', '/files/noiquy_lab.pdf', 1);
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP6', N'Biểu mẫu bàn giao thiết bị', 'BM-05', '2022-06-01', '/files/bm_bangiao.docx', 1);
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP2', N'Hướng dẫn an toàn xưởng', 'HD-CK', '2023-01-10', '/files/hd_antoan.pdf', 1);
INSERT INTO tbTaiLieu (DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES ('KP7', N'Quy trình thanh lý tài sản', 'QT-TL', '2023-12-01', '/files/qt_thanhly.pdf', 1);
GO

-- tbPhong (P001 -> P007) - Trigger tự sinh mã
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV01', N'Phòng học lý thuyết A101', 60);
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV01', N'Phòng học lý thuyết A102', 60);
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV02', N'Phòng máy 1', 40);
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV02', N'Phòng máy 2', 40);
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV03', N'Hội trường C', 200);
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV04', N'Xưởng thực hành CNC', 30);
INSERT INTO tbPhong (KhuVucNo, TenPhong, SucChua) VALUES ('KV05', N'Phòng Lab Cơ bản', 50);

-- Lớp thực hành CSDL học tại phòng P001 vào tiết 1 thứ 2
INSERT INTO tbLopHocPhan (ID_LHP, PhongNo, TietNo, SoTC, Thu, SiSo, TenLHP, HocKy) VALUES ('LHP01', 'P003', 'T01', 3,N'Thứ 2', 40, N'Thực hành CSDL', N'1/2025-2026');
INSERT INTO tbLopHocPhan (ID_LHP, PhongNo, TietNo, SoTC, Thu, SiSo, TenLHP, HocKy) VALUES ('LHP03', 'P003', 'T07', 2,N'Thứ 3', 40, N'Công nghệ phần mềm', N'1/2025-2026');
INSERT INTO tbLopHocPhan (ID_LHP, PhongNo, TietNo, SoTC,Thu, SiSo, TenLHP, HocKy) VALUES ('LHP02', 'P006', 'T06', 3,N'Thứ 3', 30, N'Thực tập CNC', N'1/2025-2026');

-- tbThietBi (TB00000001 -> TB00000007) - Trigger tự sinh mã
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000001', 'KP1', N'PC Dell Optiplex 7090', N'Sẵn sàng', 15000000, N'Core i7-12700, RAM 16GB, SSD 512GB', 'SN-DELL-001');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000001', 'KP1', N'Workstation HP Z4', N'Đang sử dụng', 45000000, N'Xeon W-2223, RAM 32GB, Quadro P2200', 'SN-HP-WORK-01');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000002', 'NCC0000002', 'KP1', N'Máy chiếu Panasonic PT-LB', N'Đang bàn giao', 18000000, N'4100 Ansi Lumens, XGA, HDMI', 'SN-PANA-99');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000005', 'NCC0000004', 'KP2', N'Máy phay CNC Mini', N'Hư hỏng', 120000000, N'Hành trình 300x400mm, Trục chính 24000rpm', 'SN-CNC-X1');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000005', 'NCC0000004', 'KP2', N'Máy hàn TIG Jasic', N'Sẵn sàng', 8500000, N'200A, Hàn inox/sắt', 'SN-HAN-JS01');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000004', 'NCC0000001', 'KP3', N'Dao động ký Tektronix', N'Sửa chữa', 12500000, N'100MHz, 2 Kênh, Digital Storage', 'SN-TEK-105');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000006', 'NCC0000001', 'KP3', N'Bộ thực hành PLC Mitsubishi', N'Đang bàn giao', 2500000, N'FX3U, Kèm module Analog', 'SN-PLC-O1');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000001', 'KP7', N'Laptop Dell Latitude 7420', N'Sẵn sàng', 28000000, N'Core i7-1185G7, RAM 16GB, SSD 512GB', 'SN-DELL-L7420');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000002', 'KP5', N'Máy chủ HP ProLiant ML30', N'Thanh lý', 55000000, N'Xeon E-2314, RAM 32GB, RAID 1 SSD', 'SN-HP-SERVER-01');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000002', 'NCC0000002', 'KP6', N'Màn hình tương tác Samsung Flip', N'Sẵn sàng', 65000000, N'65 inch, 4K UHD, Cảm ứng đa điểm', 'SN-SAM-FLIP65');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000002', 'NCC0000003', 'KP5', N'Tivi Sony Bravia 55 inch', N'Sẵn sàng', 22000000, N'4K HDR, Android TV, HDMI', 'SN-SONY-TV55');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000001', 'KP1', N'PC Dell OptiPlex 7010', N'Đang bàn giao', 12000000, N'Core i5-12500, RAM 16GB, SSD 256GB', 'SN-DELL-OPC7010-01');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000001', 'KP3', N'Laptop Lenovo ThinkPad T14', N'Sẵn sàng', 25000000, N'Core i7-1165G7, RAM 16GB, SSD 512GB', 'SN-LENOVO-T14-01');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000005', 'NCC0000004', 'KP4', N'Máy chẩn đoán ô tô Launch X431', N'Sẵn sàng', 42000000, N'Hỗ trợ đa hãng, Cập nhật online', 'SN-LAUNCH-X431');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000006', 'NCC0000002', 'KP3', N'Kit FPGA Xilinx Spartan-6', N'Sẵn sàng', 6500000, N'XC6SLX9, Board phát triển + cable', 'SN-FPGA-XILINX01');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000006', 'NCC0000001', 'KP3', N'Bộ thực hành STM32 Nucleo Kit', N'Đang bàn giao', 2800000, N'STM32F401RE, Debugger tích hợp', 'SN-STM32-NUCLEO');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000002', 'NCC0000002', 'KP6', N'Máy chiếu Epson EB-L200F', N'Sẵn sàng', 32000000, N'Full HD, 4500 Lumens, Wireless', 'SN-EPSON-L200F');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000002', 'NCC0000003', 'KP5', N'Tivi LG 75 inch Commercial', N'Sẵn sàng', 38000000, N'4K UHD, WebOS, Hotel mode', 'SN-LG-75UR640');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000007', 'NCC0000003', 'KP6', N'Loa column TOA TZ-406', N'Thanh lý', 12000000, N'40W, 4 loa 4 inch, Hội trường', 'SN-TOA-TZ406');
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000001', 'NCC0000001', 'KP2', N'Máy tính window XP 2016', N'Sẵn sàng', 7000000, N'120 GB, dung lượng 120', 'SN-657-974');
GO

-- tbPhong_ThietBi (không có trigger)
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000001', 'P003', '2026-05-01');
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000002', 'P003', '2026-04-10');
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000003', 'P003', '2026-05-15');
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000004', 'P006', '2026-03-01');
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000005', 'P006', '2026-06-20');
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000006', 'P007', '2026-02-15');
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES ('TB00000007', 'P007', '2026-07-10');

-- tbThietBi_NguoiDung (không có trigger)
INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES ('TB00000001', 'ND0002', 1); -- Trưởng khoa dùng PC Dell
INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES ('TB00000002', 'ND0003', 0); -- GV CNTT từng dùng Workstation (đã trả)
INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES ('TB00000003', 'ND0005', 1); -- Sinh viên mượn máy chiếu
INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES ('TB00000004', 'ND0004', 1); -- GV Cơ khí dùng máy CNC
INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES ('TB00000005', 'ND0004', 1); -- GV Cơ khí dùng máy hàn
INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES ('TB00000006', 'ND0006', 1); -- CSVC giữ dao động ký

-- YÊU CẦU 
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0005', 'LYC0000001', N'Chờ xử lý', '2025-09-01', '2025-09-02', NULL);
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0002', 'LYC0000002', N'Đã duyệt', '2025-09-05', '2025-09-10', '2025-09-08');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0003', 'LYC0000003', N'Chờ xử lý', '2025-09-06', '2025-09-07', NULL);
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0004', 'LYC0000001', N'Đã duyệt', '2025-09-07', '2025-09-07', '2025-09-07');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0002', 'LYC0000004', N'Từ chối', '2025-09-10', '2025-09-15', '2025-09-12');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0006', 'LYC0000003', N'Đã duyệt', '2025-09-11', '2025-09-12', '2025-09-11');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0005', 'LYC0000001', N'Đã hủy', '2025-09-12', '2025-09-13', NULL);
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0006', 'LYC0000003', N'Đã duyệt', '2025-09-12', '2025-09-14', '2025-09-12');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0003', 'LYC0000004', N'Đã duyệt', '2025-09-15', '2025-09-20', '2025-09-18');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0004', 'LYC0000003', N'Hoàn Thành', '2025-09-16', '2025-09-18', '2025-09-17');
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0006', 'LYC0000003', N'Chờ xử lý', '2025-09-16', '2025-09-18', '2025-09-17');
GO

-- CHI TIẾT YÊU CẦU SỬ DỤNG
INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon) VALUES
('YC00000001', 'TB00000018', 'T01', 'T03', N'Quay video thuyết trình môn Lập trình android', '2026-09-03'),
('YC00000001', 'TB00000001', 'T01', 'T03', N'Mượn PC phụ trợ', '2026-09-03'),
('YC00000004', 'TB00000002', 'T01', 'T02', N'Làm đồ án tốt nghiệp', '2026-09-15'),
('YC00000004', 'TB00000005', 'T03', 'T05', N'Đo đạc thí nghiệm', '2026-09-15'),
('YC00000007', 'TB00000001', 'T01', 'T05', N'Mượn bù buổi học trước', '2026-09-16');

-- CHI TIẾT YÊU CẦU SỬ DỤNG NGOÀI KHOA
-- Trigger tự sinh mã CTNK000001, CTNK000002
INSERT INTO tbChiTietYeuCauSuDung_NgoaiKhoa (YeuCauNo, KhoaPhongBanNo, TenTB, ThongSoKT, LyDo) VALUES ('YC00000002', 'KP2', N'Máy hàn TIG Jasic', N'Dòng hàn 200A, Hàn inox/sắt', N'Mượn máy hàn của Khoa Cơ khí để thi công Robocon');
INSERT INTO tbChiTietYeuCauSuDung_NgoaiKhoa (YeuCauNo, KhoaPhongBanNo, TenTB, ThongSoKT, LyDo) VALUES ('YC00000002', 'KP2', N'Máy phay CNC Mini', N'Hành trình 300x400mm', N'Mượn gia công chi tiết cơ khí cho đồ án');

-- CHI TIẾT YÊU CẦU SỬA CHỮA (Khóa chính kép: YeuCauNo + ThietBiNo)
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES ('YC00000003', 'TB00000001', 'img/tb001_hong.jpg', N'Bóng đèn mờ, quạt kêu to', N'Hư hỏng linh kiện sau thời gian sử dụng');
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES ('YC00000003', 'TB00000004', NULL, N'Không lên nguồn', N'Hư nguồn');
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES ('YC00000003', 'TB00000007', NULL, N'Module Analog lỗi', N'Cần thay module mới');
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES ('YC00000006', 'TB00000002', 'img/tb002_loi.jpg', N'Màn hình xanh, không khởi động', N'Lỗi RAM hoặc ổ cứng');
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES ('YC00000006', 'TB00000004', 'img/cnc_loi.jpg', N'Trục Z bị kẹt, sai số lớn', N'Cần hiệu chuẩn và bảo trì');
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES ('YC00000006', 'TB00000006', NULL, N'Kênh 2 không hiển thị', N'Lỗi phần cứng');

-- CHI TIẾT YÊU CẦU MUA SẮM - Trigger tự sinh mã CTM0000001 -> CTM0000007
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000005', N'Máy tính Dell Vostro', 10, N'Core i5 12th, RAM 16GB', 15000000, N'Cao', N'Bộ', N'Nâng cấp phòng máy B201');
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000005', N'Chuột máy tính', 20, N'Logitech B100', 100000, N'Thấp', N'Cái', N'Thay thế chuột hỏng');
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000005', N'Dây mạng CAT6', 3, N'Cuộn 300m', 2000000, N'Cao', N'Cái', N'Đi lại dây mạng phòng Lab');
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000005', N'Ổ cứng SSD', 10, N'Samsung 500GB', 1200000, N'Cao', N'Cái', N'Thay thế HDD cũ');
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000009', N'Màn hình 27 inch', 5, N'Dell Ultrasharp U2722D', 8000000, N'Trung bình', N'Cái', N'Trang bị cho phòng GV');
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000009', N'Loa hội trường', 2, N'JBL 1000W', 25000000, N'Thấp', N'Bộ', N'Trang bị hội trường C');
INSERT INTO tbChiTietYeuCau_Mua (YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES ('YC00000009', N'RAM 16GB', 10, N'DDR4 Bus 3200', 800000, N'Trung bình', N'Cái', N'Nâng cấp RAM máy cũ');

-- CHI TIẾT YÊU CẦU BÀN GIAO (Khóa chính kép: YeuCauNo + ThietBiNo)
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000008', 'TB00000001', 'KP1', '2025-09-14', '2025-09-14', N'Đã giao', 'ND0006', 'ND0002', N'Bàn giao PC Dell cho Trưởng khoa');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000008', 'TB00000002', 'KP1', '2025-09-14', '2025-09-14', N'Đã giao', 'ND0006', 'ND0003', N'Bàn giao Workstation HP');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000008', 'TB00000003', 'KP1', '2025-09-14', NULL, N'Chưa giao', 'ND0006', 'ND0003', N'Chờ lắp đặt phòng');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000010', 'TB00000004', 'KP2', '2025-09-17', '2025-09-17', N'Đã giao', 'ND0006', 'ND0004', N'Bàn giao máy CNC về Khoa Cơ khí');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000010', 'TB00000005', 'KP2', '2025-09-17', '2025-09-17', N'Đã giao', 'ND0006', 'ND0004', N'Bàn giao máy hàn TIG');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000010', 'TB00000006', 'KP3', '2025-09-18', '2025-09-18', N'Đã giao', 'ND0006', 'ND0004', N'Bàn giao dao động ký');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000010', 'TB00000007', 'KP3', '2025-09-18', '2025-09-18', N'Đã giao', 'ND0006', 'ND0003', N'Bàn giao dao động ký');
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES ('YC00000011', 'TB00000017', 'KP3', '2025-09-18', NULL, N'Chưa giao', 'ND0006', 'ND0003', NULL);
GO

---------------------------------------------------------------------------------------KỊCH BẢN TEST TRIGGER, FUNCTION AND PROCEDURE------------------------------------------------------------------------------------------------------------------------------------
--TEST TRIGGER trg_tbYeuCau_CapNhatTrangThaiTB
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao) 
VALUES ('ND0003', 'LYC0000003', N'Chờ xử lý', GETDATE());

-- Lấy mã YC vừa tạo để chèn chi tiết
DECLARE @MaYC_Sua CHAR(10) = (SELECT TOP 1 ID_YeuCau FROM tbYeuCau ORDER BY ID_YeuCau DESC);
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, MoTa, LyDo) 
VALUES (@MaYC_Sua, 'TB00000017', N'Lỗi nguồn', N'Sửa để thực hiện công tác giảng dạy môn thực hành lập trình');

-- Kiểm tra: Trạng thái TB00000017 tự chuyển sang 'Hư hỏng'
SELECT ID_ThietBi, TenTB, TrangThaiThietBi FROM tbThietBi WHERE ID_ThietBi = 'TB00000017';

-- Bước 2: Duyệt yêu cầu sửa chữa => Trạng thái TB00000017 tự chuyển sang 'Sửa chữa'
DECLARE @MaYC_Sua CHAR(10) = (SELECT TOP 1 ID_YeuCau FROM tbYeuCau ORDER BY ID_YeuCau DESC);
UPDATE tbYeuCau SET TrangThai = N'Đã duyệt' WHERE ID_YeuCau = @MaYC_Sua;
SELECT ID_ThietBi, TenTB, TrangThaiThietBi FROM tbThietBi WHERE ID_ThietBi = 'TB00000017';

-- Bước 3: Hoàn thành => Trạng thái TB00000017 tự chuyển sang 'Sẵn sàng'
DECLARE @MaYC_Sua CHAR(10) = (SELECT TOP 1 ID_YeuCau FROM tbYeuCau ORDER BY ID_YeuCau DESC);
UPDATE tbYeuCau SET TrangThai = N'Hoàn Thành' WHERE ID_YeuCau = @MaYC_Sua;
SELECT ID_ThietBi, TenTB, TrangThaiThietBi FROM tbThietBi WHERE ID_ThietBi = 'TB00000017';

--TEST TRIGGER trg_ChiTietSuDung_Insert_KiemTraTrung
INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon) VALUES
('YC00000001', 'TB00000005', 'T01', 'T03', N'Quay video thuyết trình môn Lập trình android', '2026-09-03'); --Thành công

INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon) VALUES
('YC00000004', 'TB00000002', 'T01', 'T02', N'Làm đồ án tốt nghiệp', '2026-09-15'); --Thất bại

--TEST TRIGGER trg_tbYeuCau_HuyYeuCau
UPDATE tbYeuCau SET TrangThai = N'Đã hủy' WHERE ID_YeuCau = 'YC00000011' --Thành công

UPDATE tbYeuCau SET TrangThai = N'Đã hủy' WHERE ID_YeuCau = 'YC00000006' --Thất bại

--TEST trigger trg_tbThietBi_CheckThanhLy
UPDATE tbThietBi SET TrangThaiThietBi = N'Thanh lý' WHERE ID_ThietBi = 'TB00000002' --Thất bại vì mặc dù thiết bị ở trạng thái sẵn sàng nhưng nó đã có lịch được mượn và đã được duyệt

UPDATE tbThietBi SET TrangThaiThietBi = N'Thanh lý' WHERE ID_ThietBi = 'TB00000020' --Thành công

--TEST TRIGGER ngăn không cho hành động xoá thiết bị xảy ra
DELETE tbThietBi WHERE ID_ThietBi = 'TB00000014'

--TEST TRIGGER --TEST TRIGGER trg_tbThietBi_CheckBeforeInsert kiểm tra mã tham chiếu hợp lệ/tồn tại hay không? => Chèn dữ liệu vào bảng tbThietBi
INSERT INTO tbThietBi (DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES ('DM00000200', 'NCC0000001', 'KP1', N'PC Dell Optiplex 7090', N'Sẵn sàng', 15000000, N'Core i7-12700, RAM 16GB, SSD 512GB', 'SN-DELL-100');

--TEST TRIGGER --TEST TRIGGER trg_tbYeuCau_CheckBeforeInsert kiểm tra mã tham chiếu hợp lệ/tồn tại hay không? => Chèn dữ liệu vào bảng tbYeuCau
INSERT INTO tbYeuCau (NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES ('ND0005', 'LYC0000100', N'Chờ xử lý', '2025-09-01', '2025-09-02', NULL);

-- 1. Thống kê thiết bị toàn trường
SELECT * FROM dbo.fn_ThongKeThietBi_TatCaTrangThai();

-- 2. Thống kê thiết bị của một khoa cụ thể (Ví dụ khoa CNTT - mã 'KP1')
SELECT * FROM dbo.fn_ThongKeTrangThaiThietBi_TheoKhoa('KP1');

-- 3. Kiểm tra quyền của một người dùng (Ví dụ ND0001 có quyền 'Quản trị' không?)
-- Trả về 1 nếu có, 0 nếu không
SELECT dbo.fn_CheckQuyenNguoiDung('ND0001', N'Quản trị') AS CoQuyenQuanTri;

-- 4. Tính tổng giá trị tài sản hiện có của khoa Cơ khí (Mã 'KP2')
SELECT dbo.fn_TinhTongGiaTriThietBiKhoa('KP2') AS TongGiaTri_KhoaCoKhi;

-- 5. Phân tích các loại yêu cầu đang ở trạng thái 'Đã duyệt'
SELECT * FROM dbo.fn_PhanTichYeuCauTheoTrangThai(N'Đã duyệt');

-- 6. Thống kê thiết bị theo nhà cung cấp của khoa CNTT ('KP1')
SELECT * FROM dbo.fn_ThongKeThietBiTheoNhaCC('KP1');

-- 7. Thống kê yêu cầu theo tháng trong năm 2025
EXEC pr_ThongKeYeuCauTheoThang @Nam = 2025;

-- 8. Xuất báo cáo tổng giá trị tài sản của tất cả các khoa trong trường
EXEC pr_BaoCaoGiaTriTaiSanTheoKhoa;

-- 9. Chạy thuật toán đề xuất các thiết bị cần bảo trì dựa trên thời gian sử dụng
EXEC pr_DeXuatBaoTriDuPhong;

-- 10. Hiển thị lịch sử dụng của thiết bị
SELECT * FROM dbo.fn_XemLichDungThietBi('TB00000002');
