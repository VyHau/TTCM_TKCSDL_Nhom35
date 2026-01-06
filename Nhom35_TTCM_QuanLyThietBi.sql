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
    TrangThaiThietBi NVARCHAR(20) DEFAULT N'Sẵn sàng' CHECK (TrangThaiThietBi IN (N'Sửa chữa', N'Đã thanh lý', N'Đang sử dụng', N'Hư hỏng', N'Sẵn sàng')),
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
-- 1. DỮ LIỆU DANH MỤC & CẤU HÌNH (GIỮ NGUYÊN CỦA BẠN)
-- =============================================
INSERT INTO tbQuyenHan (ID_QuyenHan, TenQuyenHan, MoTa) VALUES
('QH001', N'Xem', N'Chỉ được xem dữ liệu'),
('QH002', N'Thêm', N'Được phép thêm mới'),
('QH003', N'Sửa', N'Được phép chỉnh sửa'),
('QH004', N'Xóa', N'Được phép xóa dữ liệu'),
('QH005', N'Duyệt', N'Quyền phê duyệt yêu cầu'),
('QH006', N'Báo cáo', N'Xuất các báo cáo thống kê'),
('QH007', N'Quản trị', N'Toàn quyền hệ thống');

INSERT INTO tbVaiTro (ID_VaiTro, TenVaiTro) VALUES
('VT001', N'Admin'),
('VT002', N'Ban Giám Hiệu'),
('VT003', N'Trưởng Khoa'),
('VT004', N'Phòng CSVC'),
('VT005', N'Phòng KHTC'),
('VT006', N'Giảng viên'),
('VT007', N'Sinh viên');

INSERT INTO tbKhoa_PhongBan (ID_KhoaPhongBan, TenPhongBanKhoa) VALUES
('K01', N'Khoa Công nghệ số'),
('K02', N'Khoa Cơ khí'),
('K03', N'Khoa Điện - Điện tử'),
('K04', N'Khoa KT Xây dựng'),
('K05', N'Khoa Sư phạm Công nghiệp'),
('P01', N'Phòng Cơ sở vật chất'),
('P02', N'Phòng Kế hoạch Tài chính');

INSERT INTO tbCoSo (ID_CoSo, TenCoSo) VALUES
('CS01', N'Cơ sở 1'),
('CS02', N'Cơ sở 2');

INSERT INTO tbDanhMuc (ID_DanhMuc, TenDanhMuc, MoTa) VALUES
('DM01', N'Thiết bị CNTT', N'Máy tính bàn, Laptop, Server, Workstation'),
('DM02', N'Thiết bị Trình chiếu', N'Máy chiếu, Màn hình tương tác, Tivi'),
('DM03', N'Thiết bị Mạng & Viễn thông', N'Router, Switch, Access Point, Tổng đài'),
('DM04', N'Thiết bị Đo lường & Thí nghiệm', N'Dao động ký, Đồng hồ vạn năng, Nguồn DC'),
('DM05', N'Máy Công cụ & Cơ khí', N'Máy phay CNC, Máy tiện, Máy hàn, Robot tay máy'),
('DM06', N'Kit & Bo mạch nhúng', N'Kit FPGA, Raspberry Pi, Arduino, PLC'),
('DM07', N'Thiết bị Âm thanh', N'Loa hội trường, Micro, Amply, Mixer');
GO

INSERT INTO tbNhaCungCap (ID_NhaCC, TenNhaCC, LoaiDichVu, DiaChi, SDT) VALUES
('NCC001', N'FPT Trading', N'Cung cấp', N'KCN Đà Nẵng', '0905111222'),
('NCC002', N'Phong Vũ', N'Cung cấp', N'Lê Duẩn, ĐN', '0905333444'),
('NCC003', N'Điện máy Xanh', N'Bảo trì', N'Nguyễn Văn Linh, ĐN', '18001061'),
('NCC004', N'Cơ khí Hòa Phát', N'Cung cấp', N'Hòa Khánh, ĐN', '0914555666'),
('NCC005', N'Daikin Service', N'Sửa chữa', N'Hải Châu, ĐN', '18006777'),
('NCC006', N'Thiết bị GD Sao Mai', N'Cung cấp', N'Thanh Khê, ĐN', '0935888999'),
('NCC007', N'Viettel IDC', N'Khác', N'Hòa Cường, ĐN', '0969000111');

