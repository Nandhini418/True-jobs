import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truejobs/models/resume_data.dart';

// -----------------------------------------------------------------------------
// Template 3: Creative Minimalist
// -----------------------------------------------------------------------------
class TemplateThree extends StatelessWidget {
  final ResumeData data;
  
  const TemplateThree({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF00B4D8); // Cyan
    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  if (data.hasPhoto)
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: accentColor, width: 2),
                        shape: BoxShape.circle,
                        image: data.profileImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(data.profileImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: data.profileImagePath == null
                          ? const Icon(Icons.person, color: Colors.grey, size: 40)
                          : null,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Colors.black)),
                        Text(data.role.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Contact Info Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _IconText3(Icons.phone, data.phone, accentColor),
                    _IconText3(Icons.email, data.email, accentColor),
                    _IconText3(Icons.location_on, data.address, accentColor),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Body (2 Columns)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Col
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Title3('PROFILE', accentColor),
                          Text(data.summary, style: const TextStyle(fontSize: 9, height: 1.4, color: Colors.black)),
                          const SizedBox(height: 16),

                          _Title3('EXPERIENCE', accentColor),
                          ...data.experience.map((exp) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp.jobTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                Text('${exp.company} | ${exp.duration}', style: const TextStyle(fontSize: 8, color: Colors.blueGrey)),
                                const SizedBox(height: 4),
                                Text(exp.description, style: const TextStyle(fontSize: 9, color: Colors.black)),
                              ],
                            ),
                          )),
                          
                          if (data.projects.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _Title3('PROJECTS', accentColor),
                            ...data.projects.map((proj) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(proj.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                  const SizedBox(height: 2),
                                  Text(proj.description, style: const TextStyle(fontSize: 9, color: Colors.black)),
                                  if (proj.technologies.isNotEmpty)
                                    Text('Tech: ${proj.technologies}', style: const TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Right Col
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Title3('EDUCATION', accentColor),
                          ...data.education.map((edu) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                Text(edu.institution, style: const TextStyle(fontSize: 9, color: Colors.black)),
                                Text(edu.year, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                          )),

                          _Title3('SKILLS', accentColor),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: data.skills.map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(skill, style: const TextStyle(fontSize: 8, color: Colors.black87, fontWeight: FontWeight.w600)),
                            )).toList(),
                          ),
                          
                          if (data.certifications.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _Title3('CERTIFICATIONS', accentColor),
                            ...data.certifications.map((cert) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cert.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                  Text('${cert.organization} | ${cert.year}', style: const TextStyle(fontSize: 8, color: Colors.blueGrey)),
                                ],
                              ),
                            )),
                          ],
                          
                          if (data.languages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _Title3('LANGUAGES', accentColor),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: data.languages.map((lang) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: accentColor.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(lang['name']!, style: const TextStyle(fontSize: 8, color: Colors.black87, fontWeight: FontWeight.w600)),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconText3 extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _IconText3(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 8, color: Colors.black)),
      ],
    );
  }
}

class _Title3 extends StatelessWidget {
  final String title;
  final Color color;
  const _Title3(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 2, color: color),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black)),
        ],
      ),
    );
  }
}
