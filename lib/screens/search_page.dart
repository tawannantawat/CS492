import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cheese_sheet/screens/lecture_details_page.dart';
import 'package:cheese_sheet/widgets/filter_section.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  String? selectedUniversity;
  String? selectedTerm;
  String? selectedYear;
  String? selectedType;

  // ✅ ข้อมูลจำลอง (Mock Data)
  List<Map<String, dynamic>> mockLectures = [
    {
      'id': 'mock1',
      'title': 'Test with no database',
      'university': 'มหาวิทยาลัยเชียงใหม่',
      'term': '1',
      'year': '2023',
      'type': 'Mid Term',
      'price': 50,
      'rating': 4.5,
      'pdfUrl': 'assets/pdfs/data_structures_midterm.pdf',
    },
  ];

  Future<List<Map<String, dynamic>>> _fetchLectures() async {
    final response = await Supabase.instance.client.from('lectures').select(
        'id, title, university, term, year, type, price, rating, pdfUrl');

    if (response == null) {
      throw 'เกิดข้อผิดพลาดในการโหลดข้อมูลจาก Supabase';
    }

    return List<Map<String, dynamic>>.from(response);
  }

  List<Map<String, dynamic>> _getFilteredLectures(
      List<Map<String, dynamic>> allLectures,
      {bool includeMockData = true}) {
    return allLectures.where((lecture) {
      bool isMockData = lecture['id'].toString().startsWith('mock');
      return (searchQuery.isEmpty ||
              lecture['title']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase())) &&
          (selectedUniversity == null ||
              lecture['university'] == selectedUniversity) &&
          (selectedTerm == null || lecture['term'] == selectedTerm) &&
          (selectedYear == null || lecture['year'] == selectedYear) &&
          (selectedType == null || lecture['type'] == selectedType) &&
          (includeMockData || !isMockData);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ค้นหา Lecture', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFF5C842),
        elevation: 0,
      ),
      body: Column(
        children: [
          FilterSection(
            onSearchQueryChanged: (value) =>
                setState(() => searchQuery = value),
            onUniversityChanged: (value) =>
                setState(() => selectedUniversity = value),
            onTermChanged: (value) => setState(() => selectedTerm = value),
            onYearChanged: (value) => setState(() => selectedYear = value),
            onTypeChanged: (value) => setState(() => selectedType = value),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchLectures(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> allLectures = [
                  //...mockLectures,
                  ...snapshot.data!,
                ];

                var filteredLectures =
                    _getFilteredLectures(allLectures, includeMockData: true);

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredLectures.length,
                  itemBuilder: (context, index) {
                    var lecture = filteredLectures[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LectureDetailsPage(lecture: lecture),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Colors.grey.shade300,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  size: 50,
                                  color: Color(0xFFF5C842),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                lecture['title'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                lecture['university'] ?? 'N/A',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '฿${lecture['price']}',
                                    style: TextStyle(
                                      color: Color(0xFFF5C842),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      Text(
                                        '${lecture['rating']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
