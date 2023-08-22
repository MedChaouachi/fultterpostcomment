class AppUser {  // Renommer la classe pour éviter la collision
  final String id;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  AppUser(this.id, this.email, this.password, this.firstName, this.lastName);
}
