// String dbName = 'flutter_contacts.db';
String dbName = 'the_contacts.db';
int dbVersion = 1;

// firstName TEXT (changed to name)
// lastName TEXT (removed)

List<String> dbCreate = [
  // the List
  """
  CREATE TABLE contacts (
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL,
    phoneNumber TEXT,
    nationalId TEXT UNIQUE NOT NULL,
    helpDate TEXT,
    helpType TEXT,
    helpAmount INTEGER,
    helpDuration TEXT,
    notes TEXT,
    favorite INTEGER
  )""",
  // """CREATE TABLE contacts (
  //   id INTEGER PRIMARY KEY,
  //   name TEXT,
  //   nickName TEXT,
  //   work TEXT,
  //   phoneNumber TEXT,
  //   email TEXT,
  //   webSite TEXT,
  //   favorite INTEGER,
  //   created TEXT
  // )""",
];