INSERT INTO tbLoaiYeuCau (ID_LoaiYeuCau, TenLoaiYeuCau) VALUES
('LYC01', N'Yêu cầu sử dụng thiết bị'),
('LYC02', N'Yêu cầu sử dụng thiết bị ngoài khoa'),
('LYC03', N'Yêu cầu Sửa chữa'),
('LYC04', N'Yêu cầu mua sắm thiết bị'),
('LYC05', N'Báo cáo tình trạng thiết bị mua sắm'),
('LYC06', N'Yêu cầu bàn giao'),
('LYC07', N'Báo cáo sự cố thiết bị');

INSERT INTO tbTiet (ID_Tiet, GioBD, ThoiLuong) VALUES
('T01', '07:00:00', 60),
('T02', '08:00:00', 60),
('T03', '09:00:00', 60),
('T04', '10:00:00', 60),
('T05', '11:00:00', 60),
('T06', '12:00:00', 60),
('T07', '13:00:00', 60),
('T08', '14:00:00', 60),
('T09', '15:00:00', 60),
('T10', '16:00:00', 60),
('T11', '17:00:00', 60),
('T12', '18:00:00', 60),
('T13', '19:00:00', 60),
('T14', '20:00:00', 60);

-- =============================================
-- 2. DỮ LIỆU CẤP 2 (NGƯỜI DÙNG & KHU VỰC) (GIỮ NGUYÊN CỦA BẠN)
-- =============================================
-- Admin (VT001) có toàn quyền, Sinh viên (VT007) chỉ được Xem
INSERT INTO tbQuyenHan_VaiTro (QuyenHanNo, VaiTroNo, TrangThai) VALUES
('QH001', 'VT001', 1), -- Admin được Xem
('QH002', 'VT001', 1), -- Admin được Thêm
('QH004', 'VT001', 1), -- Admin được Xóa
('QH007', 'VT001', 1), -- Admin Toàn quyền
('QH001', 'VT007', 1); -- Sinh viên được Xem 

INSERT INTO tbKhuVuc (ID_KhuVuc, CoSoNo, TenKhuVuc) VALUES
('KV01', 'CS01', N'Khu A'),
('KV02', 'CS01', N'Khu B'),
('KV03', 'CS01', N'Khu C'),
('KV04', 'CS01', N'Khu D (Xưởng)'),
('KV05', 'CS02', N'Khu A'),
('KV06', 'CS02', N'Khu B'),
('KV07', 'CS02', N'Hội Trường');

INSERT INTO tbNguoiDung (ID_NguoiDung, KhoaPhongBanNo, VaiTroNo, Email, MatKhau, HoTen, NgaySinh, TrangThaiTK) VALUES
('ND001', 'P01', 'VT001', 'admin@ute.udn.vn', '123', N'Nguyễn Quản Trị', '1990-01-01', 1),
('ND002', 'K01', 'VT003', 'truongkhoa.cntt@ute.udn.vn', '123', N'Trần Văn Trưởng', '1980-05-15', 1),
('ND003', 'K01', 'VT006', 'gv.cntt01@ute.udn.vn', '123', N'Lê Thị Giảng Viên', '1992-08-20', 1),
('ND004', 'K02', 'VT006', 'gv.cokhi01@ute.udn.vn', '123', N'Phạm Kỹ Thuật', '1985-03-10', 1),
('ND005', 'K01', 'VT007', 'sv.cntt01@ute.udn.vn', '123', N'Hoàng Sinh Viên', '2003-11-25', 1),
('ND006', 'P01', 'VT004', 'nv.csvc@ute.udn.vn', '123', N'Đỗ Cơ Sở', '1995-07-07', 1),
('ND007', 'P02', 'VT005', 'nv.khtc@ute.udn.vn', '123', N'Vũ Tài Chính', '1993-12-12', 1);

