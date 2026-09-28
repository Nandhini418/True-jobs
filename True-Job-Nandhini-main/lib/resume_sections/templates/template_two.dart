import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truejobs/models/resume_data.dart';

// -----------------------------------------------------------------------------
// Template 2: Modern 2-Column (Sidebar)
// -----------------------------------------------------------------------------
class TemplateTwo extends StatelessWidget {
  final ResumeData data;
  
  const TemplateTwo({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const Color sidebarColor = Color(0xFF2C3E50); // Dark Blue
    const Color mainColor = Colors.white;

    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        color: mainColor,
        child: Row(
          children: [
            // Sidebar
            Expanded(
              flex: 1,
              child: Container(
                color: sidebarColor,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.hasPhoto)
                      Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: data.profileImagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(data.profileImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: data.profileImagePath == null
                              ? const Icon(Icons.person, color: Colors.grey, size: 50)
                              : null,
                        ),
                      ),
                    const Text('CONTACT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Divider(color: Colors.white54, height: 12),
                    _SideText(Icons.phone, data.phone),
                    _SideText(Icons.email, data.email),
                    _SideText(Icons.location_on, data.address),
                    
                    const SizedBox(height: 20),
                    const Text('SKILLS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Divider(color: Colors.white54, height: 12),
                    ...data.skills.map((skill) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• $skill', style: const TextStyle(color: Colors.white70, fontSize: 9)),
                    )),
                    
                    if (data.languages.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('LANGUAGES', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const Divider(color: Colors.white54, height: 12),
                      ...data.languages.map((lang) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text('• ${lang['name']}', style: const TextStyle(color: Colors.white70, fontSize: 9)),
                      )),
                    ],
                  ],
                ),
              ),
            ),
            
            // Main Content
            Expanded(
              flex: 2,
              child: Container(
                color: mainColor,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.fullName.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: sidebarColor)),
                    Text(data.role, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    
                    // Profile
                    _MainTitle('PROFILE', sidebarColor),
                    Text(data.summary, style: const TextStyle(fontSize: 9, height: 1.4, color: Colors.black87)),
                    const SizedBox(height: 16),

                    // Experience
                    _MainTitle('WORK EXPERIENCE', sidebarColor),
                    ...data.experience.map((exp) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exp.jobTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(exp.company, style: const TextStyle(fontSize: 9, color: Colors.blueGrey)),
                              Text(exp.duration, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(exp.description, style: const TextStyle(fontSize: 9, color: Colors.black87)),
                        ],
                      ),
                    )),

                    // Education
                    if (data.education.isNotEmpty) ...[
                      _MainTitle('EDUCATION', sidebarColor),
                      ...data.education.map((edu) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(edu.institution, style: const TextStyle(fontSize: 9, color: Colors.blueGrey)),
                                Text(edu.year, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                    ],

                    // Projects
                    if (data.projects.isNotEmpty) ...[
                      _MainTitle('PROJECTS', sidebarColor),
                      ...data.projects.map((proj) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(proj.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(proj.description, style: const TextStyle(fontSize: 9, color: Colors.black87)),
                            if (proj.technologies.isNotEmpty)
                              Text('Tech: ${proj.technologies}', style: const TextStyle(fontSize: 8, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                    ],

                    // Certifications
                    if (data.certifications.isNotEmpty) ...[
                      _MainTitle('CERTIFICATIONS', sidebarColor),
                      ...data.certifications.map((cert) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cert.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(cert.year, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                            Text(cert.organization, style: const TextStyle(fontSize: 9, color: Colors.blueGrey)),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SideText(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 10),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 8))),
        ],
      ),
    );
  }
}

class _MainTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _MainTitle(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)),
        Divider(color: color, thickness: 1.5, height: 8),
        const SizedBox(height: 8),
      ],
    );
  }
}
