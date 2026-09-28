import 'package:flutter/material.dart';
import '../../models/resume_data.dart';

// Base styling for the A4 paper look
class CvPaper extends StatelessWidget {
  final Widget child;
  const CvPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // A4 Aspect ratio is roughly 1 : 1.414
    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: child,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Template 1: Traditional 1-Column
// -----------------------------------------------------------------------------
class Template1Widget extends StatelessWidget {
  final ResumeData data;
  const Template1Widget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CvPaper(
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
                      ),
                      child: const Icon(Icons.person, color: Colors.grey, size: 40),
                    ),
                  Text(
                    data.fullName.toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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
            Text(data.summary, style: const TextStyle(fontSize: 9, height: 1.4)),
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
                      Text(exp.jobTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(exp.duration, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  Text(exp.company, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('- ${exp.description}', style: const TextStyle(fontSize: 9)),
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
                      Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(edu.institution, style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                  Text(edu.year, style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic)),
                ],
              ),
            )),
            const SizedBox(height: 4),

            // Skills
            _buildSectionTitle('SKILLS'),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: data.skills.map((skill) => Text('• $skill', style: const TextStyle(fontSize: 9))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.black, thickness: 1, height: 8),
        const SizedBox(height: 4),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Template 2: Modern 2-Column (Sidebar)
// -----------------------------------------------------------------------------
class Template2Widget extends StatelessWidget {
  final ResumeData data;
  const Template2Widget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const Color sidebarColor = Color(0xFF2C3E50); // Dark Blue
    const Color mainColor = Colors.white;

    return CvPaper(
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.grey, size: 50),
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
                  _MainTitle('EDUCATION', sidebarColor),
                  ...data.education.map((edu) => Column(
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
                  )),
                ],
              ),
            ),
          ),
        ],
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

// -----------------------------------------------------------------------------
// Template 3: Creative Minimalist
// -----------------------------------------------------------------------------
class Template3Widget extends StatelessWidget {
  final ResumeData data;
  const Template3Widget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF00B4D8); // Cyan
    return CvPaper(
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
                    ),
                    child: const Icon(Icons.person, color: Colors.grey, size: 40),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300)),
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
                        Text(data.summary, style: const TextStyle(fontSize: 9, height: 1.4)),
                        const SizedBox(height: 16),

                        _Title3('EXPERIENCE', accentColor),
                        ...data.experience.map((exp) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exp.jobTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('${exp.company} | ${exp.duration}', style: const TextStyle(fontSize: 8, color: Colors.blueGrey)),
                              const SizedBox(height: 4),
                              Text(exp.description, style: const TextStyle(fontSize: 9)),
                            ],
                          ),
                        )),
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
                              Text(edu.degree, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(edu.institution, style: const TextStyle(fontSize: 9)),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        Text(text, style: const TextStyle(fontSize: 8)),
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
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}
