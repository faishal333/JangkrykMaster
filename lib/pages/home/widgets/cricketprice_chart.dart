import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CricketPriceWidget extends StatefulWidget {
  const CricketPriceWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CricketPriceWidgetState createState() => _CricketPriceWidgetState();
}

class _CricketPriceWidgetState extends State<CricketPriceWidget> {
  String selectedType = "madu alam"; // Default selection
  DateTime today = DateTime.now(); // Get today's date

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Stack(
        children: [
          // Judul dan Subteks
          const Positioned(
            top: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update hari ini : ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  'Harga telur : Rp 120.000 / kg\nHarga jangkrik: Rp 37.000 / kg',
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Tanggal
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              '${today.day}-${today.month}-${today.year}',
              style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ),
          // Tombol Pilihan Jenis Jangkrik
          Positioned(
            top: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['tj sliring', 'tj madu kunyit', 'tj kalung','sliring', 'madu kunyit', 'kalung']
                  .map((type) => Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: 
                        SizedBox(
                          height: 25, 
                        child: 
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedType = type;
                            });
                          },
                          child: Text(type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                        ),

                        ),
                        

                        

                      ))
                  .toList(),
            ),
          ),
          // Grafik Harga
          Positioned(
            top: 100,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 12,
                  minY: 0,
                  maxY: 150000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 120000), // Data dummy harga telur
                        const FlSpot(1, 130000),
                        const FlSpot(2, 125000),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                    ),
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 37000), // Data dummy harga jangkrik
                        const FlSpot(1, 36000),
                        const FlSpot(2, 38000),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
