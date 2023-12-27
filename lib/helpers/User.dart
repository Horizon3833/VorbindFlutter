class AppUser{
  late String _name;
  late int _number;
  late String _profileURL;
  late String _about;

  AppUser();

  void setName(String name){
    _name = name;
  }
  String getName(){
    return _name;
  }

  void setNumber(int number){
    _number = number;
  }
  int getNumber(){
    return _number;
  }

  void setProfile(String url){
    _profileURL = url;
  }
  String getProfile(){
    return _profileURL;
  }

  void setAbout(String about){
    _about = about;
  }
  String getAbout(){
    return _about;
  }
}