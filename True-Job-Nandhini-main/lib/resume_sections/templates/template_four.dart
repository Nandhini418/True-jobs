import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truejobs/models/resume_data.dart';

class TemplateFour extends StatelessWidget {
  final ResumeData data;
  
  const TemplateFour({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (data.hasPhoto)
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                      image: data.profileImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(data.profileImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: data.profileImagePath == null
                        ? const Icon(Icons.person, color: Colors.grey, size: 30)
                        : null,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.fullName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w300, // Light font
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.role,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(data.phone, style: const TextStyle(fontSize: 8, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(data.email, style: const TextStyle(fontSize: 8, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(data.address, style: const TextStyle(fontSize: 8, color: Colors.black87)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 2, color: Colors.black87),
            const SizedBox(height: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('SUMMARY'),
                  Text(
                    data.summary,
                    style: const TextStyle(fontSize: 10, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSectionTitle('EXPERIENCE'),
                  ...data.experience.map((exp) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(exp.duration, style: const TextStyle(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.jobTitle,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(exp.company, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                              const SizedBox(height: 4),
                              ...exp.description.split('. ').where((s) => s.trim().isNotEmpty).map(
                                (point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('- ', style: TextStyle(fontSize: 10)),
                                      Expanded(
                                        child: Text(
                                          point.trim() + (point.endsWith('.') ? '' : '.'),
                                          style: const TextStyle(fontSize: 10, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 4),
                  
                  _buildSectionTitle('EDUCATION'),
                  ...data.education.map((edu) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(edu.year, style: const TextStyle(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(edu.institution, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  if (data.projects.isNotEmpty) ...[
                    _buildSectionTitle('PROJECTS'),
                    ...data.projects.map((proj) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(proj.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(proj.description, style: const TextStyle(fontSize: 9)),
                                if (proj.technologies.isNotEmpty)
                                  Text('Tech: ${proj.technologies}', style: const TextStyle(fontSize: 8, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 4),
                  ],

                  if (data.certifications.isNotEmpty) ...[
                    _buildSectionTitle('CERTIFICATIONS'),
                    ...data.certifications.map((cert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(cert.year, style: const TextStyle(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cert.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(cert.organization, style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  
                  const Spacer(),
                  // Bottom row for skills and languages
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('SKILLS'),
                            Text(
                              data.skills.join(' • '),
                              style: const TextStyle(fontSize: 9, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('LANGUAGES'),
                            Text(
                              data.languages.map((l) => '${l['name']} (${l['level']})').join(' • '),
                              style: const TextStyle(fontSize: 9, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
