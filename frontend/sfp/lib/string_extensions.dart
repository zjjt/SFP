extension StringExtension on String {
  String capitalize1stLetter() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
