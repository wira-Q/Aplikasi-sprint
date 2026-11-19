class CompanyModel {
  const CompanyModel({
    required this.idCompany,
    required this.idUser,
    required this.companyName,
    this.industry,
    this.description,
    this.location,
    this.email,
    this.website,
    this.logo,
  });

  final int idCompany;
  final String idUser;
  final String companyName;
  final String? industry;
  final String? description;
  final String? location;
  final String? email;
  final String? website;
  final String? logo;

  factory CompanyModel.fromMap(Map<String, dynamic> map) => CompanyModel(
    idCompany: (map['id_company'] as num).toInt(),
    idUser: map['id_user'] as String,
    companyName: (map['company_name'] as String?) ?? '',
    industry: map['industry'] as String?,
    description: map['description'] as String?,
    location: map['location'] as String?,
    email: map['email'] as String?,
    website: map['website'] as String?,
    logo: map['logo'] as String?,
  );
}
