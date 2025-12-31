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
    TrangThaiThietBi NVARCHAR(20) DEFAULT N'Sẵn sàng' CHECK (TrangThaiThietBi IN (N'Sửa chữa', N'Thanh lý', N'Đang sử dụng', N'Hư hỏng', N'Sẵn sàng')),
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
CREATE SEQUENCE seq_YeuCau START WITH 1 INCREMENT BY 1;
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

-- Bảng tbYeuCau
CREATE PROCEDURE pr_SinhMa_YeuCau
    @MaMoi CHAR(10) OUTPUT
AS
BEGIN
    DECLARE @STT INT = NEXT VALUE FOR seq_YeuCau;

    SET @MaMoi = 'YC' + RIGHT('00000000' + CAST(@STT AS VARCHAR), 8);
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

-- =============================================
-- TRIGGER
-- =============================================

-- Trigger sinh mã tự động cho bảng tbQuyenHan
CREATE TRIGGER trg_tbQuyenHan_Insert_SinhMa
ON tbQuyenHan
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(5);
    EXEC pr_SinhMa_QuyenHan @NewID OUTPUT;

    INSERT INTO tbQuyenHan(ID_QuyenHan, TenQuyenHan)
    SELECT @NewID, TenQuyenHan
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbVaiTro
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

-- Trigger sinh mã tự động cho bảng tbNguoiDung
CREATE TRIGGER trg_tbNguoiDung_Insert_SinhMa
ON tbNguoiDung
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(6);
    EXEC pr_SinhMa_NguoiDung @NewID OUTPUT;

    INSERT INTO tbNguoiDung(ID_NguoiDung, Email, MatKhau, HoTen, NgaySinh)
    SELECT @NewID, Email, MatKhau, HoTen, NgaySinh
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbThietBi
CREATE TRIGGER trg_tbThietBi_Insert_SinhMa
ON tbThietBi
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_ThietBi @NewID OUTPUT;

    INSERT INTO tbThietBi(ID_ThietBi, DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri)
    SELECT @NewID, DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbKhoa_PhongBan
CREATE TRIGGER trg_tbKhoaPhongBan_Insert_SinhMa
ON tbKhoa_PhongBan
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_KhoaPhongBan @NewID OUTPUT;

    INSERT INTO tbKhoaPhongBan(ID_KhoaPhongBan, TenKhoaPhongBan)
    SELECT @NewID, TenPhongBanKhoa
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbTaiLieu
CREATE TRIGGER trg_tbTaiLieu_Insert_SinhMa
ON tbTaiLieu
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_TaiLieu @NewID OUTPUT;

    INSERT INTO tbTaiLieu(ID_TaiLieu, DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile)
    SELECT @NewID, DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbYeuCau
CREATE TRIGGER trg_tbYeuCau_Insert_SinhMa
ON tbYeuCau
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_YeuCau @NewID OUTPUT;

    INSERT INTO tbYeuCau(ID_YeuCau, NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy)
    SELECT @NewID, NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbThongBao
CREATE TRIGGER trg_tbThongBao_Insert_SinhMa
ON tbThongBao
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_ThongBao @NewID OUTPUT;

    INSERT INTO tbThongBao(ID_ThongBao, LoaiThongBao, NoiDung, NgayTao)
    SELECT @NewID, LoaiThongBao, NoiDung, NgayTao
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbDanhMuc
CREATE TRIGGER trg_tbDanhMuc_Insert_SinhMa
ON tbDanhMuc
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_DanhMuc @NewID OUTPUT;

    INSERT INTO tbDanhMuc(ID_DanhMuc, TenDanhMuc)
    SELECT @NewID, TenDanhMuc
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbNhaCungCap
CREATE TRIGGER trg_tbNhaCungCap_Insert_SinhMa
ON tbNhaCungCap
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_NhaCungCap @NewID OUTPUT;

    INSERT INTO tbNhaCC(ID_NhaCC, TenNhaCC, LoaiDichVu, DiaChi, SDT)
    SELECT @NewID, TenNhaCC, LoaiDichVu, DiaChi, SDT
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbTiet
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

-- Trigger sinh mã tự động cho bảng tbPhong
CREATE TRIGGER trg_tbPhong_Insert_SinhMa
ON tbPhong
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_Phong @NewID OUTPUT;

    INSERT INTO tbPhong(ID_Phong, TenPhong)
    SELECT @NewID, TenPhong
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbKhuVuc
CREATE TRIGGER trg_tbKhuVuc_Insert_SinhMa
ON tbKhuVuc
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NewID CHAR(10);
    EXEC pr_SinhMa_KhuVuc @NewID OUTPUT;

    INSERT INTO tbKhuVuc(ID_KhuVuc, TenKhuVuc)
    SELECT @NewID, TenKhuVuc
    FROM inserted;
END;
GO

-- Trigger sinh mã tự động cho bảng tbCoSo
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

-- ============================================
-- Trigger tự động cập nhật ngày tạo và insert tbThongBao_NguoiDung khi thêm thông báo
CREATE TRIGGER trg_tbThongBao_Insert_ThongBaoNguoiDung
On tbThongBao
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tbThongBao
    SET NgayTao = GETDATE()
    FROM tbThongBao t
    INNER JOIN inserted i ON t.ID_ThongBao = i.ID_ThongBao;

    INSERT INTO tbThongBao_NguoiDung(ThongBaoNo, NguoiNhanNo)
    SELECT i.ID_ThongBao, nd.ID_NguoiDung
    FROM inserted i
    CROSS JOIN tbNguoiDung nd
    WHERE i.LoaiThongBao = N'Công khai';
END;
GO

