import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceChartWidget extends StatefulWidget {
  final List<double> harga; // Data untuk harga
  final List<double> volume; // Data untuk volume

  const PriceChartWidget({required this.harga, required this.volume, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PriceChartWidgetState createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  String? _selectedGrafik = 'tj sliring'; // Variabel untuk menyimpan pilihan jenis jangkrik

  @override
  Widget build(BuildContext context) {
    double maxPrice = widget.harga.reduce((a, b) => a > b ? a : b); // Menentukan harga maksimal
    double maxVolume =  widget.volume.reduce((a, b) => a > b ? a : b); // Menentukan harga maksimal
    maxVolume = maxVolume<10?10:maxVolume;

    return Stack(
      children: [
        // Judul dan Subteks
        const Positioned(
          top: 0,
          left: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market hari ini',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
              Text(
                'tj : Rp 120.000 / kg\njangkrik : Rp 37.000 / kg',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),

  Positioned(
  top: -15,
  right: 0,
  child: 
  
      DropdownButton<String>(
        hint: const Text('Pilih Grafik', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w300),),
        style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w400),
        value: _selectedGrafik,
        onChanged: (String? newValue) {
          setState(() {
            _selectedGrafik = newValue; // Perbarui nilai yang dipilih
          });

          // Panggil fungsi sesuai dengan pilihan
          switch (newValue) {
            case 'tj sliring':
              print('Fungsi untuk tj sliring dipanggil');
              break;
            case 'jk sliring':
              print('Fungsi untuk jk sliring dipanggil');
              break;
            case 'tj madu kunyit':
              print('Fungsi untuk tj madu kunyit dipanggil');
              break;
            case 'jk madu kunyit':
              print('Fungsi untuk jk madu kunyit dipanggil');
              break;
            case 'tj gengong':
              print('Fungsi untuk tj gengong dipanggil');
              break;
            case 'jk gengong':
              print('Fungsi untuk jk gengong dipanggil');
              break;
            default:
              break;
          }
        },
        items: const [
          DropdownMenuItem(value: 'tj sliring', child: Text('tj sliring')),
          DropdownMenuItem(value: 'jk sliring', child: Text('jk sliring')),
          DropdownMenuItem(value: 'tj madu kunyit', child: Text('tj madu kunyit')),
          DropdownMenuItem(value: 'jk madu kunyit', child: Text('jk madu kunyit')),
          DropdownMenuItem(value: 'tj gengong', child: Text('tj gengong')),
          DropdownMenuItem(value: 'jk gengong', child: Text('jk gengong')),
        ],
      )
),

        // Volume Bars (Background)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 45 , 0, 8),
          child: 
          BarChart(
            BarChartData(
              barGroups: widget.volume.asMap().entries.map((entry) {
                int index = entry.key;
                double value = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      width: 4, // Atur lebar batang sesuai kebutuhan
                      color: Colors.grey.withOpacity(0.3 + (value/maxVolume)*0.7), // Warna background transparan
                    ),
                  ],
                );
              }).toList(),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 30, // Atur ukuran ruang untuk angka di kanan
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Menghilangkan label X-axis
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 10, // Atur ukuran ruang untuk angka di kanan
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Atur ukuran ruang untuk angka di kanan
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
    
        
        // Price Line Chart (Foreground)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 45, 0, 8),
          child: 
          LineChart(
            LineChartData(
              minY: 0,
              maxY: maxPrice,
              lineBarsData: [
                LineChartBarData(
                  spots:  widget.harga.asMap().entries.map((entry) {
                    int index = entry.key;
                    double yValue = entry.value;
                    return FlSpot(index.toDouble(), yValue);
                  }).toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 30, // Atur ukuran ruang untuk angka di kanan
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Menghilangkan label X-axis
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 10, // Atur ukuran ruang untuk angka di kanan
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.transparent,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Atur ukuran ruang untuk angka di kanan
                    getTitlesWidget: (value, meta) {
                      return 
                      Padding(padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: 
                      Text(
                        '${(value/1000).toStringAsFixed(0)}K',
                        style: const TextStyle(fontSize: 10, color: Colors.black,),
                      ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
    
        ),

      ],
    );
  }
}
