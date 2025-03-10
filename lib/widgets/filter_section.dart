import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final Function(String) onSearchQueryChanged;
  final Function(String?) onUniversityChanged;
  final Function(String?) onTermChanged;
  final Function(String?) onYearChanged;
  final Function(String?) onTypeChanged;

  FilterSection({
    required this.onSearchQueryChanged,
    required this.onUniversityChanged,
    required this.onTermChanged,
    required this.onYearChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by Lecture Name',
              border: OutlineInputBorder(),
            ),
            onChanged: onSearchQueryChanged,
          ),
          SizedBox(height: 10),
          ExpansionTile(
            title: Text('Advanced Filters',
                style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              DropdownButtonFormField<String>(
                items: [null, 'มหาวิทยาลัยเชียงใหม่', 'มหาวิทยาลัยกรุงเทพ']
                    .map((university) => DropdownMenuItem(
                          value: university,
                          child: Text(university ?? 'University'),
                        ))
                    .toList(),
                onChanged: onUniversityChanged,
                decoration: InputDecoration(
                  labelText: 'University',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: [null, '1', '2', '3']
                    .map((term) => DropdownMenuItem(
                          value: term,
                          child: Text(term == null ? 'Term' : 'Term $term'),
                        ))
                    .toList(),
                onChanged: onTermChanged,
                decoration: InputDecoration(
                  labelText: 'Term',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: [
                  null,
                  ...List.generate(26, (index) => (2000 + index).toString())
                ]
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year ?? 'Year'),
                        ))
                    .toList(),
                onChanged: onYearChanged,
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: [null, 'Mid Term', 'Final', 'อื่นๆ']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type ?? 'Type'),
                        ))
                    .toList(),
                onChanged: onTypeChanged,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
