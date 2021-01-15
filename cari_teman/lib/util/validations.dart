class Validations {
  static String validateName(String value) {
    if (value.isEmpty) return 'Nama tidak boleh kosong.';
    final RegExp nameExp = new RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  static String validateEmail(String value) {
    if (value.isEmpty) return 'Email tidak boleh kosong.';
    final RegExp nameExp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,2"
        r"53}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-z"
        r"A-Z0-9])?)*$");
    if (!nameExp.hasMatch(value)) return 'Email tidak valid';
    return null;
  }

  static String validatePassword(String value) {
    if (value.isEmpty || value.length < 6) return 'Password tidak valid.';
    return null;
  }
}
