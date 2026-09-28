class JobModel {
  String id;
  String title;
  String employmentType;
  String experienceLevel;
  String locationType;
  String location;
  int openings;
  String deadline;
  String salaryType;
  String salaryRange;
  List<String> perks;
  String education;
  String experience;
  String englishLevel;
  List<String> skills;
  String qualification;
  String description;
  String walkIn;
  String? walkInStartDate;
  String? walkInEndDate;
  String? walkInStartTime;
  String? walkInEndTime;
  String? walkInAddress;
  String? walkInInstructions;
  String portfolio;
  String resume;
  String recruiterName;
  String recruiterTitle;
  String recruiterEmail;
  String recruiterPhone;
  String status; // 'Active', 'Expired', 'Closed'
  String datePosted;
  String? department;
  String? responsibilities;

  JobModel({
    required this.id,
    required this.title,
    required this.employmentType,
    required this.experienceLevel,
    required this.locationType,
    required this.location,
    required this.openings,
    required this.deadline,
    required this.salaryType,
    required this.salaryRange,
    required this.perks,
    required this.education,
    required this.experience,
    required this.englishLevel,
    required this.skills,
    required this.qualification,
    required this.description,
    required this.walkIn,
    this.walkInStartDate,
    this.walkInEndDate,
    this.walkInStartTime,
    this.walkInEndTime,
    this.walkInAddress,
    this.walkInInstructions,
    required this.portfolio,
    required this.resume,
    required this.recruiterName,
    required this.recruiterTitle,
    required this.recruiterEmail,
    required this.recruiterPhone,
    this.status = 'Active',
    required this.datePosted,
    this.department,
    this.responsibilities,
  });

  JobModel copyWith({
    String? id,
    String? title,
    String? location,
    String? department,
    String? responsibilities,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      locationType: locationType,
      location: location ?? this.location,
      openings: openings,
      deadline: deadline,
      salaryType: salaryType,
      salaryRange: salaryRange,
      perks: List.from(perks),
      education: education,
      experience: experience,
      englishLevel: englishLevel,
      skills: List.from(skills),
      qualification: qualification,
      description: description,
      walkIn: walkIn,
      walkInStartDate: walkInStartDate,
      walkInEndDate: walkInEndDate,
      walkInStartTime: walkInStartTime,
      walkInEndTime: walkInEndTime,
      walkInAddress: walkInAddress,
      walkInInstructions: walkInInstructions,
      portfolio: portfolio,
      resume: resume,
      recruiterName: recruiterName,
      recruiterTitle: recruiterTitle,
      recruiterEmail: recruiterEmail,
      recruiterPhone: recruiterPhone,
      status: status,
      datePosted: datePosted,
      department: department ?? this.department,
      responsibilities: responsibilities ?? this.responsibilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'employmentType': employmentType,
      'experienceLevel': experienceLevel,
      'locationType': locationType,
      'location': location,
      'openings': openings,
      'deadline': deadline,
      'salaryType': salaryType,
      'salaryRange': salaryRange,
      'perks': perks,
      'education': education,
      'experience': experience,
      'englishLevel': englishLevel,
      'skills': skills,
      'qualification': qualification,
      'description': description,
      'walkIn': walkIn,
      'walkInStartDate': walkInStartDate,
      'walkInEndDate': walkInEndDate,
      'walkInStartTime': walkInStartTime,
      'walkInEndTime': walkInEndTime,
      'walkInAddress': walkInAddress,
      'walkInInstructions': walkInInstructions,
      'portfolio': portfolio,
      'resume': resume,
      'recruiterName': recruiterName,
      'recruiterTitle': recruiterTitle,
      'recruiterEmail': recruiterEmail,
      'recruiterPhone': recruiterPhone,
      'status': status,
      'datePosted': datePosted,
      'department': department,
      'responsibilities': responsibilities,
    };
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      employmentType: json['employmentType'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      locationType: json['locationType'] ?? '',
      location: json['location'] ?? '',
      openings: json['openings'] ?? 0,
      deadline: json['deadline'] ?? '',
      salaryType: json['salaryType'] ?? '',
      salaryRange: json['salaryRange'] ?? '',
      perks: List<String>.from(json['perks'] ?? []),
      education: json['education'] ?? '',
      experience: json['experience'] ?? '',
      englishLevel: json['englishLevel'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      qualification: json['qualification'] ?? '',
      description: json['description'] ?? '',
      walkIn: json['walkIn'] ?? '',
      walkInStartDate: json['walkInStartDate'],
      walkInEndDate: json['walkInEndDate'],
      walkInStartTime: json['walkInStartTime'],
      walkInEndTime: json['walkInEndTime'],
      walkInAddress: json['walkInAddress'],
      walkInInstructions: json['walkInInstructions'],
      portfolio: json['portfolio'] ?? '',
      resume: json['resume'] ?? '',
      recruiterName: json['recruiterName'] ?? '',
      recruiterTitle: json['recruiterTitle'] ?? '',
      recruiterEmail: json['recruiterEmail'] ?? '',
      recruiterPhone: json['recruiterPhone'] ?? '',
      datePosted: json['datePosted'] ?? '',
      department: json['department'] ?? '',
      responsibilities: json['responsibilities'] ?? '',
    );
  }

  factory JobModel.fromApiJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['auto_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['job_title']?.toString() ?? '',
      employmentType: json['job_type']?.toString() ?? '',
      experienceLevel: json['experience']?.toString() ?? '',
      locationType: json['work_loc_type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      openings: int.tryParse(json['vaccancy']?.toString() ?? json['openings']?.toString() ?? '1') ?? 1,
      deadline: json['interview_date']?.toString() ?? '',
      salaryType: json['salary_type']?.toString() ?? '',
      salaryRange: json['salary_range']?.toString() ?? '',
      perks: (json['perks_benefits']?.toString() ?? '').split(',').where((s) => s.isNotEmpty).toList(),
      education: json['education']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      englishLevel: json['englishLevel']?.toString() ?? '',
      skills: (json['skills']?.toString() ?? '').split(',').where((s) => s.isNotEmpty).toList(),
      qualification: json['qualification']?.toString() ?? '',
      description: json['job_description']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      responsibilities: json['responsibilities']?.toString() ?? '',
      walkIn: json['interview_method']?.toString() == '1' ? 'Yes' : 'No',
      walkInStartDate: json['walk_start']?.toString(),
      walkInEndDate: json['walk_end']?.toString(),
      walkInStartTime: json['walk_timing']?.toString(),
      walkInEndTime: json['walk_time_end']?.toString(),
      walkInAddress: json['walk_address']?.toString(), // Guessing field name
      walkInInstructions: json['other_instruct']?.toString(),
      portfolio: json['portfolio']?.toString() ?? '',
      resume: json['resume']?.toString() ?? '',
      recruiterName: json['hr_name']?.toString() ?? '',
      recruiterTitle: json['recuriter_job']?.toString() ?? '',
      recruiterEmail: json['recuriter_email']?.toString() ?? '',
      recruiterPhone: json['recuriter_mobile']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      datePosted: json['created_date']?.toString() ?? DateTime.now().toString(),
    );
  }
}

class CandidateModel {
  final String name;
  final String role;
  final String experience;
  final String phone;
  final String location;
  final String status; // 'Shortlisted', 'On Hold', 'Under Review', 'Rejected'
  final String appliedDate;
  final String expectedSalary;
  final String education;
  final List<String> languages;
  final List<String> skills;
  final double matchScore;
  final String matchString;
  final String resume;
  final String photo;
  final String noticePeriod;
  final String currentSalary;
  final String portfolio;
  final String currentCompany;
  final String linkedin;

  CandidateModel({
    required this.name,
    required this.role,
    required this.experience,
    required this.phone,
    required this.location,
    required this.status,
    required this.appliedDate,
    required this.expectedSalary,
    required this.education,
    required this.languages,
    required this.skills,
    required this.matchScore,
    this.matchString = '',
    this.resume = '',
    this.photo = '',
    this.noticePeriod = '',
    this.currentSalary = '',
    this.portfolio = '',
    this.currentCompany = '',
    this.linkedin = '',
  });

  factory CandidateModel.fromApiJson(Map<String, dynamic> json, [String jobTitle = '']) {
    String matchRaw = json['match']?.toString() ?? '';
    double parsedScore = 0.5; // default
    if (matchRaw.toLowerCase().contains('high')) parsedScore = 0.9;
    if (matchRaw.toLowerCase().contains('medium')) parsedScore = 0.5;
    if (matchRaw.toLowerCase().contains('low')) parsedScore = 0.2;

    String parsedEducation = json['high_qualify']?.toString() ?? '';
    if (json['education_details'] != null && json['education_details'] is Map) {
      final ed = json['education_details'];
      final course = ed['ug_course']?.toString() ?? '';
      final spec = ed['ug_specialization']?.toString() ?? '';
      if (course.isNotEmpty) {
        parsedEducation = spec.isNotEmpty ? '$course in $spec' : course;
      }
    }
    
    final finalJobTitle = jobTitle.isNotEmpty ? jobTitle : (json['job_id']?.toString() ?? 'Unknown Role');
    final skillsString = json['skills_name']?.toString() ?? json['skills']?.toString() ?? '';

    return CandidateModel(
      name: json['name']?.toString() ?? json['register_name']?.toString() ?? 'Unknown',
      role: finalJobTitle,
      experience: json['experience']?.toString() ?? 'Fresher',
      phone: json['mobile_no']?.toString() ?? json['register_mobile']?.toString() ?? '',
      location: json['location']?.toString() ?? json['register_city']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Under Review',
      appliedDate: json['dtime']?.toString() ?? '',
      expectedSalary: json['expected_salary']?.toString() ?? '',
      education: parsedEducation,
      languages: [], // Not provided in payload, keeping empty or default
      skills: skillsString.split(',').where((s) => s.isNotEmpty).map((e) => e.trim()).toList(),
      matchScore: parsedScore,
      matchString: matchRaw,
      resume: json['resume']?.toString() ?? '',
      photo: json['photo']?.toString() ?? json['register_photo']?.toString() ?? '',
      noticePeriod: json['notice_period']?.toString() ?? '',
      currentSalary: json['current_salary']?.toString() ?? '',
      portfolio: json['portfolio']?.toString() ?? '',
      currentCompany: json['current_company']?.toString() ?? '',
      linkedin: json['linkedin']?.toString() ?? '',
    );
  }
}

// Generate some initial mock candidates
final List<CandidateModel> mockCandidatesList = [
  CandidateModel(
    name: 'Rahul Kumar',
    role: 'Senior UI/UX Designer',
    experience: '3 Years',
    phone: '+91 98765 43210',
    location: 'Irugur, Coimbatore',
    status: 'Shortlisted',
    appliedDate: '24 Jun 2026',
    expectedSalary: '9 LPA',
    education: 'B.Des in Interaction Design, PSG College of Tech, Coimbatore',
    languages: ['English (Fluent)', 'Tamil', 'Hindi'],
    skills: ['Figma', 'UX Research', 'Wireframing', 'Prototyping'],
    matchScore: 0.95,
  ),
  CandidateModel(
    name: 'Yasin',
    role: 'Customer Support Executive',
    experience: 'Fresher',
    phone: '+91 98765 12345',
    location: 'Ondipudur, Coimbatore',
    status: 'Shortlisted',
    appliedDate: 'Applied 2 months ago',
    expectedSalary: '3 LPA',
    education: 'B.Com, Computer Applications | RVS College of Arts and Science, Coimbatore',
    languages: ['English (Good)', 'Hindi', 'Tamil', 'Urdu'],
    skills: ['Customer Relations', 'Communication', 'Data Entry'],
    matchScore: 0.88,
  ),
  CandidateModel(
    name: 'Priya Sharma',
    role: 'Customer Support Executive',
    experience: '1 Year',
    phone: '+91 98123 45678',
    location: 'Peelamedu, Coimbatore',
    status: 'Under Review',
    appliedDate: 'Applied 1 week ago',
    expectedSalary: '3.5 LPA',
    education: 'B.Sc. Information Technology | GRD College, Coimbatore',
    languages: ['English (Fluent)', 'Tamil', 'Hindi'],
    skills: ['Technical Support', 'Ticketing Systems', 'Voice Support'],
    matchScore: 0.76,
  ),
  CandidateModel(
    name: 'Anish Raj',
    role: 'Software Engineer',
    experience: '2 Years',
    phone: '+91 90123 45678',
    location: 'Gandhipuram, Coimbatore',
    status: 'On Hold',
    appliedDate: 'Applied 3 days ago',
    expectedSalary: '6 LPA',
    education: 'B.E. Computer Science | CIT, Coimbatore',
    languages: ['English (Fluent)', 'Tamil'],
    skills: ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
    matchScore: 0.92,
  ),
  CandidateModel(
    name: 'Divya Nair',
    role: 'Senior UI/UX Designer',
    experience: '4 Years',
    phone: '+91 88888 77777',
    location: 'Saravanampatti, Coimbatore',
    status: 'Rejected',
    appliedDate: 'Applied 2 weeks ago',
    expectedSalary: '10 LPA',
    education: 'B.FA | College of Fine Arts, Thrissur',
    languages: ['English (Fluent)', 'Malayalam', 'Tamil'],
    skills: ['Design Systems', 'Figma', 'Illustrator'],
    matchScore: 0.50,
  ),
];
