class GroupListResponse {
  final bool error;
  final bool success;
  final GroupListData? data;
  final String? errorMessage;

  GroupListResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory GroupListResponse.fromJson(Map<String, dynamic> json) {
    return GroupListResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? GroupListData.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class GroupListData {
  final List<Group> groups;

  GroupListData({required this.groups});

  factory GroupListData.fromJson(Map<String, dynamic> json) {
    List<Group> groupsList = [];
    if (json['groups'] != null) {
      groupsList = List<Group>.from(
          json['groups'].map((group) => Group.fromJson(group)));
    }
    return GroupListData(groups: groupsList);
  }
}

class Group {
  final int groupID;
  final String groupName;
  final String groupDesc;
  final String createdBy;
  final String packageName;
  final String packageExpires;
  final String createDate;
  final bool isFree;
  final bool isAdmin;
  final List<Project> projects;

  Group({
    required this.groupID,
    required this.groupName,
    required this.groupDesc,
    required this.createdBy,
    required this.packageName,
    required this.packageExpires,
    required this.createDate,
    required this.isFree,
    required this.isAdmin,
    required this.projects,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    List<Project> projectsList = [];
    if (json['projects'] != null) {
      projectsList = List<Project>.from(
          json['projects'].map((project) => Project.fromJson(project)));
    }
    return Group(
      groupID: json['groupID'] ?? 0,
      groupName: json['groupName'] ?? '',
      groupDesc: json['groupDesc'] ?? '',
      createdBy: json['createdBy'] ?? '',
      packageName: json['packageName'] ?? '',
      packageExpires: json['packageExpires'] ?? '',
      createDate: json['createDate'] ?? '',
      isFree: json['isFree'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      projects: projectsList,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'groupID': groupID,
      'groupName': groupName,
      'groupDesc': groupDesc,
      'createdBy': createdBy,
      'packageName': packageName,
      'packageExpires': packageExpires,
      'createDate': createDate,
      'isFree': isFree,
      'isAdmin': isAdmin,
      'projects': projects.map((project) => project.toJson()).toList(),
    };
  }
}

class Project {
  final int projectID;
  final String projectName;
  final String projectStatus;
  final int projectStatusID;

  Project({
    required this.projectID,
    required this.projectName,
    required this.projectStatus,
    required this.projectStatusID,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectID: json['projectID'] ?? 0,
      projectName: json['projectName'] ?? '',
      projectStatus: json['projectStatus'] ?? '',
      projectStatusID: json['projectStatusID'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'projectID': projectID,
      'projectName': projectName,
      'projectStatus': projectStatus,
      'projectStatusID': projectStatusID,
    };
  }
}

class GroupDetail {
  final int groupID;
  final String groupName;
  final String groupDesc;
  final String createdBy;
  final String packageName;
  final int packMaxUsers;
  final int packMaxProjects;
  final String packPrice;
  final String packageExpires;
  final String createDate;
  final int totalUsers;
  final bool isFree;
  final bool isAddUser;
  final bool isAddProject;
  final List<GroupUser> users;
  final List<Project> projects;
  final List<GroupEvent> events;
  final List<GroupReport> reports;

  GroupDetail({
    required this.groupID,
    required this.groupName,
    required this.groupDesc,
    required this.createdBy,
    required this.packageName,
    required this.packMaxUsers,
    required this.packMaxProjects,
    required this.packPrice,
    required this.packageExpires,
    required this.createDate,
    required this.totalUsers,
    required this.isFree,
    required this.isAddUser,
    required this.isAddProject,
    required this.users,
    required this.projects,
    required this.events,
    this.reports = const [],
  });

  factory GroupDetail.fromJson(Map<String, dynamic> json) {
    return GroupDetail(
      groupID: json['groupID'] ?? 0,
      groupName: json['groupName'] ?? '',
      groupDesc: json['groupDesc'] ?? '',
      createdBy: json['createdBy'] ?? '',
      packageName: json['packageName'] ?? '',
      packMaxUsers: json['packMaxUsers'] ?? 0,
      packMaxProjects: json['packMaxProjects'] ?? 0,
      packPrice: json['packPrice'] ?? '',
      packageExpires: json['packageExpires'] ?? '',
      createDate: json['createDate'] ?? '',
      totalUsers: json['totalUsers'] ?? 0,
      isFree: json['isFree'] ?? false,
      isAddUser: json['isAddUser'] ?? false,
      isAddProject: json['isAddProject'] ?? false,
      users: (json['users'] as List<dynamic>?)
              ?.map((user) => GroupUser.fromJson(user))
              .toList() ??
          [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((project) => Project.fromJson(project))
              .toList() ??
          [],
      events: (json['events'] as List<dynamic>?)
              ?.map((event) => GroupEvent.fromJson(event))
              .toList() ??
          [],
      reports: (json['reports'] as List<dynamic>?)
              ?.map((report) => GroupReport.fromJson(report))
              .toList() ??
          [],
    );
  }
}

class GroupUser {
  final int groupUID;
  final int userID;
  final String userName;
  final int userRoleID;
  final String userRole;
  final String joinedDate;
  final bool isAdmin;
  final String profilePhoto;

  GroupUser({
    required this.groupUID,
    required this.userID,
    required this.userName,
    required this.userRoleID,
    required this.userRole,
    required this.joinedDate,
    required this.isAdmin,
    required this.profilePhoto,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
      groupUID: json['groupUID'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userRoleID: json['userRoleID'] ?? 0,
      userRole: json['userRole'] ?? '',
      joinedDate: json['joinedDate'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      profilePhoto: json['profilePhoto'] ?? '',
    );
  }
}

class GroupEvent {
  final int eventID;
  final int groupID;
  final int userID;
  final String userFullname;
  final String eventTitle;
  final String eventDesc;
  final int eventStatusID;
  final String eventStatus;
  final String eventDate;
  final String createDate;

  GroupEvent({
    required this.eventID,
    required this.groupID,
    required this.userID,
    required this.userFullname,
    required this.eventTitle,
    required this.eventDesc,
    required this.eventStatusID,
    required this.eventStatus,
    required this.eventDate,
    required this.createDate,
  });

  factory GroupEvent.fromJson(Map<String, dynamic> json) {
    return GroupEvent(
      eventID: json['eventID'] ?? 0,
      groupID: json['groupID'] ?? 0,
      userID: json['userID'] ?? 0,
      userFullname: json['userFullname'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      eventDesc: json['eventDesc'] ?? '',
      eventStatusID: json['eventStatusID'] ?? 0,
      eventStatus: json['eventStatus'] ?? '',
      eventDate: json['eventDate'] ?? '',
      createDate: json['createDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'groupID': groupID,
      'userID': userID,
      'userFullname': userFullname,
      'eventTitle': eventTitle,
      'eventDesc': eventDesc,
      'eventStatusID': eventStatusID,
      'eventStatus': eventStatus,
      'eventDate': eventDate,
      'createDate': createDate,
    };
  }

  DateTime get eventDateTime {
    // Örnek tarih formatı: "27.04.2025 19:00"
    try {
      final parts = eventDate.split(' ');
      if (parts.length != 2) {
        throw FormatException('Geçersiz tarih formatı: $eventDate');
      }
      
      final dateParts = parts[0].split('.');
      final timeParts = parts[1].split(':');
      
      if (dateParts.length != 3 || timeParts.length != 2) {
        throw FormatException('Geçersiz tarih/saat formatı: $eventDate');
      }
      
      final year = int.parse(dateParts[2]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[0]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Değerlerin geçerli olup olmadığını kontrol et
      if (year < 2000 || year > 2100 ||
          month < 1 || month > 12 ||
          day < 1 || day > 31 ||
          hour < 0 || hour > 23 ||
          minute < 0 || minute > 59) {
        throw FormatException('Geçersiz tarih/saat değerleri: $eventDate');
      }
      
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      // Herhangi bir hatada şimdiki zamanı dön
      return DateTime.now();
    }
  }
}

class GroupLog {
  final int logID;
  final int groupID;
  final int projectID;
  final int workID;
  final int userID;
  final String logName;
  final String logDesc;
  final String createDate;

  GroupLog({
    required this.logID,
    required this.groupID,
    required this.projectID,
    required this.workID,
    required this.userID,
    required this.logName,
    required this.logDesc,
    required this.createDate,
  });

  factory GroupLog.fromJson(Map<String, dynamic> json) {
    return GroupLog(
      logID: json['logID'] ?? 0,
      groupID: json['groupID'] ?? 0,
      projectID: json['projectID'] ?? 0,
      workID: json['workID'] ?? 0,
      userID: json['userID'] ?? 0,
      logName: json['logName'] ?? '',
      logDesc: json['logDesc'] ?? '',
      createDate: json['createDate'] ?? '',
    );
  }

  DateTime get logDateTime {
    // Örnek tarih formatı: "24.04.2025 19:56"
    final parts = createDate.split(' ');
    if (parts.length != 2) return DateTime.now();
    
    final dateParts = parts[0].split('.');
    final timeParts = parts[1].split(':');
    
    if (dateParts.length != 3 || timeParts.length != 2) return DateTime.now();
    
    try {
      return DateTime(
        int.parse(dateParts[2]), // Yıl
        int.parse(dateParts[1]), // Ay
        int.parse(dateParts[0]), // Gün
        int.parse(timeParts[0]), // Saat
        int.parse(timeParts[1]), // Dakika
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}

class GroupLogResponse {
  final bool error;
  final bool success;
  final List<GroupLog> data;

  GroupLogResponse({
    required this.error,
    required this.success,
    required this.data,
  });

  factory GroupLogResponse.fromJson(Map<String, dynamic> json) {
    List<GroupLog> logs = [];
    if (json['data'] != null) {
      logs = List<GroupLog>.from(
          json['data'].map((log) => GroupLog.fromJson(log)));
    }
    return GroupLogResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: logs,
    );
  }
}

class ProjectDetail {
  final int groupID;
  final int projectID;
  final String projectName;
  final String projectDesc;
  final int projectStatusID;
  final String projectStatus;
  final String projectProgress;
  final String createdBy;
  final String proStartDate;
  final String proEndDate;
  final String proCreateDate;
  final List<ProjectUser> users;

  ProjectDetail({
    required this.groupID,
    required this.projectID,
    required this.projectName,
    required this.projectDesc,
    required this.projectStatusID,
    required this.projectStatus,
    required this.projectProgress,
    required this.createdBy,
    required this.proStartDate,
    required this.proEndDate,
    required this.proCreateDate,
    required this.users,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      groupID: json['groupID'] ?? 0,
      projectID: json['projectID'] ?? 0,
      projectName: json['projectName'] ?? '',
      projectDesc: json['projectDesc'] ?? '',
      projectStatusID: json['projectStatusID'] ?? 0,
      projectStatus: json['projectStatus'] ?? '',
      projectProgress: json['projectProgress'] ?? '0.00',
      createdBy: json['createdBy'] ?? '',
      proStartDate: json['proStartDate'] ?? '',
      proEndDate: json['proEndDate'] ?? '',
      proCreateDate: json['proCreateDate'] ?? '',
      users: (json['users'] as List<dynamic>?)
              ?.map((user) => ProjectUser.fromJson(user))
              .toList() ??
          [],
    );
  }
}

class ProjectUser {
  final int projectUID;
  final int userID;
  final String userName;
  final int userRoleID;
  final String userRole;
  final String assignedDate;
  final String profilePhoto;

  ProjectUser({
    required this.projectUID,
    required this.userID,
    required this.userName,
    required this.userRoleID,
    required this.userRole,
    required this.assignedDate,
    required this.profilePhoto,
  });

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      projectUID: json['projectUID'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userRoleID: json['userRoleID'] ?? 0,
      userRole: json['userRole'] ?? '',
      assignedDate: json['assignedDate'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
    );
  }
}

class ProjectDetailResponse {
  final bool error;
  final bool success;
  final ProjectDetail? data;
  final String? errorMessage;

  ProjectDetailResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ProjectDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDetailResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? ProjectDetail.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class ProjectStatusResponse {
  final bool error;
  final bool success;
  final ProjectStatusData? data;
  final String? errorMessage;

  ProjectStatusResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ProjectStatusResponse.fromJson(Map<String, dynamic> json) {
    return ProjectStatusResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? ProjectStatusData.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class ProjectStatusData {
  final List<ProjectStatus> statuses;

  ProjectStatusData({required this.statuses});

  factory ProjectStatusData.fromJson(Map<String, dynamic> json) {
    List<ProjectStatus> statusList = [];
    if (json['statuses'] != null) {
      statusList = List<ProjectStatus>.from(
          json['statuses'].map((status) => ProjectStatus.fromJson(status)));
    }
    return ProjectStatusData(statuses: statusList);
  }
}

class ProjectStatus {
  final int statusID;
  final String statusName;
  final String statusColor;

  ProjectStatus({
    required this.statusID,
    required this.statusName,
    required this.statusColor,
  });

  factory ProjectStatus.fromJson(Map<String, dynamic> json) {
    return ProjectStatus(
      statusID: json['statusID'] ?? 0,
      statusName: json['statusName'] ?? '',
      statusColor: json['statusColor'] ?? '#f5f8fa',
    );
  }
}

// Proje görevleri için modeller
class ProjectWorkListResponse {
  final bool error;
  final bool success;
  final ProjectWorkListData? data;
  final String? errorMessage;

  ProjectWorkListResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ProjectWorkListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectWorkListResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? ProjectWorkListData.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class ProjectWorkListData {
  final List<ProjectWork> works;

  ProjectWorkListData({required this.works});

  factory ProjectWorkListData.fromJson(Map<String, dynamic> json) {
    List<ProjectWork> worksList = [];
    if (json['works'] != null) {
      worksList = List<ProjectWork>.from(
          json['works'].map((work) => ProjectWork.fromJson(work)));
    }
    return ProjectWorkListData(works: worksList);
  }
}

class ProjectWork {
  final int workID;
  final String workName;
  final String workDesc;
  final int workOrder;
  final bool workCompleted;
  final String workStartDate;
  final String workEndDate;
  final String workCreateDate;
  final List<WorkUser> workUsers;

  ProjectWork({
    required this.workID,
    required this.workName,
    required this.workDesc,
    required this.workOrder,
    required this.workCompleted,
    required this.workStartDate,
    required this.workEndDate,
    required this.workCreateDate,
    required this.workUsers,
  });

  factory ProjectWork.fromJson(Map<String, dynamic> json) {
    List<WorkUser> usersList = [];
    if (json['workUsers'] != null) {
      usersList = List<WorkUser>.from(
          json['workUsers'].map((user) => WorkUser.fromJson(user)));
    }
    
    return ProjectWork(
      workID: json['workID'] ?? 0,
      workName: json['workName'] ?? '',
      workDesc: json['workDesc'] ?? '',
      workOrder: json['workOrder'] ?? 0,
      workCompleted: json['workCompleted'] ?? false,
      workStartDate: json['workStartDate'] ?? '',
      workEndDate: json['workEndDate'] ?? '',
      workCreateDate: json['workCreateDate'] ?? '',
      workUsers: usersList,
    );
  }
}

class WorkUser {
  final int workAssID;
  final int userID;
  final String userName;
  final String assignedDate;

  WorkUser({
    required this.workAssID,
    required this.userID,
    required this.userName,
    required this.assignedDate,
  });

  factory WorkUser.fromJson(Map<String, dynamic> json) {
    return WorkUser(
      workAssID: json['workAssID'] ?? 0,
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      assignedDate: json['assignedDate'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'workAssID': workAssID,
      'userID': userID,
      'userName': userName,
      'assignedDate': assignedDate,
    };
  }
}

class ProjectWorkDetailResponse {
  final bool error;
  final bool success;
  final ProjectWork? data;
  final String? errorMessage;

  ProjectWorkDetailResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ProjectWorkDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProjectWorkDetailResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? ProjectWork.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

// Kullanıcı görevleri yanıtı için model
class UserWorksResponse {
  final bool error;
  final bool success;
  final UserWorksData? data;
  final String? errorMessage;
  final String? code;

  UserWorksResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    this.code,
  });

  factory UserWorksResponse.fromJson(Map<String, dynamic> json) {
    return UserWorksResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserWorksData.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
      code: json['410'],
    );
  }
}

class UserWorksData {
  final List<UserProjectWork> works;

  UserWorksData({required this.works});

  factory UserWorksData.fromJson(Map<String, dynamic> json) {
    List<UserProjectWork> worksList = [];
    if (json['works'] != null) {
      worksList = List<UserProjectWork>.from(
          json['works'].map((work) => UserProjectWork.fromJson(work)));
    }
    return UserWorksData(works: worksList);
  }
}

class UserProjectWork {
  final int projectID;
  final int workID;
  final String projectName;
  final String workName;
  final String workDesc;
  final int workOrder;
  final bool workCompleted;
  final String workStartDate;
  final String workEndDate;
  final String workCreateDate;
  final List<WorkUser> workUsers;

  UserProjectWork({
    required this.projectID,
    required this.workID,
    required this.projectName,
    required this.workName,
    required this.workDesc,
    required this.workOrder,
    required this.workCompleted,
    required this.workStartDate,
    required this.workEndDate,
    required this.workCreateDate,
    required this.workUsers,
  });

  factory UserProjectWork.fromJson(Map<String, dynamic> json) {
    List<WorkUser> usersList = [];
    if (json['workUsers'] != null) {
      usersList = List<WorkUser>.from(
          json['workUsers'].map((user) => WorkUser.fromJson(user)));
    }
    
    return UserProjectWork(
      projectID: json['projectID'] ?? 0,
      workID: json['workID'] ?? 0,
      projectName: json['projectName'] ?? '',
      workName: json['workName'] ?? '',
      workDesc: json['workDesc'] ?? '',
      workOrder: json['workOrder'] ?? 0,
      workCompleted: json['workCompleted'] ?? false,
      workStartDate: json['workStartDate'] ?? '',
      workEndDate: json['workEndDate'] ?? '',
      workCreateDate: json['workCreateDate'] ?? '',
      workUsers: usersList,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'projectID': projectID,
      'workID': workID,
      'projectName': projectName,
      'workName': workName,
      'workDesc': workDesc,
      'workOrder': workOrder,
      'workCompleted': workCompleted,
      'workStartDate': workStartDate,
      'workEndDate': workEndDate,
      'workCreateDate': workCreateDate,
      'workUsers': workUsers.map((user) => user.toJson()).toList(),
    };
  }
}

class GroupReport {
  final int reportID;
  final int groupID;
  final int projectID;
  final int userID;
  final String userFullname;
  final String userProfilePhoto;
  final String reportTitle;
  final String reportDesc;
  final String reportDate;
  final String createDate;
  final String updatedDate;

  GroupReport({
    required this.reportID,
    required this.groupID,
    required this.projectID,
    required this.userID,
    required this.userFullname,
    required this.userProfilePhoto,
    required this.reportTitle,
    required this.reportDesc,
    required this.reportDate,
    required this.createDate,
    required this.updatedDate,
  });

  factory GroupReport.fromJson(Map<String, dynamic> json) {
    return GroupReport(
      reportID: json['reportID'] ?? 0,
      groupID: json['groupID'] ?? 0,
      projectID: json['projectID'] ?? 0,
      userID: json['userID'] ?? 0,
      userFullname: json['userFullname'] ?? '',
      userProfilePhoto: json['userProfilePhoto'] ?? '',
      reportTitle: json['reportTitle'] ?? '',
      reportDesc: json['reportDesc'] ?? '',
      reportDate: json['reportDate'] ?? '',
      createDate: json['createDate'] ?? '',
      updatedDate: json['updatedDate'] ?? '',
    );
  }
}

class ReportDetailResponse {
  final bool error;
  final bool success;
  final GroupReport? data;
  final String? errorMessage;

  ReportDetailResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ReportDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReportDetailResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? GroupReport.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class ReportListResponse {
  final bool error;
  final bool success;
  final ReportListData? data;
  final String? errorMessage;

  ReportListResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ReportListResponse.fromJson(Map<String, dynamic> json) {
    return ReportListResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? ReportListData.fromJson(json['data']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class ReportListData {
  final List<GroupReport> reports;

  ReportListData({required this.reports});

  factory ReportListData.fromJson(Map<String, dynamic> json) {
    List<GroupReport> reportsList = [];
    if (json['reports'] != null) {
      reportsList = List<GroupReport>.from(
          json['reports'].map((report) => GroupReport.fromJson(report)));
    }
    return ReportListData(reports: reportsList);
  }
} 