-- Ghi nhận thời gian hiệu lực của vai trò người dùng
INSERT INTO tbVaiTro_NguoiDung (VaiTroNo, NguoiDungNo, NgayHieuLuc, NgayHetHieuLuc) VALUES
('VT001', 'ND001', '2023-01-01', '2030-01-01'), -- ND001 làm Admin từ 2023 đến 2030
('VT003', 'ND002', '2023-05-01', '2028-05-01'), -- ND002 làm Trưởng khoa nhiệm kỳ 5 năm
('VT007', 'ND005', '2023-09-01', '2027-09-01'); -- ND005 là Sinh viên khóa 2023-2027

INSERT INTO tbThongBao (ID_ThongBao, NguoiTaoNo, TieuDe, NoiDung, LoaiThongBao) VALUES
('TB001', 'ND001', N'Lịch bảo trì hệ thống', N'Hệ thống sẽ bảo trì vào chủ nhật tuần này.', N'Hệ thống'),
('TB002', 'ND002', N'Nhắc nhở nộp báo cáo', N'Các giảng viên nộp báo cáo kiểm kê trước ngày 30.', N'Nhóm');

--Bảng tbThongBao_NguoiDung (Gửi thông báo cho ai)
INSERT INTO tbThongBao_NguoiDung (ThongBaoNo, NguoiNhanNo, TrangThaiDoc) VALUES
('TB001', 'ND005', 0), -- Gửi cho Sinh viên, chưa đọc
('TB002', 'ND003', 1); -- Gửi cho Giảng viên, đã đọc

INSERT INTO tbTaiLieu (ID_TaiLieu, DonViQuanLy, TenTaiLieu, SoHieu, NgayPhatHanh, DuongDanFile, TrangThaiApDung) VALUES
('TL001', 'P01', N'Quy định sử dụng tài sản công', '01/QD-CSVC', '2023-01-01', '/files/quydinh_tsc.pdf', 1),
('TL002', 'P02', N'Định mức chi tiêu mua sắm', '05/QD-KHTC', '2023-02-15', '/files/dinhmuc_2023.pdf', 1),
('TL003', 'P01', N'Biểu mẫu đề nghị sửa chữa', 'BM-03', '2022-06-01', '/files/bm_suachua.docx', 1),
('TL004', 'K01', N'Nội quy phòng máy tính', 'NQ-CNTT', '2023-08-20', '/files/noiquy_lab.pdf', 1),
('TL005', 'P01', N'Biểu mẫu bàn giao thiết bị', 'BM-05', '2022-06-01', '/files/bm_bangiao.docx', 1),
('TL006', 'K02', N'Hướng dẫn an toàn xưởng', 'HD-CK', '2023-01-10', '/files/hd_antoan.pdf', 1),
('TL007', 'P01', N'Quy trình thanh lý tài sản', 'QT-TL', '2023-12-01', '/files/qt_thanhly.pdf', 1);

-- =============================================
-- 3. DỮ LIỆU CẤP 3 (PHÒNG & THIẾT BỊ)
-- =============================================

INSERT INTO tbPhong (ID_Phong, KhuVucNo, TenPhong, SucChua) VALUES
('A101', 'KV01', N'Phòng học lý thuyết', 60),
('A102', 'KV01', N'Phòng học lý thuyết', 60),
('B201', 'KV02', N'Phòng máy 1', 40),
('B202', 'KV02', N'Phòng máy 2', 40),
('C305', 'KV03', N'Hội trường C', 200),
('D001', 'KV04', N'Xưởng thực hành CNC', 30),
('E101', 'KV05', N'Phòng Lab Cơ bản', 50);

-- Lớp thực hành CSDL học tại phòng B201 vào tiết 1 thứ 2
INSERT INTO tbLopHocPhan (ID_LHP, PhongNo, TietNo, Thu, SiSo, TenLHP, HocKy) VALUES
('LHP01', 'B201', 'T01', N'Thứ 2', 40, N'Thực hành CSDL Nhóm 35', N'1/2025-2026'),
('LHP02', 'D001', 'T06', N'Thứ 3', 30, N'Thực tập CNC', N'1/2025-2026');