-- Trigger chặn xóa thiết bị, thay trạng thái thành 'Đã thanh lý'
CREATE TRIGGER trg_tbThietBi_Delete_ThanhLy
ON tbThietBi
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Đã thanh lý'
    FROM tbThietBi t
    INNER JOIN deleted d
        ON t.ID_ThietBi = d.ID_ThietBi;
END;
GO

-- =============================================
-- MOCK DATA
-- =============================================

-- Trigger cập nhật thông tin khi bàn giao
CREATE TRIGGER trg_ChiTietBanGiao_DaBanGiao
ON tbChiTietYeuCau_BanGiao
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThaiBanGiao)
    BEGIN
        UPDATE tbThietBi
        SET KhoaPhongBan = i.PhongBanKhoaNo, TrangThaiThietBi = N'Đang sử dụng'
        FROM tbThietBi tb 
        INNER JOIN inserted i ON tb.ID_ThietBi = i.ThietBiNo
        INNER JOIN deleted d ON i.YeuCauNo = d.YeuCauNo AND i.ThietBiNo = d.ThietBiNo
        WHERE i.TrangThaiBanGiao = N'Đã bàn giao'

        -- Cập nhật ngày nhận thực tế
        UPDATE tbChiTietYeuCau_BanGiao
        SET NgayNhanThucTe = GETDATE()
        FROM tbChiTietYeuCau_BanGiao ct
        INNER JOIN inserted i ON ct.YeuCauNo = i.YeuCauNo AND ct.ThietBiNo = i.ThietBiNo
        INNER JOIN deleted d ON ct.YeuCauNo = d.YeuCauNo AND ct.ThietBiNo = d.ThietBiNo
        WHERE i.TrangThaiBanGiao = N'Đã bàn giao'
    END
END;
GO

-- Trigger khi update tbYeuCau (trạng thái) => cập nhật trạng thái thiết bị
CREATE TRIGGER trg_tbYeuCau_CapNhatTrangThaiTB
ON tbYeuCau
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Khi tạo yêu cầu sửa chữa
    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Hư hỏng'
    FROM tbThietBi tb
    JOIN tbChiTietYeuCau_SuaChua ct ON tb.ID_ThietBi = ct.ThietBiNo
    JOIN inserted i ON ct.YeuCauNo = i.ID_YeuCau
    WHERE i.LoaiYeuCauNo = 'LYC03' AND i.TrangThai = N'Chờ xử lý';

    -- 2. Khi duyệt yêu cầu sửa chữa
    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Sửa chữa'
    FROM tbThietBi tb
    JOIN tbChiTietYeuCau_SuaChua ct ON tb.ID_ThietBi = ct.ThietBiNo
    JOIN inserted i ON ct.YeuCauNo = i.ID_YeuCau
    JOIN deleted d ON i.ID_YeuCau = d.ID_YeuCau
    WHERE i.LoaiYeuCauNo = 'LYC03' AND d.TrangThai = N'Chờ xử lý' AND i.TrangThai = N'Đã duyệt';

    -- 3. Khi hoàn thành yêu cầu sửa chữa
    UPDATE tbThietBi
    SET TrangThaiThietBi = N'Sẵn sàng'
    FROM tbThietBi tb
    JOIN tbChiTietYeuCau_SuaChua ct ON tb.ID_ThietBi = ct.ThietBiNo
    JOIN inserted i ON ct.YeuCauNo = i.ID_YeuCau
    WHERE i.LoaiYeuCauNo = 'LYC03' AND i.TrangThai = N'Hoàn Thành';
END;
GO

-- Trigger tạo thông báo tự động khi cập nhật trạng thái yêu cầu
CREATE TRIGGER trg_YeuCau_ThongBaoHeThong
ON tbYeuCau
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO tbThongBao (ID_ThongBao, NguoiTaoNo, TieuDe, NoiDung, NgayTao, LoaiThongBao)
    SELECT 
        NEXT VALUE FOR seq_ThongBao,
        NULL,
        N'Thông báo xử lý yêu cầu',
        CASE 
            WHEN i.TrangThai = N'Đã duyệt' 
                THEN N'Yêu cầu ' + lyc.TenLoaiYeuCau + N' đã được duyệt'
            ELSE 
                N'Yêu cầu ' + lyc.TenLoaiYeuCau + N' đã bị từ chối'
        END,
        GETDATE(),
        N'Hệ thống'
    FROM inserted i
    INNER JOIN deleted d ON i.ID_YeuCau = d.ID_YeuCau
    INNER JOIN tbLoaiYeuCau lyc ON i.LoaiYeuCauNo = lyc.ID_LoaiYeuCau
    WHERE d.TrangThai = N'Chờ xử lý' AND i.TrangThai IN (N'Đã duyệt', N'Từ chối');

    INSERT INTO tbThongBao_NguoiDung (ThongBaoNo, NguoiNhanNo)
    SELECT tb.ID_ThongBao, i.NguoiTaoNo
    FROM tbThongBao tb
    INNER JOIN inserted i ON tb.NgayTao = CAST(GETDATE() AS DATE)
    WHERE i.NguoiTaoNo IS NOT NULL;
END;
GO

-- Trigger kiểm tra trùng lịch mượn khi INSERT vào tbChiTietYeuCau_SuDung
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
        WHERE yc.TrangThai NOT IN (N'Từ chối', N'Đã hủy', N'Hoàn Thành') AND ((i.TietBDNo <= ct.TietKTNo) AND (i.TietKTNo >= ct.TietBDNo))
    )
    BEGIN
        RAISERROR(N'Thiết bị đã được mượn trong khoảng thời gian này. Vui lòng chọn thời gian khác.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Nếu không trùng thì cho phép insert
    INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon)
    SELECT YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon
    FROM inserted;
END;
GO