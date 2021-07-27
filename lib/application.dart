String dbName = 'the_cadah_contacts.db';
int dbVersion = 1;

List<String> dbCreate = [
  // the List
  """
  CREATE TABLE contacts (
    id INTEGER PRIMARY KEY, 
    DeadPersonName TEXT NOT NULL,

    RequesterName TEXT NOT NULL,
    RequesterPhoneNumber TEXT,
    RequesterNationalId TEXT UNIQUE NOT NULL,

    ProviderName TEXT NOT NULL,
    ProviderPhoneNumber TEXT,
    ProviderReceivedDate TEXT,
    
    HelpDuration TEXT,

    HajjTypeAmount INTEGER,
    HajjTypeTimes INTEGER,

    NadharTypeAmount INTEGER,
    NadharTypeTimes INTEGER,

    PrayerTypeAmount INTEGER,
    PrayerTypeTimes INTEGER,

    FastTypeAmount INTEGER,
    FastTypeTimes INTEGER,

    AmalBrTypeAmount INTEGER,
    AmalBrTypeTimes INTEGER,

    notes TEXT,
    favorite INTEGER
  )""",
];
