class InstituteTopicData {
  int? instituteTopicDataId;
  int? onlineInstituteTopicDataId;
  int? instituteId;
  int? parentInstituteId;
  int? instituteTopicId;
  String? topicDataKind;
  String? topicDataType;
  String? topicDataFileCodeName;
  String? code;
  String? fileNameExt;
  String? html5FileName;
  String? html5FileNameApp;
  String? referenceUrl;
  int? noOfClicks;
  String? priority;
  String? status;
  String? displayType;
  String? isDefault;
  String? defaultTopicDateId;
  String? entryByInstituteUserId;
  String? addedType;
  String? contentLevel;
  String? contentTag;
  String? contentLang;
  String? isVerified;
  Null? verifiedBy;
  int? isLocalContentAvailable;
  String? html5DownloadUrl;

  InstituteTopicData(
      {this.instituteTopicDataId,
      this.onlineInstituteTopicDataId,
      this.instituteId,
      this.parentInstituteId,
      this.instituteTopicId,
      this.topicDataKind,
      this.topicDataType,
      this.topicDataFileCodeName,
      this.code,
      this.fileNameExt,
      this.html5FileName,
      this.html5FileNameApp,
      this.referenceUrl,
      this.noOfClicks,
      this.priority,
      this.status,
      this.displayType,
      this.isDefault,
      this.defaultTopicDateId,
      this.entryByInstituteUserId,
      this.addedType,
      this.contentLevel,
      this.contentTag,
      this.contentLang,
      this.isVerified,
      this.verifiedBy,
      this.isLocalContentAvailable,
      this.html5DownloadUrl});

  InstituteTopicData.fromJson(Map<String, dynamic> json) {
    instituteTopicDataId = json['institute_topic_data_id'];
    onlineInstituteTopicDataId = json['online_institute_topic_data_id'];
    instituteId = json['institute_id'];
    parentInstituteId = json['parent_institute_id'];
    instituteTopicId = json['institute_topic_id'];
    topicDataKind = json['topic_data_kind'];
    topicDataType = json['topic_data_type'];
    topicDataFileCodeName = json['topic_data_file_code_name'];
    code = json['code'];
    fileNameExt = json['file_name_ext'];
    html5FileName = json['html5_file_name'];
    html5FileNameApp = json['html5_file_name_app'];
    referenceUrl = json['reference_url'];
    noOfClicks = json['no_of_clicks'];
    priority = json['priority'];
    status = json['status'];
    displayType = json['display_type'];
    isDefault = json['is_default'];
    defaultTopicDateId = json['default_topic_date_id'];
    entryByInstituteUserId =
        (json['entry_by_institute_user_id'] ?? "").toString();
    addedType = json['added_type'];
    contentLevel = json['content_level'];
    contentTag = json['content_tag'];
    contentLang = json['content_lang'];
    isVerified = json['is_verified'];
    verifiedBy = json['verified_by'];
    isLocalContentAvailable = json['is_local_content_available'];
    html5DownloadUrl = json['html5_download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['institute_topic_data_id'] = this.instituteTopicDataId;
    data['online_institute_topic_data_id'] = this.onlineInstituteTopicDataId;
    data['institute_id'] = this.instituteId;
    data['parent_institute_id'] = this.parentInstituteId;
    data['institute_topic_id'] = this.instituteTopicId;
    data['topic_data_kind'] = this.topicDataKind;
    data['topic_data_type'] = this.topicDataType;
    data['topic_data_file_code_name'] = this.topicDataFileCodeName;
    data['code'] = this.code;
    data['file_name_ext'] = this.fileNameExt;
    data['html5_file_name'] = this.html5FileName;
    data['html5_file_name_app'] = this.html5FileNameApp;
    data['reference_url'] = this.referenceUrl;
    data['no_of_clicks'] = this.noOfClicks;
    data['priority'] = this.priority;
    data['status'] = this.status;
    data['display_type'] = this.displayType;
    data['is_default'] = this.isDefault;
    data['default_topic_date_id'] = this.defaultTopicDateId;
    data['entry_by_institute_user_id'] = this.entryByInstituteUserId;
    data['added_type'] = this.addedType;
    data['content_level'] = this.contentLevel;
    data['content_tag'] = this.contentTag;
    data['content_lang'] = this.contentLang;
    data['is_verified'] = this.isVerified;
    data['verified_by'] = this.verifiedBy;
    data['is_local_content_available'] = this.isLocalContentAvailable;
    data['html5_download_url'] = this.html5DownloadUrl;
    return data;
  }
}
