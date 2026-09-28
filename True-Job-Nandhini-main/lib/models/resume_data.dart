class ResumeData {
  final String fullName;
  final String role;
  final String email;
  final String phone;
  final String address;
  final String summary;
  final List<Education> education;
  final List<Experience> experience;
  final List<Project> projects;
  final List<Certification> certifications;
  final List<String> skills;
  final List<Map<String, String>> languages;
  final List<String> hobbies;
  final bool hasPhoto; // Used for "With photo" / "Without photo" variations
  final String? profileImagePath; // User uploaded image path
  
  // Customization settings
  final String fontFamily;
  final double fontSize;
  final int primaryColor; // Stored as integer representation of Color

  // Singleton instance
  static ResumeData globalData = ResumeData.dummyData();

  ResumeData({
    required this.fullName,
    required this.role,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
    required this.education,
    required this.experience,
    this.projects = const [],
    this.certifications = const [],
    required this.skills,
    this.languages = const [],
    this.hobbies = const [],
    this.hasPhoto = false,
    this.profileImagePath,
    this.fontFamily = 'Poppins',
    this.fontSize = 14.0,
    this.primaryColor = 0xFF2563EB, // AppColors.primary equivalent
  });

  // Dummy data for template preview
  static ResumeData dummyData({bool withPhoto = false}) {
    return ResumeData(
      fullName: 'Alex Johnson',
      role: 'Software Engineer',
      email: 'alex.johnson@email.com',
      phone: '+1 234 567 8900',
      address: 'New York, NY 10001',
      summary: 'Passionate and results-driven Software Engineer with 3+ years of experience in developing scalable web applications. Proficient in Flutter, Dart, and building user-centric interfaces. Strong problem-solving skills and a team player.',
      education: [
        Education(
          degree: 'B.S. in Computer Science',
          institution: 'State University',
          year: '2018 - 2022',
        ),
      ],
      experience: [
        Experience(
          jobTitle: 'Frontend Developer',
          company: 'Tech Solutions Inc.',
          duration: 'Jan 2023 - Present',
          description: 'Developed and maintained cross-platform mobile applications using Flutter. Improved app performance by 30% and successfully delivered 4 major releases.',
        ),
        Experience(
          jobTitle: 'Software Engineering Intern',
          company: 'Innovate LLC',
          duration: 'Jun 2022 - Dec 2022',
          description: 'Assisted in building responsive web components and optimizing REST APIs.',
        ),
      ],
      projects: [
        Project(
          title: 'E-commerce App',
          description: 'Built a full-stack e-commerce app with payment gateway integration.',
          technologies: 'Flutter, Firebase, Stripe',
        ),
      ],
      certifications: [
        Certification(
          name: 'AWS Certified Solutions Architect',
          organization: 'Amazon',
          year: '2023',
        ),
      ],
      skills: ['Flutter', 'Dart', 'JavaScript', 'React', 'Git', 'Agile', 'UI/UX Design'],
      languages: [
        {"name": "English", "level": "Proficient"},
        {"name": "Hindi", "level": "Proficient"},
      ],
      hobbies: ["Writing", "Cricket", "Music"],
      hasPhoto: withPhoto,
    );
  }

  // Helper method to create a copy with new values
  ResumeData copyWith({
    String? fullName,
    String? role,
    String? email,
    String? phone,
    String? address,
    String? summary,
    List<Education>? education,
    List<Experience>? experience,
    List<Project>? projects,
    List<Certification>? certifications,
    List<String>? skills,
    List<Map<String, String>>? languages,
    List<String>? hobbies,
    bool? hasPhoto,
    String? profileImagePath,
    String? fontFamily,
    double? fontSize,
    int? primaryColor,
  }) {
    return ResumeData(
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      summary: summary ?? this.summary,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      hobbies: hobbies ?? this.hobbies,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

class Education {
  final String degree;
  final String institution;
  final String year;

  Education({
    required this.degree,
    required this.institution,
    required this.year,
  });
}

class Experience {
  final String jobTitle;
  final String company;
  final String duration;
  final String description;

  Experience({
    required this.jobTitle,
    required this.company,
    required this.duration,
    required this.description,
  });
}

class Project {
  final String title;
  final String description;
  final String technologies;

  Project({
    required this.title,
    required this.description,
    required this.technologies,
  });
}

class Certification {
  final String name;
  final String organization;
  final String year;

  Certification({
    required this.name,
    required this.organization,
    required this.year,
  });
}
