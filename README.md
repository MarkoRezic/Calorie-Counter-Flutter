# CalorieCounter

FSRE student mobile application project made with Flutter and NodeJS.

# Instalacija i pokretanje projekta

Preduvjeti:
- instaliran Node.js i npm (potrebno samo za lokalno pokretanje backenda)
- instaliran Flutter
- instaliran Android Studio
- Android Emulator ili Fizi�ki Android ure�aj spojen USB-om
- postavljen API_BASE_URL u .env datoteci na heroku NodeJS aplikaciju ili na lokalni backend
- Mogu�e je i samo preuzimanje i instalacija .apk datoteke na android ure�aju, ili .ipa za iOS, backend je pokrenut na heroku NodeJS aplikaciji

# Pokretanje frontenda
- u Android Studio otvoriti root folder projekta, smjestiti `.env` datoteku uz postavljenu `API_BASE_URL` na backend koji �e se koristiti
- za lokalni backend u .env upisati `API_BASE_URL=http://localhost:3000`, a za backend na heroku link od aplikacije (primjer .env datoteke je .env.example)
- pokrenuti Emulator ili spojiti Android ure�aj USB-om, dopustiti na ure�aju otklanjanje pogre�aka putem USB-a (debugiranje) unutar opcija za razvojne programere
- u Android studiju odraditi Run za main.dart file smjesten unutar /lib foldera, eventualno podesiti Run konfiguraciju na Run > Edit Configurations... i odabrati main.dart
- nakon pokretanja se generira /build folder
- Aplikacija bi se trebala instalirati i pokrenuti na ure�aju
- Izgenerirana .apk datoteka se nalazi u /build/app/outputs/flutter-apk/app.apk
- Po defaultu se generira "debug" verzija, ukoliko je potrebna release verzija (puno br�a i slu�i za produkciju), mo�e se izgenerirati sa `flutter build apk`, ova apk �e se nalaziti unutar /build/app/outputs/flutter-apk/app-release.apk

# Pokretanje backenda
- za lokalni backend preuzeti git repozitorij https://github.com/MarkoRezic/Calorie-Counter-NodeJS
- u root folderu smjestiti .env datoteku i popuniti podatke za bazu i JWT hash kao �to je navedeno u .env.example
- pokrenuti lokalni backend u terminalu sa `npm start` iz root foldera od backend projekta (za heroku poslu�itelj nisu potrebni nikakvi koraci)
- nije potreban pokrenut MySQL, baza je na heroku poslu�itelju te ju i lokalni backend tako�er koristi
- ukoliko je potrebno i lokalnu bazu napraviti, potrebno je schemu kreirati i promijeniti podatke za spajanje unutar root foldera od backenda `.env` datoteci

# Instalacija gotove aplikacije
- u root folderu ovog repozitorija se nalazi i app-release.apk �ijom instalacijom se mo�e odmah koristiti aplikacija (Android ure�aji)

# Kori�tenje barkod skenera
- zakori�tenje skenera potrebno je dati dozvolu kori�tenja kamere na ure�aju
- potreban je fizi�ki ure�aj, emulatori ne podr�avaju ovu opciju 

## App screenshots
<p float="left">
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Po�etni%20zaslon.PNG" alt="Po�etni zaslon" width="250"/>
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Dnevnik%20ishrane.jpeg" alt="Dnevnik ishrane" width="250"/>
</p>
<p float="left">
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Nutritivne%20vrijednosti.jpeg" alt="Nutritivne vrijednost" width="250"/>
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Napredak.jpeg" alt="Napredak" width="250"/>
</p>