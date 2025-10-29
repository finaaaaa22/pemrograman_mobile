import 'dart:ffi';
import 'dart:io';

// KELAS ABSTRAK
abstract class Transportasi {
  String id;
  String nama;
  double tarifDasar;
  Transportasi(this.id, this.nama, this.tarifDasar);
  double get tarifdasar => tarifDasar;
  double hitungTarif(int jumlahPenumpang);
}

// taksi
class Taksi extends Transportasi {
  double jarak; // jarak perjalanan
  Taksi(String id, String nama, double tarifDasar, this.jarak)
      : super(id, nama, tarifDasar);
  double hitungTarif(int jumlahPenumpang) => tarifDasar * jarak;
}

// kelas Bus
class Bus extends Transportasi {
  bool adaWifi;
  Bus(String id, String nama, double tarifDasar, this.adaWifi)
      : super(id, nama, tarifDasar);
  double hitungTarif(int jumlahPenumpang) =>
      tarifDasar * jumlahPenumpang + (adaWifi ? 5000 : 0);
}

// kelas Pesawat
class Pesawat extends Transportasi {
  String kelas;
  Pesawat(String id, String nama, double tarifDasar, this.kelas)
      : super(id, nama, tarifDasar);
  double hitungTarif(int jumlahPenumpang) =>
      tarifDasar * jumlahPenumpang * (kelas == "Bisnis" ? 1.5 : 1.0);
}

// kelas pemesanan
class Pemesanan {
  String idPemesanan;
  String namaPelanggan;
  Transportasi transportasi;
  int jumlahPenumpang;
  double totalTarif;

  Pemesanan(this.idPemesanan, this.namaPelanggan, this.transportasi,
      this.jumlahPenumpang)
      : totalTarif = transportasi.hitungTarif(jumlahPenumpang);
  void cetakStruk() {
    print('---$namaPelanggan---');
    print('Transportasi: ${transportasi.nama}');
    print('JumlahPenumpang: ${jumlahPenumpang}');
    print('Total Tarif: Rp$totalTarif\n');
  }
}

// FUNGSI GLOBAL

Pemesanan buatPemesanan(
    Transportasi t, String nama, int jumlahPenumpang, String idPemesanan) {
  return Pemesanan(idPemesanan, nama, t, jumlahPenumpang);
}

// fungsi untuk menampilkan semua pesanan

void tampilSemuaPemesanan(List<Pemesanan> daftar) {
  print("====RIWAYAT SEMUA PEMESANAN====");
  for (var p in daftar) {
    p.cetakStruk();
  }
}

//fungsi main program

void main() {
  List<Pemesanan> daftarPemesanan = [];

  Transportasi taksi1 = Taksi("002", "Taksi Pink", 50000, 10);
  Transportasi bus1 = Bus("002", "Bus Safina", 20000, true);
  Transportasi pesawat1 = Pesawat("004", "Garuda", 500000, "Bisnis");
  List<Transportasi> transport = [taksi1, bus1, pesawat1];
  print("====SELAMAT DATANG DI SMARTRIDE====");
  for (int i = 0; i < 2; i++) {
    stdout.write("Nama Pelanggan:");
    String nama = stdin.readLineSync() ?? '';
    print("Pilih Transportasi(1:Taksi, 2:Bus, 3:Pesawat):");
    int pilih = int.parse(stdin.readLineSync() ?? '1');
    stdout.write("Jumlah Penumpang:");
    int jumlah = int.parse(stdin.readLineSync() ?? '1');
    String idPemesanan = 'PSN00${i + 1}';
    Pemesanan p =
        buatPemesanan(transport[pilih - 1], nama, jumlah, idPemesanan);
    daftarPemesanan.add(p);
    print("Pemesanan");
  }
  tampilSemuaPemesanan(daftarPemesanan);
}