INSERT INTO tbThietBi (ID_ThietBi, DanhMucNo, NhaCCNo, KhoaPhongBan, TenTB, TrangThaiThietBi, Gia, ThongSoKT, SoSeri) VALUES
('PC01', 'DM01', 'NCC001', 'K01', N'PC Dell Optiplex 7090', N'Sẵn sàng', 15000000, N'Core i7-12700, RAM 16GB, SSD 512GB', 'SN-DELL-001'),
('PC02', 'DM01', 'NCC001', 'K01', N'Workstation HP Z4', N'Đang sử dụng', 45000000, N'Xeon W-2223, RAM 32GB, Quadro P2200', 'SN-HP-WORK-01'),
('PRJ01', 'DM02', 'NCC002', 'P01', N'Máy chiếu Panasonic PT-LB', N'Sẵn sàng', 18000000, N'4100 Ansi Lumens, XGA, HDMI', 'SN-PANA-99'),
('CNC01', 'DM05', 'NCC004', 'K02', N'Máy phay CNC Mini', N'Sửa chữa', 120000000, N'Hành trình 300x400mm, Trục chính 24000rpm', 'SN-CNC-X1'),
('HAN01', 'DM05', 'NCC004', 'K02', N'Máy hàn TIG Jasic', N'Sẵn sàng', 8500000, N'200A, Hàn inox/sắt', 'SN-HAN-JS01'),
('OSC01', 'DM04', 'NCC001', 'K03', N'Dao động ký Tektronix', N'Sẵn sàng', 12500000, N'100MHz, 2 Kênh, Digital Storage', 'SN-TEK-105'),
('PLC01', 'DM06', 'NCC001', 'K03', N'Bộ thực hành PLC Mitsubishi', N'Hư hỏng', 25000000, N'FX3U, Kèm module Analog', 'SN-PLC-M01');
GO

INSERT INTO tbPhong_ThietBi (ThietBiNo, PhongNo, NgayHieuLuc) VALUES
('PC01', 'B201', '2026-05-01'),
('PC02', 'B201', '2026-04-10'),
('PRJ01', 'A101', '2026-05-15'),
('CNC01', 'D001', '2026-03-01'),
('HAN01', 'D001', '2026-06-20'),
('PC01', 'B202', '2026-02-01'), 
('OSC01', 'E101', '2026-07-10');

INSERT INTO tbThietBi_NguoiDung (ThietBiNo, NguoiDungNo, TrangThai) VALUES
('PC02', 'ND002', 1), -- Trưởng khoa dùng Workstation
('PC02', 'ND003', 0), 
('PC01', 'ND005', 1), -- Sinh viên mượn PC
('OSC01', 'ND004', 1),
('PRJ01', 'ND006', 1),-- CSVC giữ máy chiếu
('CNC01', 'ND004', 1);

INSERT INTO tbYeuCau (ID_YeuCau, NguoiTaoNo, LoaiYeuCauNo, TrangThai, NgayTao, NgayDuKienXL, NgayXuLy) VALUES
('YC001', 'ND005', 'LYC01', N'Chờ xử lý', '2025-09-01', '2025-09-02', NULL),
('YC002', 'ND002', 'LYC02', N'Đã duyệt', '2025-09-05', '2025-09-10', '2025-09-08'),
('YC003', 'ND003', 'LYC03', N'Chờ xử lý', '2025-09-06', '2025-09-07', NULL),
('YC004', 'ND004', 'LYC01', N'Đã duyệt', '2025-09-07', '2025-09-07', '2025-09-07'),
('YC005', 'ND002', 'LYC02', N'Từ chối', '2025-09-10', '2025-09-15', '2025-09-12'),
('YC006', 'ND006', 'LYC03', N'Đã duyệt', '2025-09-11', '2025-09-12', '2025-09-11'),
('YC007', 'ND005', 'LYC01', N'Đã hủy', '2025-09-12', '2025-09-13', NULL);

INSERT INTO tbChiTietYeuCau_SuDung (YeuCauNo, ThietBiNo, TietBDNo, TietKTNo, LyDoMuon, NgayMuon) VALUES
('YC001', 'PC01', 'T01', 'T03', N'Học thực hành', '2026-09-03'),
('YC001', 'PC02', 'T01', 'T03', N'Học thực hành', '2026-09-03'),
('YC004', 'CNC01', 'T06', 'T07', N'Dạy thực hành CNC', '2026-09-08'),
('YC007', 'OSC01', 'T01', 'T02', N'Làm đồ án', '2026-09-15'),
('YC004', 'HAN01', 'T01', 'T05', N'Mượn đi hội thảo', '2026-09-09'),
('YC001', 'OSC01', 'T04', 'T05', N'Đo đạc mạch điện', '2026-09-03'),
('YC007', 'PC01', 'T01', 'T05', N'Mượn bù', '2026-09-16');

