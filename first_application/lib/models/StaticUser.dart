class StaticUser {
  final String id;
  final String email;
  final String password;

  StaticUser(this.id, this.email, this.password);

  static final StaticUser staticUser = StaticUser('1', 'test.com', 'password');
}
