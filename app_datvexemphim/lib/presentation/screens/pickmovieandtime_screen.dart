// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';

// class PickmovieandtimeScreen extends StatefulWidget {
//   final String idRap;

//   const PickmovieandtimeScreen({Key? key, required this.idRap}) : super(key: key);

//   @override
//   _PickmovieandtimeScreen createState() => _PickmovieandtimeScreen();
// }

// class _PickmovieandtimeScreen extends State<PickmovieandtimeScreen> {
//   List<dynamic> lichChieuList = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchLichChieu();
//   }

//   Future<void> fetchLichChieu() async {
//     try {
//       final response = await Dio().post(
//         'https://your-api-url.com/all-lich-chieu/rap',
//         data: {'idRap': widget.idRap},
//       );
      
//       if (response.statusCode == 200) {
//         setState(() {
//           lichChieuList = response.data['lich_chieu'];
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Lỗi khi lấy lịch chiếu: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chọn Phim & Giờ Chiếu")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: lichChieuList.length,
//               itemBuilder: (context, index) {
//                 final item = lichChieuList[index];
//                 return Card(
//                   margin: EdgeInsets.all(8),
//                   child: ListTile(
//                     title: Text(item['id_phim']['ten_phim']),
//                     subtitle: Text("Phòng: ${item['id_phong']['ten_phong']}"),
//                     trailing: Text(item['thoi_gian_chieu']),
//                     onTap: () {
//                       Navigator.pushNamed(
//                         context,
//                         '/pickseat',
//                         arguments: {
//                           'idLichChieu': item['_id'],
//                           'tenPhim': item['id_phim']['ten_phim'],
//                           'phongChieu': item['id_phong']['ten_phong'],
//                           'thoiGian': item['thoi_gian_chieu'],
//                         },
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }






// import 'package:app_datvexemphim/presentation/screens/pickseat_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:app_datvexemphim/api/api_service.dart';


// class PickMovieAndTimeScreen extends StatefulWidget {
//   final Map<String, dynamic> cinema;

//   const PickMovieAndTimeScreen({Key? key, required this.cinema}) : super(key: key);

//   @override
//   _PickMovieAndTimeScreenState createState() => _PickMovieAndTimeScreenState();
// }

// class _PickMovieAndTimeScreenState extends State<PickMovieAndTimeScreen> {
//   List<dynamic> movies = []; // Danh sách phim đang chiếu tại rạp
//   Map<String, List<String>> showtimes = {}; // Lịch chiếu theo từng phim
//   bool isLoading = true;
//   String? selectedMovie; // Phim được chọn

//   @override
//   void initState() {
//     super.initState();
//     fetchMoviesAndShowtimes();
//   }

//   // TODO: Gọi API để lấy danh sách phim đang chiếu và suất chiếu của từng phim
//   Future<void> fetchMoviesAndShowtimes() async {
//     try {
//       Response? response = await ApiService.get("/all-lich-chieus?rap_id=${widget.cinema["_id"]}");
//       if (response != null && response.statusCode == 200) {
//         setState(() {
//           movies = response.data.map((lich) => lich["phim"]).toSet().toList();
//           showtimes = _groupShowtimesByMovie(response.data);
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Lỗi khi lấy lịch chiếu: $e");
//     }
//   }

//   // Nhóm suất chiếu theo từng phim
//   Map<String, List<String>> _groupShowtimesByMovie(List<dynamic> schedules) {
//     Map<String, List<String>> grouped = {};
//     for (var schedule in schedules) {
//       String movieTitle = schedule["phim"]["ten_phim"];
//       String time = schedule["gio_chieu"];
//       if (!grouped.containsKey(movieTitle)) {
//         grouped[movieTitle] = [];
//       }
//       grouped[movieTitle]!.add(time);
//     }
//     return grouped;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff1B1B1B),
//       appBar: AppBar(
//         title: Text("Chọn Phim & Suất Chiếu"),
//         backgroundColor: Colors.black,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator()) // Hiển thị vòng xoay khi tải
//           : Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       labelText: "Chọn phim",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     value: selectedMovie,
//                     items: movies.map((movie) {
//                       return DropdownMenuItem<String>(
//                         value: movie["ten_phim"],
//                         child: Text(movie["ten_phim"]),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedMovie = value;
//                       });
//                     },
//                   ),
//                 ),