-- YC005 trong code trước là loại LYC02 (Ngoài khoa), ta thêm chi tiết vào đây
INSERT INTO tbChiTietYeuCauSuDung_NgoaiKhoa (ID_ChiTiet, YeuCauNo, KhoaPhongBanNo, TenTB, ThongSoKT, LyDo) VALUES
('CTNK01', 'YC005', 'K02', N'Máy hàn TIG', N'Dòng hàn 200A', N'Mượn máy hàn của Khoa Cơ khí để thi công Robocon');

INSERT INTO tbChiTietYeuCau_Mua (ID_ChiTiet, YeuCauNo, TenTB, SoLuong, ThongSoKT, GiaDuKien, MucDoUuTien, DonViTinh, LyDo) VALUES
('CTM01', 'YC002', N'Máy tính Dell Vostro', 10, N'Core i5 12th', 15000000, N'Cao', N'Bộ', N'Nâng cấp phòng B201'),
('CTM02', 'YC002', N'Chuột máy tính', 20, N'Logitech B100', 100000, N'Thấp', N'Cái', N'Thay thế chuột hỏng'),
('CTM03', 'YC005', N'Màn hình 27 inch', 5, N'Dell Ultrasharp', 8000000, N'Trung bình', N'Cái', N'Dùng cho GV'),
('CTM04', 'YC005', N'Loa hội trường', 2, N'JBL 1000W', 25000000, N'Thấp', N'Bộ', N'Trang bị hội trường C'),
('CTM05', 'YC002', N'Dây mạng CAT6', 3, N'Cuộn 300m', 2000000, N'Cao', N'Cái', N'Đi lại dây mạng'),
('CTM06', 'YC005', N'RAM 16GB', 10, N'DDR4 Bus 3200', 800000, N'Trung bình', N'Cái', N'Nâng cấp RAM'),
('CTM07', 'YC002', N'Ổ cứng SSD', 10, N'Samsung 500GB', 1200000, N'Cao', N'Cái', N'Thay HDD cũ');

INSERT INTO tbChiTietYeuCau_SuaChua (YeuCauNo, ThietBiNo, HinhAnh, MoTa, LyDo) VALUES
('YC003', 'PRJ01', 'img/tb003_hong.jpg', N'Bóng đèn mờ, quạt kêu to', N'Hư hỏng linh kiện'),
('YC006', 'PLC01', 'img/tb005_loi.jpg', N'Không lạnh, chảy nước', N'Lâu ngày không vệ sinh'),
('YC003', 'PC01', NULL, N'Không lên nguồn', N'Hư nguồn'),
('YC006', 'CNC01', 'img/cnc_loi.jpg', N'Trục Z bị kẹt', N'Kẹt cơ khí'),
('YC003', 'PC02', NULL, N'Màn hình xanh', N'Lỗi RAM'),
('YC006', 'OSC01', NULL, N'Sai số lớn', N'Cần hiệu chuẩn'),
('YC003', 'HAN01', NULL, N'Pin chai', N'Thay pin mới');

