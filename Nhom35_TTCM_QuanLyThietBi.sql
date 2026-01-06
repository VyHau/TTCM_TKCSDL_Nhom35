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
    NgayNhanThucTe DATE NOT NULL,
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
DISABLE TRIGGER ALL ON DATABASE;
GO

ALTER TABLE tbPhong_ThietBi NOCHECK CONSTRAINT ALL;
ALTER TABLE tbChiTietYeuCau_SuDung NOCHECK CONSTRAINT ALL;
ALTER TABLE tbVaiTro_NguoiDung NOCHECK CONSTRAINT ALL; -- 
GO
INSERT INTO tbQuyenHan (ID_QuyenHan, TenQuyenHan, MoTa) VALUES
('QH001', N'Xem', N'Chỉ được xem dữ liệu'),
('QH002', N'Thêm', N'Được phép thêm mới'),
('QH003', N'Sửa', N'Được phép chỉnh sửa'),
('QH004', N'Xóa', N'Được phép xóa dữ liệu'),
('QH005', N'Duyệt', N'Quyền phê duyệt yêu cầu'),
('QH006', N'Báo cáo', N'Xuất các báo cáo thống kê'),
('QH007', N'Quản trị', N'Toàn quyền hệ thống');

INSERT INTO tbVaiTro (ID_VaiTro, TenVaiTro) VALUES
('VT001', N'Admin'), ('VT002', N'Ban Giám Hiệu'), ('VT003', N'Trưởng Khoa'),
('VT004', N'Phòng CSVC'), ('VT005', N'Phòng KHTC'), ('VT006', N'Giảng viên'), ('VT007', N'Sinh viên');

INSERT INTO tbKhoa_PhongBan (ID_KhoaPhongBan, TenPhongBanKhoa) VALUES
('K01', N'Khoa Công nghệ số'), ('K02', N'Khoa Cơ khí'), ('K03', N'Khoa Điện - Điện tử'),
('K04', N'Khoa KT Xây dựng'), ('K05', N'Khoa Sư phạm Công nghiệp'),
('P01', N'Phòng Cơ sở vật chất'), ('P02', N'Phòng Kế hoạch Tài chính');

INSERT INTO tbCoSo (ID_CoSo, TenCoSo) VALUES ('CS01', N'Cơ sở 1'), ('CS02', N'Cơ sở 2');

INSERT INTO tbDanhMuc (ID_DanhMuc, TenDanhMuc, MoTa) VALUES
('DM00000001', N'Thiết bị CNTT', N'PC, Laptop'),
('DM00000002', N'Thiết bị Trình chiếu', N'Máy chiếu, TV'),
('DM00000003', N'Thiết bị Mạng', N'Router, Switch'),
('DM00000004', N'Thiết bị Đo lường', N'Dao động ký'),
('DM00000005', N'Máy Công cụ', N'CNC, Máy hàn'),
('DM00000006', N'Thiết bị Nhúng', N'PLC, Kit'),
('DM00000007', N'Thiết bị Âm thanh', N'Loa, Mic');

