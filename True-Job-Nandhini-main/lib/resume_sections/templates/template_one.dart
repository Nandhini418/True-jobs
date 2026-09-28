import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truejobs/models/resume_data.dart';

// -----------------------------------------------------------------------------
// Template 1: Traditional 1-Column
// -----------------------------------------------------------------------------
class TemplateOne extends StatelessWidget {
  final ResumeData data;
  
  const TemplateOne({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    if (data.hasPhoto)
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
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
                    Text(
                      data.fullName.toUpperCase(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.phone}  |  ${data.email}  |  ${data.address}',
                      style: const TextStyle(fontSize: 8, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Summary
              _buildSectionTitle('PROFESSIONAL SUMMARY'),
              Text(data.summary, style: const TextStyle(fontSize: 9, height: 1.4, color: Colors.black)),
              const SizedBox(height: 12),

              // Experience
              _buildSectionTitle('EXPERIENCE'),
              ...data.experience.map((exp) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(exp.jobTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text(exp.duration, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.black)),
                      ],
                    ),
                    Text(exp.company, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 4),
                    Text('- ${exp.description}', style: const TextStyle(fontSize: 9, color: Colors.black)),
                  ],
                ),
              )),
              const SizedBox(height: 4),

              // Education
              _buildSectionTitle('EDUCATION'),
              ...data.education.map((edu) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text(edu.institution, style: const TextStyle(fontSize: 9, color: Colors.black)),
                      ],
                    ),
                    Text(edu.year, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.black)),
                  ],
                ),
              )),
              const SizedBox(height: 4),

              // Skills
              if (data.skills.isNotEmpty) ...[
                _buildSectionTitle('SKILLS'),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: data.skills.map((skill) => Text('• $skill', style: const TextStyle(fontSize: 9, color: Colors.black))).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Projects
              if (data.projects.isNotEmpty) ...[
                _buildSectionTitle('PROJECTS'),
                ...data.projects.map((proj) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proj.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 4),
                      Text('- ${proj.description}', style: const TextStyle(fontSize: 9, color: Colors.black)),
                      if (proj.technologies.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('Technologies: ${proj.technologies}', style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.black)),
                      ],
                    ],
                  ),
                )),
                const SizedBox(height: 4),
              ],

              // Certifications
              if (data.certifications.isNotEmpty) ...[
                _buildSectionTitle('CERTIFICATIONS'),
                ...data.certifications.map((cert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cert.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                          Text(cert.organization, style: const TextStyle(fontSize: 9, color: Colors.black)),
                        ],
                      ),
                      Text(cert.year, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.black)),
                    ],
                  ),
                )),
                const SizedBox(height: 4),
              ],

              // Languages
              if (data.languages.isNotEmpty) ...[
                _buildSectionTitle('LANGUAGES'),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: data.languages.map((lang) => Text('• ${lang['name']}', style: const TextStyle(fontSize: 9, color: Colors.black))).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
        const Divider(color: Colors.black, thickness: 1, height: 8),
        const SizedBox(height: 4),
      ],
    );
  }
}