INSERT INTO tbChiTietYeuCau_BanGiao (YeuCauNo, ThietBiNo, PhongBanKhoaNo, NgayBanGiao, NgayNhanThucTe, TrangThaiBanGiao, NguoiBanGiaoNo, NguoiNhanNo, GhiChu) VALUES
('YC002', 'PC01', 'K01', '2025-09-12', '2025-09-12', N'Đã giao', 'ND006', 'ND002', N'Bàn giao đúng hạn'),
('YC002', 'PC02', 'K01', '2025-09-12', '2025-09-12', N'Đã giao', 'ND006', 'ND002', NULL),
('YC006', 'PLC01', 'P01', '2025-09-13', '2025-09-13', N'Đã giao', 'ND006', 'ND006', N'Đã sửa xong'),
('YC002', 'HAN01', 'K01', '2025-09-14', '2025-09-15', N'Chưa giao', 'ND006', 'ND002', N'Chờ cài win'),
('YC006', 'CNC01', 'K02', '2025-09-14', '2025-09-14', N'Đã giao', 'ND006', 'ND004', NULL),
('YC002', 'OSC01', 'K03', '2025-09-15', '2025-09-15', N'Đã giao', 'ND006', 'ND004', NULL),
('YC002', 'PRJ01', 'K01', '2025-09-12', '2025-09-12', N'Đã giao', 'ND006', 'ND002', NULL);
GO

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

    INSERT INTO tbKhoa_PhongBan(ID_KhoaPhongBan, TenPhongBanKhoa)
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

    INSERT INTO tbThongBao(ID_ThongBao, TieuDe, LoaiThongBao, NoiDung, NgayTao)
    SELECT @NewID, TieuDe, LoaiThongBao, NoiDung, NgayTao
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

    INSERT INTO tbNhaCungCap(ID_NhaCC, TenNhaCC, LoaiDichVu, DiaChi, SDT)
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
        SET KhoaPhongBan = i.PhongBanKhoaNo
        FROM tbThietBi tb 
        INNER JOIN inserted i ON tb.ID_ThietBi = i.ThietBiNo
        INNER JOIN deleted d ON i.YeuCauNo = d.YeuCauNo AND i.ThietBiNo = d.ThietBiNo
        WHERE i.TrangThaiBanGiao = N'Đã giao'

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

-- Thủ tục thống kê thiết bị theo khoa
GO
CREATE PROCEDURE pr_ThongKeThietBiTheoKhoa
AS
BEGIN
    SELECT k.TenPhongBanKhoa, tb.TrangThaiThietBi, COUNT(tb.ID_ThietBi) AS SoLuong, SUM(tb.Gia) AS TongGiaTri
    FROM tbKhoa_PhongBan k
    LEFT JOIN tbThietBi tb ON k.ID_KhoaPhongBan = tb.KhoaPhongBan
    GROUP BY k.TenPhongBanKhoa, tb.TrangThaiThietBi
    ORDER BY k.TenPhongBanKhoa;
END;
GO
EXEC pr_ThongKeThietBiTheoKhoa;

-- Thủ tục thống kê số lượng yêu cầu theo mỗi tháng của năm (được truyền vào)
GO
CREATE PROCEDURE pr_ThongKeYeuCauTheoThang
    @Nam INT
AS
BEGIN
    SELECT 
        MONTH(NgayTao) AS Thang,
        l.TenLoaiYeuCau,
        COUNT(y.ID_YeuCau) AS TongSoYeuCau,
        SUM(CASE WHEN y.TrangThai = N'Đã duyệt' THEN 1 ELSE 0 END) AS SoLuongDaDuyet
    FROM tbYeuCau y
    JOIN tbLoaiYeuCau l ON y.LoaiYeuCauNo = l.ID_LoaiYeuCau
    WHERE YEAR(NgayTao) = @Nam
    GROUP BY MONTH(NgayTao), l.TenLoaiYeuCau
    ORDER BY Thang;
END;
GO
-- Thống kê yêu cầu của năm 2025
EXEC pr_ThongKeYeuCauTheoThang @Nam = 2025;

-- Thủ tục lấy danh sách các thiết bị hư hỏng/sửa chữa
GO
CREATE PROCEDURE pr_BaoCaoThietBiSuCo
AS
BEGIN
    SELECT tb.ID_ThietBi, tb.TenTB, tb.TrangThaiThietBi, ncc.TenNhaCC, ncc.SDT, sc.MoTa AS NoiDungHuHong
    FROM tbThietBi tb
    LEFT JOIN tbChiTietYeuCau_SuaChua sc ON tb.ID_ThietBi = sc.ThietBiNo
    LEFT JOIN tbNhaCungCap ncc ON tb.NhaCCNo = ncc.ID_NhaCC
    WHERE tb.TrangThaiThietBi IN (N'Hư hỏng', N'Sửa chữa');
END;
GO
EXEC pr_BaoCaoThietBiSuCo