INSERT INTO tbNhaCungCap (ID_NhaCC, TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES
('NCC0000001', N'FPT Trading', N'Cung cấp', N'Đà Nẵng', '0905111222'),
('NCC0000002', N'Phong Vũ', N'Cung cấp', N'Đà Nẵng', '0905333444'),
('NCC0000003', N'Điện máy Xanh', N'Bảo trì', N'Đà Nẵng', '18001061'),
('NCC0000004', N'Cơ khí Hòa Phát', N'Cung cấp', N'Đà Nẵng', '0914555666');

INSERT INTO tbLoaiYeuCau (ID_LoaiYeuCau, TenLoaiYeuCau) VALUES
('LYC0000001', N'Yêu cầu sử dụng thiết bị'),
('LYC0000002', N'Yêu cầu sử dụng thiết bị ngoài khoa'),
('LYC0000003', N'Yêu cầu Sửa chữa'),
('LYC0000004', N'Yêu cầu mua sắm thiết bị'),
('LYC0000005', N'Báo cáo tình trạng thiết bị mua sắm'),
('LYC0000006', N'Yêu cầu bàn giao'),
('LYC0000007', N'Báo cáo sự cố thiết bị');

INSERT INTO tbTiet (ID_Tiet, GioBD, ThoiLuong) VALUES
('T01', '07:00', 60), ('T02', '08:00', 60), ('T03', '09:00', 60), ('T04', '10:00', 60),
('T05', '11:00', 60), ('T06', '12:00', 60), ('T07', '13:00', 60), ('T08', '14:00', 60);

-- =======================================================
-- BƯỚC 2: NGƯỜI DÙNG & PHÒNG 
-- =======================================================

INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES
('QH001', 'VT001', 1), ('QH004', 'VT001', 1), ('QH001', 'VT007', 1);

INSERT INTO tbKhuVuc (ID_KhuVuc, CoSoNo, TenKhuVuc) VALUES
('KV01', 'CS01', N'Khu A'), ('KV02', 'CS01', N'Khu B'), ('KV03', 'CS01', N'Xưởng');

INSERT INTO tbNguoiDung (ID_NguoiDung, KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES
('ND0001', 'P01', 'VT001', 'admin@ute.vn', '123', N'Admin', '1990-01-01', 1),
('ND0002', 'K01', 'VT003', 'tk.cntt@ute.vn', '123', N'Trưởng Khoa CNTT', '1980-01-01', 1),
('ND0003', 'K01', 'VT006', 'gv.cntt@ute.vn', '123', N'Giảng Viên A', '1990-01-01', 1),
('ND0004', 'K02', 'VT006', 'gv.ck@ute.vn', '123', N'Giảng Viên B', '1985-01-01', 1),
('ND0005', 'K01', 'VT007', 'sv.cntt@ute.vn', '123', N'Sinh Viên C', '2003-01-01', 1),
('ND0006', 'P01', 'VT004', 'nv.csvc@ute.vn', '123', N'Nhân Viên CSVC', '1995-01-01', 1);

INSERT INTO tbVaiTro_NguoiDung (VaiTroNo, NguoiDungNo, NgayHieuLuc, NgayHetHieuLuc) VALUES
('VT001', 'ND0001', '2023-01-01', '2030-01-01'), ('VT007', 'ND0005', '2023-09-01', '2027-09-01');

INSERT INTO tbPhong (ID_Phong, KhuVucNo, TenPhong, SucChua) VALUES
('P001', 'KV01', N'Phòng A101', 60), ('P003', 'KV02', N'Phòng B201', 40),
('P006', 'KV03', N'Xưởng CNC', 30), ('P007', 'KV03', N'Phòng Lab', 50);

INSERT INTO tbLopHocPhan (ID_LHP, PhongNo, TietNo, Thu, SiSo, TenLHP, HocKy) VALUES
('LHP0000001', 'P003', 'T01', N'Thứ 2', 40, N'Thực hành CSDL', N'1/2025');

-- =======================================================
-- 3: THIẾT BỊ 
-- =======================================================

INSERT INTO tbThietBi (ID_ThietBi, DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES

-- 1. NHÓM "SẴN SÀNG"
-- Logic: Không có ai đang mượn, không hỏng. Đang rảnh rỗi.
('TB00000001', 'DM00000001', 'NCC0000001', 'K01', N'PC Dell Optiplex (M01)', N'Sẵn sàng', 15000000, N'Core i7', 'SN-001'),
('TB00000002', 'DM00000001', 'NCC0000001', 'K01', N'PC Dell Optiplex (M02)', N'Sẵn sàng', 15000000, N'Core i7', 'SN-002'),
('TB00000003', 'DM00000001', 'NCC0000001', 'K01', N'PC Dell Optiplex (M03)', N'Sẵn sàng', 15000000, N'Core i7', 'SN-003'),
('TB00000004', 'DM00000005', 'NCC0000004', 'K02', N'Máy hàn TIG Jasic', N'Sẵn sàng', 8500000, N'200A', 'SN-004'),
('TB00000013', 'DM00000004', 'NCC0000001', 'K03', N'Dao động ký (Dự phòng)', N'Sẵn sàng', 12500000, N'100MHz', 'SN-013'),
('TB00000015', 'DM00000007', 'NCC0000002', 'P01', N'Loa hội trường JBL', N'Sẵn sàng', 25000000, N'1000W', 'SN-015'),

-- 2. NHÓM "ĐANG SỬ DỤNG"
-- Logic: Đang nằm trong một YC Mượn chưa trả hoặc Bàn giao.
('TB00000005', 'DM00000001', 'NCC0000001', 'K01', N'Workstation HP Z4', N'Đang sử dụng', 45000000, N'Xeon W', 'SN-005'),
('TB00000006', 'DM00000002', 'NCC0000002', 'P01', N'Máy chiếu Panasonic', N'Đang sử dụng', 18000000, N'4100 Lumens', 'SN-006'),
('TB00000012', 'DM00000004', 'NCC0000001', 'K03', N'Dao động ký Tektronix', N'Đang sử dụng', 12500000, N'100MHz', 'SN-012'),
('TB00000014', 'DM00000001', 'NCC0000001', 'K01', N'Màn hình Dell Ultra', N'Đang sử dụng', 8000000, N'27 inch', 'SN-014'),

-- 3. NHÓM "HƯ HỎNG"
-- Logic: Đang nằm trong YC Báo hỏng (Chờ xử lý).
('TB00000007', 'DM00000002', 'NCC0000002', 'K01', N'Máy chiếu Sony (Hư)', N'Hư hỏng', 12000000, N'XGA', 'SN-007'),
('TB00000008', 'DM00000001', 'NCC0000001', 'K01', N'PC Dell Vostro (Hư)', N'Hư hỏng', 10000000, N'Gen 8', 'SN-008'),
('TB00000009', 'DM00000005', 'NCC0000004', 'K02', N'Máy khoan bàn (Gãy)', N'Hư hỏng', 5000000, N'1/2 HP', 'SN-009'),

-- 4. NHÓM "SỬA CHỮA"
-- Logic: Đang nằm trong YC Sửa chữa (Đã duyệt).
('TB00000010', 'DM00000005', 'NCC0000004', 'K02', N'Máy phay CNC Mini', N'Sửa chữa', 120000000, N'24k rpm', 'SN-010'),
('TB00000011', 'DM00000006', 'NCC0000001', 'K03', N'Bộ thực hành PLC', N'Sửa chữa', 25000000, N'FX3U', 'SN-011');



-- Map thiết bị vào phòng
INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES
('TB00000001', 'P003', '2024-01-01'), ('TB00000002', 'P003', '2024-01-01'),
('TB00000003', 'P003', '2024-01-01'), ('TB00000004', 'P006', '2024-01-01'),
('TB00000005', 'P001', '2024-01-01'), ('TB00000006', 'P001', '2024-01-01'),
('TB00000010', 'P006', '2024-01-01'), ('TB00000011', 'P007', '2024-01-01'),
('TB00000012', 'P007', '2024-01-01'), ('TB00000014', 'P003', '2024-01-01');

INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES
('TB00000005', 'ND0002', 1), ('TB00000006', 'ND0006', 1);

-- =======================================================
-- 4: YÊU CẦU 
-- =======================================================

INSERT INTO tbYeuCau (ID_YeuCau, NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES
-- 1. CÁC YÊU CẦU ĐÃ HOÀN THÀNH (TRẢ MÁY)
-- YC01: Đã trả máy TB01, TB02, TB03
('YC00000001', 'ND0005', 'LYC0000001', N'Hoàn Thành', '2025-08-01', '2025-08-05', '2025-08-05'),
-- YC04: Đã trả máy TB04
('YC00000004', 'ND0004', 'LYC0000001', N'Hoàn Thành', '2025-09-01', '2025-09-02', '2025-09-02'),

-- 2. CÁC YÊU CẦU ĐANG MƯỢN (CHƯA TRẢ)
-- YC07: SV mượn TB12
('YC00000007', 'ND0005', 'LYC0000001', N'Đã duyệt', '2026-01-04', '2026-01-05', '2026-01-06'),
-- YC10: GV mượn TB14
('YC00000010', 'ND0003', 'LYC0000001', N'Đã duyệt', '2026-01-04', '2026-01-05', '2026-01-06'),

-- 3. BÁO CÁO SỰ CỐ
-- YC03: Báo hỏng (TB07, TB08, TB09). Chờ xử lý -> Thiết bị vẫn Hư.
('YC00000003', 'ND0003', 'LYC0000003', N'Chờ xử lý', '2025-09-20', '2025-09-21', NULL),
-- YC06: Đưa đi sửa (TB10, TB11). Đã duyệt -> Thiết bị đang Sửa.
('YC00000006', 'ND0006', 'LYC0000003', N'Đã duyệt', '2025-09-22', '2025-09-25', '2025-09-22'),

-- 4. BÀN GIAO 
-- YC08: Bàn Giao (TB13,TB15)
('YC00000008', 'ND0006', 'LYC0000006', N'Đã duyệt', '2025-09-10', '2025-09-10', '2025-09-10'),

-- 5. MUA SẮM 
('YC00000002', 'ND0002', 'LYC0000004', N'Đã duyệt', '2025-09-01', '2025-09-05', '2025-09-02');

-- =======================================================
-- 5: CHI TIẾT YÊU CẦU 
-- =======================================================

-- 5.1 Chi tiết MƯỢN/SỬ DỤNG
-- mượn và đã trả 
INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon) VALUES
('YC00000001', 'TB00000001', 'T01', 'T03', N'Học thực hành', '2025-08-05'),
('YC00000001', 'TB00000002', 'T01', 'T03', N'Học thực hành', '2025-08-05'),
('YC00000001', 'TB00000003', 'T01', 'T03', N'Học thực hành', '2025-08-05'),
('YC00000004', 'TB00000004', 'T01', 'T05', N'Mượn đi hội thảo', '2025-09-02'),
--mượn và đang sử dụng
('YC00000007', 'TB00000012', 'T01', 'T05', N'Làm đồ án tốt nghiệp', '2026-01-06'),
('YC00000010', 'TB00000014', 'T01', 'T05', N'Dùng hiển thị slide', '2026-01-06');

-- 5.2 Chi tiết SỬA CHỮA (TB Hư & Đang sửa)
INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES
('YC00000003', 'TB00000007', 'img/sony_hong.jpg', N'Bóng đèn mờ', N'Tuổi thọ cao'),
('YC00000003', 'TB00000008', NULL, N'Không lên nguồn', N'Hư nguồn'),
('YC00000003', 'TB00000009', 'img/khoan_gay.jpg', N'Gãy mũi khoan', N'Sinh viên làm gãy'),
('YC00000006', 'TB00000010', 'img/cnc_ket.jpg', N'Kẹt trục Z', N'Lỗi cơ khí'),
('YC00000006', 'TB00000011', NULL, N'Mất tín hiệu Input', N'Lỏng chân hàn');

-- 5.3 Chi tiết BÀN GIAO
INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES
('YC00000008', 'TB00000013', 'K01', '2025-09-10', '2025-09-10', N'Đã giao', 'ND0006', 'ND0002', N'Máy cho trưởng khoa'),
('YC00000008', 'TB00000015', 'P01', '2025-09-10', '2025-09-10', N'Đã giao', 'ND0006', 'ND0006', N'Lắp tại phòng họp');

-- 5.4 Chi tiết MUA SẮM
INSERT INTO tbChiTietYeuCau_Mua (ID_ChiTiet, YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES
('CTM0000001', 'YC00000002', N'Chuột máy tính', 20, N'Logitech', 100000, N'Thấp', N'Cái', N'Thay thế');

-- =======================================================
-- 6 : BẬT LẠI TRIGGER & CHECK CONSTRAINT (QUAN TRỌNG)
-- =======================================================
ENABLE TRIGGER ALL ON DATABASE;

ALTER TABLE tbPhong_ThietBi WITH NOCHECK CHECK CONSTRAINT ALL;
ALTER TABLE tbChiTietYeuCau_SuDung WITH NOCHECK CHECK CONSTRAINT ALL;
ALTER TABLE tbVaiTro_NguoiDung WITH NOCHECK CHECK CONSTRAINT ALL;
GO