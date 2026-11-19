# O WorkManager cria seu banco Room por reflexão (WorkDatabase_Impl); sem isto o R8 remove a classe e o app fecha ao abrir.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