//                 // Danh sách suất chiếu
//                 Expanded(
//                   child: selectedMovie == null
//                       ? Center(child: Text("Vui lòng chọn phim", style: TextStyle(color: Colors.white)))
//                       : GridView.builder(
//                           padding: EdgeInsets.all(16),
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3, // Hiển thị 3 suất chiếu trên mỗi hàng
//                             childAspectRatio: 2.5,
//                             crossAxisSpacing: 10,
//                             mainAxisSpacing: 10,
//                           ),
//                           itemCount: showtimes[selectedMovie]?.length ?? 0,
//                           itemBuilder: (context, index) {
//                             String time = showtimes[selectedMovie]![index];
//                             // return ElevatedButton(
//                             //   style: ElevatedButton.styleFrom(
//                             //     backgroundColor: Colors.redAccent,
//                             //   ),
//                             //   onPressed: () {
//                             //     // TODO: Chuyển sang trang chọn ghế với thông tin phim, rạp và suất chiếu
//                             //     Navigator.push(
//                             //       context,
//                             //       MaterialPageRoute(
//                             //         builder: (context) => PickseatScreen(
//                             //           cinema: widget.cinema,
//                             //           movie: selectedMovie!,
//                             //           showtime: time,
//                             //         ),
//                             //       ),
//                             //     );
//                             //   },
//                             //   child: Text(time, style: TextStyle(fontSize: 16)),
//                             // );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:app_datvexemphim/api/api_service.dart';

// class PickMovieAndTimeScreen extends StatefulWidget {
//   final Map<String, dynamic> cinema;

//   const PickMovieAndTimeScreen({Key? key, required this.cinema}) : super(key: key);

//   @override
//   _PickMovieAndTimeScreenState createState() => _PickMovieAndTimeScreenState();
// }

// class _PickMovieAndTimeScreenState extends State<PickMovieAndTimeScreen> {
//   List<dynamic> movies = [];
//   Map<String, List<dynamic>> showtimes = {};
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchMoviesAndSchedules();
//   }

//  Future<void> fetchMoviesAndSchedules() async {
//     Response? response = await ApiService.post(
//       "/all-lich-chieu/rap",
//       { "_id": widget.cinema } // Truyền ID rạp vào API
//     );

//       if (response != null && response.statusCode == 200) {
//         setState(() {
//           movies = response.data.map((lich) => lich["phim"]).toSet().toList();
//           showtimes = _groupShowtimesByMovie(response.data);
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Lỗi khi lấy lịch chiếu theo rạp: $e");
//     }
//   }

//   Map<String, List<dynamic>> _groupShowtimesByMovie(List<dynamic> data) {
//     Map<String, List<dynamic>> grouped = {};
//     for (var lich in data) {
//       String movieName = lich["phim"] ?? "";
//       if (!grouped.containsKey(movieName)) {
//         grouped[movieName] = [];
//       }
//       grouped[movieName]?.add(lich);
//     }
//     return grouped;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xff1B1B1B),
//       appBar: AppBar(
//         title: Text("Chọn Phim & Suất Chiếu"),
//         backgroundColor: Colors.black,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               padding: EdgeInsets.all(16),
//               itemCount: movies.length,
//               itemBuilder: (context, index) {
//                 String movie = movies[index];
//                 return MovieCard(movie: movie, showtimes: showtimes[movie] ?? []);
//               },
//             ),
//     );
//   }
// }

// class MovieCard extends StatelessWidget {
//   final String movie;
//   final List<dynamic> showtimes;

//   const MovieCard({Key? key, required this.movie, required this.showtimes}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white10,
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               movie,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 6),
//             Wrap(
//               spacing: 10,
//               children: showtimes.map((showtime) {
//                 return ElevatedButton(
//                   onPressed: () {
//                     // Chuyển đến trang chọn ghế
//                   },
//                   child: Text(showtime["gio_chieu"] ?? "--:--"),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:app_datvexemphim/api/api_service.dart';
import 'package:dio/dio.dart';

class PickCinemaAndTimeScreen extends StatefulWidget {
  final String cinemaId; // ID của rạp

  const PickCinemaAndTimeScreen({Key? key, required this.cinemaId}) : super(key: key);

  @override
  _PickCinemaAndTimeScreenState createState() => _PickCinemaAndTimeScreenState();
}

class _PickCinemaAndTimeScreenState extends State<PickCinemaAndTimeScreen> {
  List<dynamic> movies = []; // Danh sách phim
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMoviesAndSchedules();
  }

  // Gọi API lấy danh sách phim và lịch chiếu của rạp
  Future<void> fetchMoviesAndSchedules() async {
    Response? response = await ApiService.post(
      "/all-lich-chieu/rap",
      { "_id": widget.cinemaId } // Truyền ID rạp vào API
    );

    if (response != null && response.statusCode == 200) {
      setState(() {
        movies = response.data["movies"]; // Giả sử API trả về danh sách phim
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn Phim & Lịch Chiếu"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : movies.isEmpty
              ? Center(child: Text("Không có phim nào!", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    var movie = movies[index];
                    return MovieCard(movie: movie);
                  },
                ),
    );
  }
}

// Widget hiển thị phim
class MovieCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie["ten_phim"] ?? "Không có tên",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Thời lượng: ${movie["thoi_luong"] ?? "N/A"} phút",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 6),
            // Lịch chiếu
            Wrap(
              spacing: 8,
              children: (movie["lich_chieu"] as List<dynamic>)
                  .map<Widget>((schedule) => Chip(
                        label: Text(schedule["thoi_gian"] ?? "N/A"),
                        backgroundColor: Colors.redAccent,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
